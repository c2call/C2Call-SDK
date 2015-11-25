//
//  UserInfoProtocol.h
//  C2CallPhone
//
//  Created by Michael Knecht on 5/11/11.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#ifndef __USERINFOPROTOCOL
#define __USERINFOPROTOCOL

/** The UserInfoDelegate protocol defines certain information events, which require user attention.
 
 For each information event, a default behavior is defined in C2CallAppDelegate class and it typically show an alert dialog with a pre-defined message.
    
 Overwriting the C2CallAppDelegate methods allows to define different behavior.
 */
@protocol UserInfoDelegate <NSObject>

@optional

/** Shows No Internet Alert.
 
 The device cannot connect to the internet at the moment WiFi or 3G might be disabled
 
 */
-(void) showNoInternet;

/** Shows Invalid Login.
 
 The username or password is wrong.
 
 */
-(void) showInvalidLogin;

/** Shows Server not reachable.
 
 The device cannot connect to the C2Call Service at the moment. The necessary communication ports might be blocked by the firewall or not internet connection is available.
 
 */
-(void) showServerNotReachable;

/** Shows Password has been changed successfully
 
 */
-(void) showPasswordChangeSuccess;

/** Shows Password couldn't be changed
 
 */
-(void) showPasswordChangeFailed;

/** Shows Call Forwarding has been set-up successfully
 
 */
-(void) showCallForwardSuccess;

/** Shows Call Forwarding couldn't be set-up correctly
 
 */
-(void) showCallForwardFailed;

/** Shows Offline Alert
 
 */
-(void) showOfflineAlert;

/** Shows Purchase Error
 
 Either Apple InApp purchase has reported an error or the credit couldn't be added to the users account.
 */
-(void) showPurchaseError;


/** Shows User Profile update failed
 
 Changes to the User Profile couldn't updated to the server.
 */
-(void) showUpdateUserProfileFailed;

/** Shows User Profile update success
 
 Changes to the User Profile have been updated to the server.
 */
-(void) showUpdateUserProfileSuccess;

/** Shows SIP Connection Wifi failed
 
 The necessary SIP Ports might be blocked by the firewall on Wifi.
 
 */
-(void) showSIPConnectionWifiFailed;

/** Shows SIP Connection 3G failed
 
 The necessary SIP Ports might be blocked by the firewall on 3G.
 
 */
-(void) showSIPConnection3GFailed;

/** Shows Take Call failed
 
 The call couldn't be accepted due to an internat error.
 
 */
-(void) showTakeCallFailed;

@end

#endif
