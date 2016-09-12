//
//  GRPAppDelegate.m
//  greedpatch-ios
//
//  Created by Bell on 09/10/2016.
//  Copyright (c) 2016 greedlab.com. All rights reserved.
//

#import "GRPAppDelegate.h"
#import "GRPPatchManager.h"
#import "GRPViewController.h"

@implementation GRPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // config greedpatch
    [[GRPPatchManager sharedInstance] setProjectId:@"57d61489f0068561dce9baee"];
    [[GRPPatchManager sharedInstance] setToken:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE0NzM2NDg2MzA0ODgsImlkIjoiNTdkM2JmMmY5MDE1ZWU0N2ZjYzNjYWJhIiwic2NvcGUiOiJwYXRjaDpjaGVjayJ9.YPedieEibUgLecWDmuIVIdkY_Ra-4Qa2HeIQpE7Z_k8"];
    [[GRPPatchManager sharedInstance] setCompressPassword:@"compress_password"];
    
    /**
     *  0: release
     *
     *  1: test
     *
     *  2: compress
     */
    NSInteger env = 0;
    
    if (env == 1) { // test local patch
        [[GRPPatchManager sharedInstance] testPatch];
    } else if (env == 2) { // compress patch
        [[GRPPatchManager sharedInstance] compressPatch];
    } else {
        // patch
        [[GRPPatchManager sharedInstance] patch];
        
        // check need patch
        [[GRPPatchManager sharedInstance] requestPatch];
    }
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    GRPViewController *viewController = [[GRPViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
