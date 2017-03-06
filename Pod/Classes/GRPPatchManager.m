//
//  GRPPatchManager.m
//  Pods
//
//  Created by Bell on 16/9/10.
//  Copyright © 2016年 greedlab.com. All rights reserved.
//

#import "GRPPatchManager.h"
#import <AFNetworking/AFNetworking.h>
#import "FileHash.h"
#import "JPEngine.h"
#import "ZipArchive.h"

@interface GRPPatchManager ()

@property (nonatomic, strong, nonnull) NSString *projectVersion;

@property (nonatomic, assign) NSInteger patchVersion;

@end

@implementation GRPPatchManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _projectVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"projectVersion"];
        _patchVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"patchVersion"];
        _serverAddress = @"https://patchapi.greedlab.com";
    }
    return self;
}

+ (nonnull GRPPatchManager *)sharedInstance {
    static GRPPatchManager *__patchManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __patchManager = [[self alloc] init];
    });
    return __patchManager;
}

- (void)requestPatch {
    if (!_projectId) {
        NSLog(@"projectId can not be null");
        return;
    }
    if (!_serverAddress) {
        NSLog(@"serverAddress can not be null");
        return;
    }
    if (!_token) {
        NSLog(@"token can not be null");
        return;
    }
    
    // url
    NSString *url = [_serverAddress stringByAppendingString:@"/patches/check"];
    
    // parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [parameters setObject:currentBundleVersion forKey:@"project_version"];
    if (_projectVersion && [_projectVersion isEqualToString:currentBundleVersion]) {
        [parameters setObject:[NSNumber numberWithInteger:_patchVersion] forKey:@"patch_version"];
    }
    [parameters setObject:_projectId forKey:@"project_id"];
    
    // header
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:[@"Bearer " stringByAppendingString:_token] forHTTPHeaderField:@"Authorization"];
    [requestSerializer setValue:@"application/vnd.greedlab+json;version=1.0" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableURLRequest *mutableRequest = [requestSerializer requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    [[[AFHTTPSessionManager manager] dataTaskWithRequest:mutableRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            NSLog(@"%@",responseObject);
        } else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSString *hash = [responseObject objectForKey:@"hash"];
                NSString *project_version = [responseObject objectForKey:@"project_version"];
                NSInteger patch_version = [[responseObject objectForKey:@"patch_version"] integerValue];
                NSString *patch_url = [responseObject objectForKey:@"patch_url"];
                [self patchWithProjectVewsion:project_version patchVewsion:patch_version patchUrl:patch_url hash:hash];
            } else {
                NSLog(@"no need to patch");
            }
        }
    }] resume];
}

- (void)patch {
    if ([self checkNeedPatch]) {
        [self realPatch];
    }
}

- (void)testPatch {
    [JPEngine startEngine];
    NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"js" inDirectory:@"/"];
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = obj;
        NSString *fileName = [path lastPathComponent];
        if (fileName.length && ![fileName isEqualToString:@"JSPatch.js"]) {
            [JPEngine evaluateScriptWithPath:path];
        }
    }];
}

- (void)compressPatch {
    NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"js" inDirectory:@"/"];
    if (array.count <= 1) {
        return;
    }
    NSString *zipPath = [self compressZipPath];
    NSLog(@"patch file path: %@", zipPath);
    NSString *documentDirectory = [self documentDirectory];
    NSString *zipDirectory = [documentDirectory stringByAppendingPathComponent:@"patch"];
    zipDirectory = [zipDirectory stringByAppendingPathComponent:@"compress"];
    [[NSFileManager defaultManager] removeItemAtPath:zipDirectory error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:zipDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    if (![zip CreateZipFile2:zipPath Password:_compressPassword]) {
        return;
    }
    
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = obj;
        NSString *fileName = [path lastPathComponent];
        if (fileName.length && ![fileName isEqualToString:@"JSPatch.js"]) {
            [zip addFileToZip:path newname:fileName];
        }
    }];
    [zip CloseZipFile2];
    
    NSString *hashCode = [FileHash md5HashOfFileAtPath:zipPath];
    NSLog(@"hash of patch file is: %@", hashCode);
    
    NSString *patchDirectiory = [self compressJsDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:patchDirectiory error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:patchDirectiory withIntermediateDirectories:YES attributes:nil error:NULL];
    if ([zip UnzipOpenFile:zipPath]) {
        [zip UnzipFileTo:patchDirectiory overWrite:YES];
        [zip UnzipCloseFile];
    }
}

#pragma mark - private

/**
 *  check whether need to patch
 */
- (BOOL)checkNeedPatch {
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return (_projectVersion && [_projectVersion isEqualToString:currentBundleVersion] && _patchVersion > 0);
}

/**
 *  download express and patch
 */
- (void)patchWithProjectVewsion:(NSString *)projectVersion patchVewsion:(NSInteger)patchVersion patchUrl:(NSString *)patchUrl hash:(NSString *)hash {
    if (!projectVersion) {
        NSLog(@"projectVersion is null");
        return;
    }
    if (!patchUrl) {
        NSLog(@"patchUrl is null");
        return;
    }
    if (!hash) {
        NSLog(@"hash is null");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:patchUrl]] returningResponse:NULL error:NULL];
        if (data) {
            NSString *strPatchVersion = [NSString stringWithFormat:@"%@",@(patchVersion)];
            NSString *patchDirectory = [self patchDirectoryWithProjectVersion:projectVersion patchVersion:strPatchVersion];
            [[NSFileManager defaultManager] removeItemAtPath:patchDirectory error:NULL];
            [[NSFileManager defaultManager] createDirectoryAtPath:patchDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
            
            NSString *patchZipPath = [self patchZipPathWithProjectVersion:projectVersion patchVersion:strPatchVersion];
            [data writeToFile:patchZipPath atomically:YES];
            
            NSString *hashCode = [FileHash md5HashOfFileAtPath:patchZipPath];
            if (hashCode && hash && [hashCode isEqualToString:hash]) { // check hash
                NSString *directory = [self jsDirectoryWithProjectVersion:projectVersion patchVersion:strPatchVersion];
                [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
                
                ZipArchive *zip = [[ZipArchive alloc] init];
                if ([zip UnzipOpenFile:patchZipPath Password:_compressPassword]) {
                    if ([zip UnzipFileTo:directory overWrite:YES]) {
                        [self setProjectVersion:projectVersion];
                        [self setPatchVersion:patchVersion];
                        
                        if ([self checkNeedPatch]) {
                            [self realPatch];
                        }
                    }
                    [zip UnzipCloseFile];
                }
            }
        }
    });
}

/**
 *  real patch
 */
- (void)realPatch {
    NSString *strPatchVersion = [NSString stringWithFormat:@"%@", @(_patchVersion)];
    NSString *directory = [self jsDirectoryWithProjectVersion:_projectVersion patchVersion:strPatchVersion];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        return;
    }
    NSLog(@"=== start patch");
    [JPEngine startEngine];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [directory stringByAppendingPathComponent:(NSString *) obj];
        if ([path hasSuffix:@".js"]) {
            [JPEngine evaluateScriptWithPath:path];
        }
    }];
    NSLog(@"=== end patch");
}

#pragma mark - file path

/**
 *  get document directory
 *
 *  @return document directory
 */
- (NSString *)documentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

/**
 *  compress/js
 *
 *  @return Document/patch/compress/js
 */
- (NSString *)compressJsDirectory {
    NSString *documentDirectory = [self documentDirectory];
    NSString *directory = [documentDirectory stringByAppendingPathComponent:@"patch"];
    directory = [directory stringByAppendingPathComponent:@"compress"];
    directory = [directory stringByAppendingPathComponent:@"js"];
    return directory;
}

/**
 *  compressed patch.zip
 *
 *  @return Document/patch/compress/patch.zip
 */
- (NSString *)compressZipPath {
    NSString *documentDirectory = [self documentDirectory];
    NSString *directory = [documentDirectory stringByAppendingPathComponent:@"patch"];
    directory = [directory stringByAppendingPathComponent:@"compress"];
    directory = [directory stringByAppendingPathComponent:@"patch.zip"];
    return directory;
}

/**
 *  patchVersion
 *
 *  @return Document/patch/projectVersion/patchVersion
 */
- (NSString *)patchDirectoryWithProjectVersion:(NSString *)projectVersion patchVersion:(NSString *)patchVersion {
    NSString *documentDirectory = [self documentDirectory];
    NSString *patchDirectory = [documentDirectory stringByAppendingPathComponent:@"patch"];
    patchDirectory = [patchDirectory stringByAppendingPathComponent:projectVersion];
    patchDirectory = [patchDirectory stringByAppendingPathComponent:patchVersion];
    return patchDirectory;
}

/**
 *  js
 *
 *  @return Document/patch/projectVersion/patchVersion/js
 */
- (NSString *)jsDirectoryWithProjectVersion:(NSString *)projectVersion patchVersion:(NSString *)patchVersion {
    NSString *patchDirectory = [self patchDirectoryWithProjectVersion:projectVersion patchVersion:patchVersion];
    NSString *luaDirectory = [patchDirectory stringByAppendingPathComponent:@"js"];
    return luaDirectory;
}

/**
 *  patch.zip
 *
 *  @return Document/patch/projectVersion/patchVersion/patch.zip
 */
- (NSString *)patchZipPathWithProjectVersion:(NSString *)projectVersion patchVersion:(NSString *)patchVersion {
    NSString *patchDirectory = [self patchDirectoryWithProjectVersion:projectVersion patchVersion:patchVersion];
    NSString *patchZipPath = [patchDirectory stringByAppendingPathComponent:@"patch.zip"];
    return patchZipPath;
}

#pragma mark - setter

- (void)setProjectVersion:(NSString *)projectVersion {
    if (!projectVersion) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:projectVersion forKey:@"projectVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _projectVersion = projectVersion;
}

- (void)setPatchVersion:(NSInteger)patchVersion {
    [[NSUserDefaults standardUserDefaults] setInteger:patchVersion forKey:@"patchVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _patchVersion = patchVersion;
}

@end
