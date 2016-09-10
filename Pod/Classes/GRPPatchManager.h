//
//  GRPPatchManager.h
//  Pods
//
//  Created by Bell on 16/9/10.
//  Copyright © 2016年 greedlab.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRPPatchManager : NSObject

/**
 *  project ID.
 *  default: null.
 *  must set before requestPatch and patch.
 */
@property (nonatomic, strong, nonnull) NSString *projectId;

/**
 *  the address of the hot patch server.
 *  default: http://patchapi.greedlab.com/.
 */
@property (nonatomic, strong, nonnull) NSString *serverAddress;

/**
 *  compress and archive password.
 *  default: null.
 */
@property (nonatomic, strong, nullable) NSString *compressPassword;

/**
 *  the project version of the last patch
 */
@property (nonatomic, strong, nonnull, readonly) NSString *projectVersion;

/**
 *  the version of the last patch
 */
@property (nonatomic, strong, nullable, readonly) NSString *patchVersion;

+ (nonnull GRPPatchManager *)sharedInstance;

/**
 *  send a network request to check whether need to patch
 */
- (void)requestPatch;

/**
 *  patch
 */
- (void)patch;

/**
 *  test local js files
 */
- (void)testPatch;

/**
 *  compress local js files to a zip file
 */
- (void)compressPatch;

@end
