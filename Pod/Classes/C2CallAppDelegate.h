//
//  C2CallAppDelegate.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <Foundation/Foundation.h>

#import "C2CallPhone.h"

@class DDXMLDocument;


/** Application Delegate base class for an automatic initialization of C2Call services.

As a VoIP and Messaging Service the C2Call Framework requires a complex initialization procedure and as well a detailed monitoring of all application states like active (app is in foreground), inactive (screensaver is active), background (app is in background) or termined. During the different states, the C2Call Framework has to maintain the connection to the C2Call backend systems, monitor network changes, automatically retrieve missed messages or call records and nevertheless save battery power as good as possible. In order to make it easy for the developer, all this complex application management has been capsuled into the C2CallAppDelegate base class. This base class should now be the UIApplicationDelegate base class for apps using the C2Call Framework.
 
 The C2CallAppDelegate class implements the following methods from UIApplicationDelegate:
 
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    - (void)applicationDidBecomeActive:(UIApplication *)application;
    - (void)applicationWillResignActive:(UIApplication *)application;
    - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
    - (void)applicationWillTerminate:(UIApplication *)application;
    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
    - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
    - (void)applicationDidEnterBackground:(UIApplication *)application
    - (void)applicationWillEnterForeground:(UIApplication *)application

 On all methods above the corresponding super method has to be called when overwriting in your own C2CallAppDelegate subclass.


 */

@interface C2CallAppDelegate : UIResponder<UIApplicationDelegate, C2CallPhoneDelegate>

/** @name Properties */
/** Sets the AffiliateId from the C2Call SDK Developer Account.
 */
@property(nonatomic, strong)    NSString        *affiliateid;

/** Sets the Application Secret from the C2Call SDK Developer Account.
 */
@property(nonatomic, strong)    NSString        *secret;

/** Auto-Login Token (Enterprise Customers only)
 */
@property(nonatomic, strong)    NSString        *loginToken;

/** Auto-Login Session (Enterprise Customers only)
 */
@property(nonatomic, strong)    NSString        *loginSession;

/** Sets the Sandbox Mode.
 
 If set to YES, Push Notifications will use the Developer Push Certificate.
 
 If set to NO, Push Notification will use the Production Push Ceterificate.
 
 Also, in Sandbox Mode all type of rewarded offers are available.
 
 */
@property(nonatomic) BOOL                       useSandboxMode;

/** Automatically sets the Application Badge to the number of missed events
 
 This will set the useApplicationBadge property in C2CallPhone on initialization
 */
@property(nonatomic) BOOL                       useApplicationBadge;

/** Show the Online/Offline Status prompt
 
 Default is on. Overwrite method : 
 
    -(void) showPrompt:(NSString *) p tmo:(NSTimeInterval) t
 
 To define your own prompt.
 
 */
@property(nonatomic) BOOL                       useOnlineStatusPrompt;

/** Use Photo Effects for Picture Messages

    This is the pre-set for using photo effects when sending a picture message from camera or photo album.
    3 values are possible:
        - SC_PHOTO_NOEFFECTS : No effects will be applied
        - SC_PHOTO_APPLYEFFECTS : Always apply photo effects when sending a picture message
        - SC_PHOTO_USERCHOICE : A popup menu allows the user to choose whether he wants to applay a photo effect, after capturing an image.
 
        In order to use photo effects with the C2Call SDK, please add the following library from the 3rdparty-libs folder:
        R1PhotoEffectsSDK.a and add the CoreText Framework to your application.
 
        In your project target settings, add the parameter "-ObjC" to "other Linker Flags".
 
 */
@property(nonatomic) SCPhotoEffects             usePhotoEffects;


/** Enable the iOS8 VoIP Push feature
 
 Before setting this option to YES, please check whether the device is currently running iOS8 or higher.
 You also need to upload a VoIP Push Certificate in the DevArea then.
 This option has to be set in applicationDidFinishLaunching:withOptions
 
 With VoIP Push all incoming calls will wake-up the app immediately and receive the push notification first, before 
 it will be presented to the user. The Application has the chance to restore the network connections then and present 
 a custom notification to the user.
 
 Please also see the methods :
 
    - callNotificationForUserid:displayName:videoCall
    - missedCallNotificationForUserid:displayName:
 
 The presented call notification can be customized here.
 
 */
@property(nonatomic) BOOL                       usePushKit;

/** Set the Supported PushTypes for PushKit Framework
 */
@property(nonatomic, strong) NSSet              *pushKitPushTypes;

/** Use iOS 10 CallKit
 */
@property(nonatomic) BOOL                       useCallKit;


/** Is the user with the current credentials logged in and has a server session
 */
@property(nonatomic, readonly) BOOL             loginCompleted;

/** Are valid credentials available for single sign on
 */
@property(nonatomic, readonly) BOOL             hasValidCredentials;



/** Optional: Sets the email address for Login.
 
 If no email address and password will be set in the C2CallAppDelegate, the C2CallAppDelegate will fire a segue named “SCLaunchScreenControllerSegue” on applicationDidBecomeActive.
 
    @try {
        [self.mainScreenController performSegueWithIdentifier:@"SCLaunchScreenControllerSegue" sender:nil];
    }
    @catch (NSException *exception) {
    }
 
 The SCLaunchScreenController represents the startup dialog for the user to authenticate or register to the service. In case the segue is not existing, nothing happens.
 The SDK provides a predefined SCLaunchScreenController, SCLoginController and SCRegisterController to implement login and registration. 
 The standard Login and Registration Controler stores the email address and password in the NSUserDefaults. C2CallAppDelegate will automatically use them next time on application start for an automatic login.
 For a new application development it is recommended to use the standard login and register controls to create test accounts before implementing an individual login and registration process.
 
 */
@property(nonatomic, strong)    NSString        *c2email;

/** Optional: Sets the password address for Login.
 */
@property(nonatomic, strong)    NSString        *c2password;

/** Applications main screen controller.
 
 Will be set on applicationDidFinishLaunching.
 
    self.mainScreenController = self.window.rootViewController;

 */
@property(nonatomic, weak)      UIViewController     *mainScreenController;

/** References to the C2Call SDK storyboard.
 
 The C2Call SDK storyboard provides all C2Call SDK GUI components, which
  will be set on applicationDidFinishLaunching.
 
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SCStoryboard" bundle:nil];
    self.storyboard = sb;

 */
@property(nonatomic, strong)    UIStoryboard       *storyboard;

/** References to the Application Custom Storyboard.

 In Storyboard Applications, this will be the storyboard, referenced by the rootViewController of the App.
 In case the App is using tradition XIB Files, an additional Custom Storyboard needs to be created 
 and correctly set by Application delegateMethod didFinishLaunchingWithOptions.
 Please see the Sample Code SDK-UsingXIBFiles Sample
 
 */
@property(nonatomic, strong)    UIStoryboard       *customStoryboard;


/** References to the C2Call SDK Resource Bundle.
 
 The C2Call SDK Resource Bundle contains all SDK resources.
 This property is only set when provided as Cocoapods SDK
 
 */
@property(nonatomic, readonly)  NSBundle           *sdkbundle;

/** Standard UIApplicationDelegate window property.
 */
@property (strong, nonatomic)   UIWindow *window;

/** @name Instantiate SDK ViewControllers */
/** Instantiates a C2Call SDK GUI Component.
 
 The C2Call SDK provides various standard components for all its communication features. These components may be used as is or can be modified by the application developer. To do so, copy the GUI Component from the SCStoryboard to the application MainStoryboard and modify it.
 
 instantiateViewControllerWithIdentifier first seeks the component in the MainStoryboard and then in the SCStoryboard to instantiate the component. This ensures that the developer version takes precedence over the standard version.
 
 @param vcname - Storyboard Name of the ViewController
 */
-(id) instantiateViewControllerWithIdentifier:(NSString *) vcname;

/** Present the LaunchScreen in case, no user is currently defined for autologin.
 
 Overwrite this method to do your own action here.
 This method fires performSegueWithIdentifier:@"SCLaunchScreenControllerSegue" by default.
 
 */
-(void) showLaunchScreen;

/** @name Facebook Login */
/** Can be called from launch screen when choosing Facebook login
 
 The Facebook Login option is for professional users only.
 
 @return Returns NO, for free users, YES for professional and enterprise users.
 */
-(BOOL) startUsingFacebookLogin;


/** @name Logout */
/** Logouts the current user and show the launch screen.
 */
-(void) logoutUser;

/** @name Other Methods */

/** Will be called by C2CallPhone on register result.
 */
-(void) processRegisterResult:(DDXMLDocument *) doc;

/** Shows User Notification from C2Call Service.
 
 The C2Call Backend Service sends notifications of the following type:
 
     SC_NOTIFICATIONTYPE_REWARD - The user has received a reward from a rewarded advertising.
     SC_NOTIFICATIONTYPE_NEWFRIENDS - The user got new friends connected.
     SC_NOTIFICATIONTYPE_USERMESSAGE - A system message for the user like new version information etc.
     SC_NOTIFICATIONTYPE_ADDCREDIT - Credit has been added to the users account.

 The developer should overwrite this method to present the hint to the user.
 
 @param message - The actual hint message
 @param notificationType - The notification type
 */
- (void)showHint:(NSString *) message withNotificationType:(SCNotificationType) notificationType;

/** Callback to Present a dialog for payment required actions
 
 The parameter type indicates whether is a call or message action.
 Overwrite this method to present a specific action to the user here.
 
 @param type - "Call" or "Message"
 */
- (void) showPaymentRequiredForType:(NSString *) type;

/** Handle custom SIP Events.
 
 Always call super class with unhandled events
 
 @param event - Name of the event
 @param data - 
 */
-(void) notifySIPEvent:(NSString *) event andData:(id) data;

/** Customize Notification Message for inbound call in background
 
 Actually an App using C2Call SDK with VoIP services has two background modes.
 During the frist 10 minutes in background the app keeps being active and will receive 
 call notifications via normal SIP communication. After 10 minutes, the app goes to sleep and any call notification 
 will be sent by the server via Apple Push Notification Service.
 During the first 10 mintues, the inbound call will then be presented as NSLocalNotification
 to the user. In order to customize the message, presented to the user via NSLocalNotification, please overwrite
 this method and provide a UILocalNotification which will be presented to the user instead.
 
 @param userid - Userid of the Caller
 @param displayName - Display Name of the Caller
 @param isVideoCall - YES - it's a video call, NO it's an audio call
 @return UILocalNotifcation to display, if nil no notification will be presented
*/
-(UILocalNotification *) callNotificationForUserid:(NSString *) userid displayName:(NSString *) displayName videoCall:(BOOL) isVideoCall;

/** Customize Notification Message for missed call in background
 @param userid - Userid of the Caller
 @param displayName - Display Name of the Caller
 @return UILocalNotifcation to display, if nil no notification will be presented
 */
-(UILocalNotification *) missedCallNotificationForUserid:(NSString *) userid displayName:(NSString *) displayName;

/** Shows the online status prompt when connected to the service
 
 Overwrite this method to show your own customized prompt
 This method uses SCPromptController. For GUI modification, just copy SCPromptController in 
 your storyboard file and change it accordingly.
 
 @param prompt - Message to show
 @param tmo - time interval to remove the message from screen
 */
-(void) showPrompt:(NSString *) prompt tmo:(NSTimeInterval) tmo;

/** Presents the SCInboundCallController on incoming call
 
 Overwrite this Method to present your own
 */
-(void) showIncomingCall;


/** Presents the SCCallStatusController on call connected event
 
 Overwrite this Method to present your own
 */
-(void) showCallStatus;

/** @name Static Methods */
/** Gets the current Application Delegate.
 
 @return Current Application Delegate
 
 */
+(instancetype) appDelegate;

@end
