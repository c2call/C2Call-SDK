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
    // VideoChat1@gmail.com / Password : 123456
    // VideoChat2@gmail.com / Password : 123456
    // VideoChat3@gmail.com / Password : 123456
    // VideoChat4@gmail.com / Password : 123456
    // VideoChat5@gmail.com / Password : 123456
    // VideoChat6@gmail.com / Password : 123456
    
    // IMPORTANT :
    // 2. Please manually add the following files to your "Copy Bundle Resources" section in your Application Target Build Phases:
    // myshader.vsh
    // myshader.fsh
    // Just seek for myshader and drag&drop it into your "Copy Bundle Resources" section. This is important as the files will not be copied into your Application Bundle by default at compile time.
    // The video call does not work in this case.
    // It should be in there already, but will be automatically removed when replacing SocialCommunication.ressources. So it has to be added again then.
    
    self.affiliateid = @"1F3E9213F51427D53";
    self.secret = @"27ed87e8356390b50c7c20fc5029b55b";
    
#ifdef __DEBUG
    self.useSandboxMode = YES;
#endif
    
    // Customize Message Sounds
    // [RingtoneHandler defaultHandler].messageOut = nil; // Switch sound off
    // [RingtoneHandler defaultHandler].messageOut = [[C2SystemSound alloc] initWithRessource:@"MySound" ofType:@"wav"];
    
    // iOS8 VoIP Push Support
    // In order to enable iOS8 VoIP Push Support please do the following steps:
    // 1. Create a VoIP Push Certificate in your Apple Developer Account
    // 2. Download the VoIP Certificate and import it into your KeyChain
    // 3. Select the imported Certificate in your KeyChain including the private key (expand the ">" and select both)
    // 4. Export the Certificate as .p12 File (use a password)
    // 5. Import the .p12 file in your Apps section in C2Call DevArea
    // 6. Add PushKit Framework to your App
    // 7. Set Deployment Target to iOS8
    // 8. Validate that your Architecture includes ARM64 (required by PushKit)
    // 9. Add import statement
    // #import <PushKit/PushKit.h>
    // 10. Uncomment the following lines of Code here:
    // self.usePushKit = YES;
    // self.pushKitPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [super applicationWillTerminate:application];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showHint:(NSString *) message withNotificationType:(SCNotificationType) notificationType
{
    if (notificationType == SC_NOTIFICATIONTYPE_REWARD) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reward" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

@end
