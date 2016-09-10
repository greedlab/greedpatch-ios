//
//  GRPPatchManager.m
//  Pods
//
//  Created by Bell on 16/9/10.
//  Copyright © 2016年 greedlab.com. All rights reserved.
//

#import "GRPPatchManager.h"

#import "FileHash.h"
#import "JPEngine.h"
#import "ZipArchive.h"

@interface GRPPatchManager ()

/**
 *  the project version of the last patch
 */
@property (nonatomic, strong, nonnull) NSString *projectVersion;

/**
 *  the version of the last patch
 */
@property (nonatomic, strong, nullable) NSString *patchVersion;

@end

@implementation GRPPatchManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _projectVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"projectVersion"];
        _patchVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"patchVersion"];
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
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [parameters setObject:currentBundleVersion forKey:@"project_version"];
    if (self.projectVersion && [self.projectVersion isEqualToString:currentBundleVersion]) {
        [parameters setObject:self.patchVersion forKey:@"patch_version"];
    }
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
    if (![zip CreateZipFile2:zipPath]) {
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
 *  打包的patch js位置
 *
 *  @return documentDirectory/patch/compress/js
 */
- (NSString *)compressJsDirectory {
    NSString *documentDirectory = [self documentDirectory];
    NSString *directory = [documentDirectory stringByAppendingPathComponent:@"patch"];
    directory = [directory stringByAppendingPathComponent:@"compress"];
    directory = [directory stringByAppendingPathComponent:@"js"];
    return directory;
}

/**
 *  打包的patch zip位置
 *
 *  @return documentDirectory/patch/compress/patch.zip
 */
- (NSString *)compressZipPath {
    NSString *documentDirectory = [self documentDirectory];
    NSString *directory = [documentDirectory stringByAppendingPathComponent:@"patch"];
    directory = [directory stringByAppendingPathComponent:@"compress"];
    directory = [directory stringByAppendingPathComponent:@"patch.zip"];
    return directory;
}

/**
 *  当前版本的patch位置
 *
 *  @return documentDirectory/patch/projectVersion/patchVersion
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
 *  @return documentDirectory/patch/projectVersion/patchVersion/js
 */
- (NSString *)jsDirectoryWithProjectVersion:(NSString *)projectVersion patchVersion:(NSString *)patchVersion {
    NSString *patchDirectory = [self patchDirectoryWithProjectVersion:projectVersion patchVersion:patchVersion];
    NSString *luaDirectory = [patchDirectory stringByAppendingPathComponent:@"js"];
    return luaDirectory;
}

/**
 *  patch.zip
 *
 *  @return documentDirectory/patch/projectVersion/patchVersion/patch.zip
 */
- (NSString *)patchZipPathWithProjectVersion:(NSString *)projectVersion patchVersion:(NSString *)patchVersion {
    NSString *patchDirectory = [self patchDirectoryWithProjectVersion:projectVersion patchVersion:patchVersion];
    NSString *patchZipPath = [patchDirectory stringByAppendingPathComponent:@"patch.zip"];
    return patchZipPath;
}

#pragma mark - private

/**
 *  检测本地是否有补丁需要打
 */
- (BOOL)checkNeedPatch {
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return (_projectVersion && [_projectVersion isEqualToString:currentBundleVersion] && _patchVersion);
}

/**
 *  下载，解压，打补丁
 *
 *  @param entity   参数
 */
- (void)patchWithProjectVewsion:(NSString *)projectVewsion patchVewsion:(NSString *)patchVewsion patchUrl:(NSString *)patchUrl hash:(NSString *)hash {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *patchUrl = [NSURL URLWithString:patchUrl];
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:patchUrl] returningResponse:NULL error:NULL];
        if (data) {
            NSString *patchDirectory = [self patchDirectoryWithProjectVersion:projectVersion patchVersion:patchVersion];
            [[NSFileManager defaultManager] removeItemAtPath:patchDirectory error:NULL];
            [[NSFileManager defaultManager] createDirectoryAtPath:patchDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
            
            NSString *patchZipPath = [self patchZipPathWithProjectVersion:projectVersion patchVersion:patchVersion];
            [data writeToFile:patchZipPath atomically:YES];
            
            NSString *hashCode = [FileHash md5HashOfFileAtPath:patchZipPath];
            if (hashCode && entity.hashCode && [hashCode isEqualToString:hash]) { // hash校验
                NSString *directory = [self jsDirectoryWithProjectVersion:entity.projectVersion patchVersion:entity.patchVersion];
                [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
                
                ZipArchive *zip = [[ZipArchive alloc] init];
                if ([zip UnzipOpenFile:patchZipPath]) {
                    if ([zip UnzipFileTo:directory overWrite:YES]) {
                        [self setProjectVersion:entity.projectVersion];
                        [self setPatchVersion:entity.patchVersion];
                        
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

- (void)realPatch {
    NSString *directory = [self jsDirectoryWithProjectVersion:_projectVersion patchVersion:_patchVersion];
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

#pragma mark - setter

- (void)setProjectVersion:(NSString *)projectVersion {
    if (!projectVersion) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:projectVersion forKey:@"projectVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _projectVersion = projectVersion;
}

- (void)setPatchVersion:(NSString *)patchVersion {
    if (!patchVersion) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:patchVersion forKey:@"patchVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _patchVersion = patchVersion;
}

@end
