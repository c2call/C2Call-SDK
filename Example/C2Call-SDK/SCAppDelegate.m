//
//  SCAppDelegate.m
//  C2Call-SDK
//
//  Created by Michael Knecht on 11/22/2015.
//  Copyright (c) 2015 Michael Knecht. All rights reserved.
//

#import "SCAppDelegate.h"
#import <SocialCommunication/SocialCommunication.h>

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Test Accounts:
    // CallAPI1@gmail.com / Password : 123456
    // CallAPI2@gmail.com / Password : 123456
    
    self.affiliateid = @"1F3E9213F51427D53";
    self.secret = @"04c592fd6e20dfa2c3c5d196369b3105";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Frameworks/SocialCommunication.framework/SocialCommunication" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    
    NSLog(@"Path: %@", path);
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [super applicationWillResignActive:application];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [super applicationDidEnterBackground:application];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    UIImage *ico = [UIImage imageNamed:@"btn_ico_call"];
    
    NSLog(@"Image: %@", ico);
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [super applicationWillTerminate:application];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
