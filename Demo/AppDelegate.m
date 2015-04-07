//
//  AppDelegate.m
//  Demo
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask,
                                                              YES) lastObject];
    
    NSLog(@"Run in %@", docsPath);
    
    NSString *path = [docsPath stringByAppendingPathComponent:@"zips"];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *vc = [ViewController new];
    vc.path = path;
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = naVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
