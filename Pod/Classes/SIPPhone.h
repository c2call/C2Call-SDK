//
//  SIPPhone.h
//  ioslib-sipphone
//
//  Created by Michael Knecht on 28.10.10.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlurryEventProtocol.h"
#import "WaitIndicatorProtocol.h"
#import "UserInfoProtocol.h"
#import "SIPConstants.h"

// Constants for property list
#define C2_USERID            @"Userid"
#define C2_PASSWORD          @"Password"
#define C2_DISPLAYNAME       @"Displayname"
#define C2_PROXY             @"Proxy"
#define C2_PROXYPORTS        @"ProxyPorts"

typedef enum {
    SCCallStatusNone,
    SCCallStatusDialing,
    SCCallStatusRinging,
    SCCallStatusConnected
} SCCallStatus;

@class SIPPhone, DDXMLElement;

/** SIPPhoneDelegate protocol.
 
 The SIPPhoneDelegate protocol provides callback methods to inform the delegate on certain call and messaging events.
 
 */
@protocol SIPPhoneDelegate<UserInfoDelegate, WaitIndicatorDelegate, FlurryEventsDelegate>

/** Notifies the delegate on initialization success.
 
 On SIPPhone startup the SIP client auto discovers the network environment like firewall and NAT, external and internal IP address and ports and establish a connection to the C2Call SIP Proxy.
 initializationSuccess will be called after the auto discover and connect process has been successfully completed.
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 @param phone - Current SIPPhone instance
 */
-(void) initializationSuccess:(SIPPhone *) phone;

/** Notifies the delegate on initialization failure.
 
 On SIPPhone startup the SIP client auto discovers the network environment like firewall and NAT, external and internal IP address and ports and establish a connection to the C2Call SIP Proxy.
 In case the connection the SIP Proxy cannot be established, initializationFailed will be called.
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 @param phone - Current SIPPhone instance
 @param reason - Failure reason
 
 */
-(void) initializationFailed:(SIPPhone *) phone withReason:(NSString *) reason;

/** Notifies the delegate on onlinestatus changes.
 
 The online status can change if the network connection is temporary lost.
 See C2NetworkStatusHandler to get the current network status.
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) onlineStatusUpdate;


/** Notifies the delegate on an outbound call event.
 
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) outboundCall:(SIPPhone *) phone;

/** Notifies the delegate on an inbound call event.
 
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) inboundCall:(SIPPhone *) phone fromUser:(NSString *) userid;

/** Notifies the delegate on an incoming message event.
 
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) message:(DDXMLElement *) msg;


/** Notifies the delegate on a ringing event.
 
 The ringing event occurs on an outbound call when the receiver sends a ringing or session progress notification (remote party rings).
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) ringing:(SIPPhone *) phone;

/** Notifies the delegate on a responseError event.
 
 The responseError event occurs on an outbound call when the remote party cannot be reached (busy, call rejected, etc.)
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) responseError:(SIPPhone *) phone withErrorCode:(int)errorCode;

/** Notifies the delegate on a call connected event.
 
 The connected event occurs on an outbound call, when the remote party has accepted the call.
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) connected:(SIPPhone *) phone;


/** Notifies the delegate on a call hang up event.
 
 The connected event occurs on an established call when the call has been disconnected.
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) hangUp:(SIPPhone *) phone;

@optional

/** Notifies the delegate on C2Call specific SIP events like presence, invite and group call events.
 
 In C2Call SDK the C2CallAppDelegate class will be called on all SIPPhoneDelegate events.
 To change the default behavior of the specific event handling, please overwrite the corresponding method in C2CallAppDelegate class.
 
 */
-(void) notifySIPEvent:(NSString *) event andData:(id) data;

@end


@class SIPHandler, C2NetworkStatusHandler, SCCallKitCallManager;
/** The SIPPhone class encapsules the SIP communication layer of the C2Call SDK.
 
 The SIPPhone class will be instantiated by the C2CallPhone class.
 It's not recommended to use the SIPPhone methods directly. All relevant call and messaging specific methods are mirrored in the C2CallPhone class for convenience. 
 */
@interface SIPPhone : NSObject<WaitIndicatorDelegate, FlurryEventsDelegate, UserInfoDelegate>

/**---------------------------------------------------------------------------------------
 * @name Properties
 *  ---------------------------------------------------------------------------------------
 */
/** SIPPhone userid.
 */
@property(nonatomic, readonly) NSString                  *userid;

/** SIPPhone delegate.
 */
@property(nonatomic, weak) id<SIPPhoneDelegate>          delegate;

/** Current call status information
 
 Available call states:
 
    SCCallStatusNone        - No active call
    SCCallStatusDialing     - Dialing
    SCCallStatusRinging     - Ringing
    SCCallStatusConnected   - Connected

 */
@property(nonatomic, readonly) SCCallStatus             callStatus;

/** Is the current call a video call
 */
@property(nonatomic, readonly) BOOL videoCall;

/** Is the current call a group call
 */
@property(nonatomic, readonly) BOOL groupCall;

/** Is this client the caller in the current active call?
 */
@property(nonatomic, readonly) BOOL isCaller;

/** Automatically uses public key encryption for instant messages and rich media messages if available for the receiver
 
 In case the receiver provdes a public key in his user record, automatically force end-to-end encryption
 for instant messages and rich media message attachments
 
 */
@property(nonatomic) BOOL                             preferMessageEncryption;

/** This option will be automatically set if the callerid of the user is verified
 */
@property(nonatomic) BOOL           callerIdVerified;

/**---------------------------------------------------------------------------------------
 * @name SIPPhone lifecycle handling
 *  ---------------------------------------------------------------------------------------
 */
/** Classes Initialization with a dictionary of properties.
 
 The actual SIPPhone initialization is actually done by the C2CallPhone.
 Calling this method manually is not recommended.
 
 @param properties A dictionary of properties
 @return SIPPhone instance
 */
- (id) initWithProperties:(NSDictionary *) properties;

/** Handles the Application Status willResignActive.
 
 The actual SIPPhone willResignActive is handled automatically by C2CallPhone.
 Calling this method manually is not recommended.
 
 */
-(void) willResignActive;

/** Handles the Application Status didEnterBackground.
 
 The actual SIPPhone didEnterBackground is handled automatically by C2CallPhone.
 Calling this method manually is not recommended.
 
 */
-(void) didEnterBackground;

/** Handles the Application Status willEnterForeground.
 
 The actual SIPPhone willEnterForeground is handled automatically by C2CallPhone.
 Calling this method manually is not recommended.
 
 */
-(void) willEnterForeground;

/** Handles the Application Status didBecomeActive.
 
 The actual SIPPhone didBecomeActive is handled automatically by C2CallPhone.
 Calling this method manually is not recommended.
 
 */
-(void) didBecomeActive;

/** Handles an incoming call while in background
 
 
 */
-(void) didReceiveCallInBackground;

/** Handles the Application Status willTerminate.
 
 The actual SIPPhone willTerminate is handled automatically by C2CallPhone.
 It's not recommended to call this method manually.
 
 */
-(void) willTerminate;

/** Sets the Application SessionId.
 
 Calling this method manually is not recommended.
 
 @param sid - Application SessionId
 */
-(void) setApplicationSessionId:(NSString *) sid;

/** Sets the AffiliateId.
 
 Calling this method manually is not recommended.
 
 @param affiliateId - AffiliateId
 */
-(void) setAffiliateId:(NSString *)affiliateId;


/** Starts the SIPPhone.
 
 Calling this method manually is not recommended.
 
 */
-(void) startSIPPhone;

/** Stops the SIPPhone.
 
 Calling this method manually is not recommended.
 
 */
-(void) stopSIPPhone;

/** Current online / connection status.
 
 @return YES - online/connected / NO - offline / disconnected
 
 */
-(BOOL) isOnline;

/** Is BackgroundCall running
 
 Indicates whether during background start whether the App has been woken up for a call.
 
 @return YES/NO
 */
-(BOOL) isBackgroundCall;

/** Is UDPTunnel over TCP active
 
 In case the firewall is blocking UDP data packet, the client automatically establish a UDP Tunnel over TCP port 80.
 This will cause additional delay on the connection, but will get at least through the firewall in most cases.
 
 @return YES - Connection via TCP / NO - Connection via UDP
 
 */
-(BOOL) isUDPTunnelActive;

/** Force a UDP Tunnel Connection
 */
-(BOOL) forceTunnel;

/** Return forceCallerIdVerify status
 */
-(BOOL) forceCallerIdVerify;

/**---------------------------------------------------------------------------------------
 * @name Call handling methods
 *  ---------------------------------------------------------------------------------------
 */
/** Calls a phone number.
 
 Calling a phone number, the number should typically start with the + and the international country code, followed by the area code without leading "0" and then the number (e.g. +14081234567).
 If the submitted number is not in international format, the function automatically tries to convert the number into international format.
 
 @param number - Phone number in international format
 */
-(void) callNumber:(NSString *) number;

/** Convert a local number into international number format
 
 Based on the vailable information from country and local area, 
 local numbers will be converted into internaltional number format 
 starting with +<countrycode><Areacode><number>
 
 @param number - Local number (e.g. (408) 123456)
 @return international number (e.g. +1408123456)
 */
-(NSString *) normalizeNumber:(NSString *) number;
+(NSString *) normalizeNumber:(NSString *) number;

/** Check whether the given number is a valid phone number
 
 @return YES / NO
 */
-(BOOL) isValidNumber:(NSString *) number;

/** Calls another C2Call Service user or group via VoIP call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 For example, the userid of the C2Call Test Call is "9bc2858f1194dc1c107".
 In order to call the Test Call simply do:
 
 [[SIPPhone currentPhone] callVoIP:@"9bc2858f1194dc1c107"];
 
 In order to call a user by his email address, simply do:
 
 [[SIPPhone currentPhone] callVoIP:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 */
-(void) callVoIP:(NSString *) callee;

/** Calls another C2Call Service user via VoIP call providing an additional action parameter
 
 In addition to the regular callVoIP method, this method allows to submit an additional user defined action parameter.
 This parameter can be retrieved at the receiver side via [[SIPPhone currentPhone] callAction] when the call has been notified.
 This allows to take specific action at the receiver, for example for emergency cases.
 The action parameter should be a single word only ASCII characters, for example @"EMERGENCY"
 
 @param callee - C2Call Userid or Email Address of a registered user
 @param action - User defined action parameter
 
 */
-(void) callVoIP:(NSString *) callee callAction:(NSString *) action;

/** Calls another C2Call Service user or group via VoIP call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 For example, the userid of the C2Call Test Call is "9bc2858f1194dc1c107".
 In order to call the Test Call simply do:
 
 [[SIPPhone currentPhone] callVoIP:@"9bc2858f1194dc1c107"];
 
 In order to call a user by his email address, simply do:
 
 [[SIPPhone currentPhone] callVoIP:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 @param isGroupCall - Specify whether it's a group call.
 
 */
-(void) callVoIP:(NSString *) callee groupCall:(BOOL) isGroupCall;



/** Calls another C2Call Service user or group via Video call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 In order to call a user by his email address, simply do:
 
 [[SIPPhone currentPhone] callVideo:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 */
-(void) callVideo:(NSString *) callee;

/** Calls another C2Call Service user via Video call providing an additional action parameter
 
 In addition to the regular callVideo method, this method allows to submit an additional user defined action parameter.
 This parameter can be retrieved at the receiver side via [[SIPPhone currentPhone] callAction] when the call has been notified.
 This allows to take specific action at the receiver, for example for emergency cases.
 The action parameter should be a single word only ASCII characters, for example @"EMERGENCY"
 
 @param callee - C2Call Userid or Email Address of a registered user
 @param action - User defined action parameter
 
 */
-(void) callVideo:(NSString *) callee callAction:(NSString *) action;


/** Calls another C2Call Service user or group via Video call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 In order to call a user by his email address, simply do:
 
 [[SIPPhone currentPhone] callVideo:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 @param isGroupCall - Specify whether it's a group call.
 */
-(void) callVideo:(NSString *) callee groupCall:(BOOL) isGroupCall;

/** Accepts an incoming call.
 
 @param useVideo - Allow video for this call
 */
-(void) takeCall:(BOOL) useVideo;

/** Hangs up a call.
 
 Hangs up an active call.
 */
-(void) hangUp;

/** Reject an incoming call.
 */
-(void) rejectCall;

/**---------------------------------------------------------------------------------------
 * @name Message Functions
 *  ---------------------------------------------------------------------------------------
 */
/** Submits an instant message.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 An instant message will be either delivered via SIP message to the receiver while the app is in foreground or via Push Notification while the app is in background.
 
 [[SIPPhone currentPhone] submitMessage:@"This is a message" toUser:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param message - The message
 @param target - C2Call Userid or email address
 */
-(void) submitMessage:(NSString *) message toUser:(NSString *) target;

/** Submits the next message in reply to the defines message id
 
 @param msgId - Message Reference of the Reply
 */
-(void) useInReplyTo:(NSString *) msgId;


/** Submits an instant message.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 An instant message will be either delivered via SIP message to the receiver while the app is in foreground or via Push Notification while the app is in background.
 
 [[SIPPhone currentPhone] submitMessage:@"This is a message" toUser:@"max.muster@registeredemail.com" preferEncryption:NO];
 
 To access user data, please see also SCDataManager class.
 
 @param message - The message
 @param target - C2Call Userid or email address
 @param encrypted - If set to YES, the message will be encrypted with the Public Key of the remot user if available.
 */
-(void) submitMessage:(NSString *) message toUser:(NSString *) target preferEncryption:(BOOL) encrypted;

/** Submits an SMS/Text message.
 
 Sending an SMS/Text message will be charged to the user credit according to our pricelist.
 SMS/Text messages are 160 characters or 70 2-Byte characters. Longer messages will be automatically split into multiple SMS and charged accordingly.
 In of mixing 1-Byte character and 2-Bytes character in a message, you have only 70 characters per messages even it contains only one 2-Byte character.
 Sending SMS/Text messages into the USA requires a C2Call DID-Number.
 
 [[SIPPhone currentPhone] submitMessage:@"This is a message" toNumber:@"+14081234567"];
 
 The number should typically start with the + and the international country code, followed by the area code without leading "0" and then the number (e.g. +14081234567).
 If the submitted number is not in international format, the function automatically tries to convert the number into international format automatically, based on the users country settings.
 To access user data, please see also SCDataManager class.
 
 @param message - The message
 @param number - Receiver number in international format
 */
-(void) submitMessage:(NSString *) message toNumber:(NSString *) number;

/** Submitting an Event Message.

 An Event Message is supposed to be an internal notification from app to app
 to submit status information or other information which shouldn't be displayed to the user directly.
 
 Every event name has to start with prefix "SCEVNT_" otherwise it will not be handled
 
 On the receiver side, the event can be handled by overwriting C2CallAppDelegate method as follows:
 
    -(void) notifySIPEvent:(NSString *)event andData:(id)data
    {
        [super notifySIPEvent:event andData:data];
        
        if ([event isEqualToString:@"SCEVNT_MYEVENT"]) {
            NSString *message = [[SIPPhone currentPhone] messageBodyFromEvent:data];
            NSString *userid = [[SIPPhone currentPhone] useridFromEvent:data];
            NSString *displayName = [[SIPPhone currentPhone] displayNameFromEvent:data];
            NSLog(@"SCEVNT_MYEVENT : %@ <%@> : %@", displayName, userid, message);
        }
        
    }

 
 @param event - The event name, SCEVNT_ plus just 7 Bit ASCII characters no blanks
 @param message - The message
 @param userid - receiver userid
 */
-(void) submitEvent:(NSString *)event withMessage:(NSString *)msg toUser:(NSString *) userid;

/** Submitting a isTyping Event to target userid.
 
 This event will be fired by SCChatController if the user is typing.
 The event should only be fired every 2 seconds while a user is typing
 
 @param userid - target userid
*/
-(void) submitTypingEventToUser:(NSString *) userid;

/** Extract the message body from event data
 
 @param data - Event data received by the C2CallAppDelegate
 @return message body if available or nil
 */
-(NSString *) messageBodyFromEvent:(id) data;

/** Extract the userid from event data
 
 @param data - Event data received by the C2CallAppDelegate
 @return userid if available or nil
 */
-(NSString *) useridFromEvent:(id) data;

/**---------------------------------------------------------------------------------------
 * @name Remote Party Information
 *  ---------------------------------------------------------------------------------------
 */
/** Remotes party userid or phone number of an incoming or established call.
 
 @return Remote party userid or phone number
 */
-(NSString *) remoteParty;

/** Remotes party display name.
 
 @return Remote party display name
 */
-(NSString *) remoteDisplayname;

/** InboundCall line identifier
 
 If a call comes from an external number, this method returns the number which has been called.
 
 @return Inbound Line Number or "VoIP"
 */
-(NSString *) inboundLine;

/** Receive callAction submitted with the inbound call notification
 
 In order to support specific user definied call actions, the caller can provide an a user defined action parameter,
 for example "EMERGENCY" when calling, so that the receiver of the call can differently notified.
 
 @see callVoIP:callAction:
 @see callVideo:callAction:
 
 @return User defined call action
 */
-(NSString *) callAction;

/**---------------------------------------------------------------------------------------
 * @name DTMF Tones
 *  ---------------------------------------------------------------------------------------
 */
/** Sends a DTMF Tone to the remote party.
 
 Sometimes IVRs / answer maschines require DTMF tones to select menu options during a call.
 Supported DTMF tones are : 0 - 9, '*' = 10, '#' = 11
 
 @param tone - The DTMF tone (Allowed values : 0 - 11)
 @param durationInMS - Duration of the DTMF Tone (typically 200ms)
 */
-(void) sendDTMFTone:(int) tone withInterval:(int) durationInMS;

/** Sends a DTMF Tone to the remote party.
 
 Sometimes IVRs / answer maschines require DTMF tones to select menu options during a call.
 Supported DTMF tones are : 0 - 9, '*' = 10, '#' = 11
 The duration of the tone event call be defined by the length of the key press. (Start on key down / End on key up)
 
 @param tone - The DTMF tone (Allowed values : 0 - 11)
 @param durationInMS - Duration of the DTMF Tone (typically 200ms)
 */
-(void) startToneEvent:(int) event;

/** Ends a DTMF tone event.
 */
-(void) endToneEvent;

/**---------------------------------------------------------------------------------------
 * @name Static Methods
 *  ---------------------------------------------------------------------------------------
 */
/** Current SIPPhone Instance.
 
 @return Current SIPPhone Instance
 */
+(SIPPhone *) currentPhone;

/** Set the default OfflineStatus
 
 Valid Values are:
    OS_OFFLINE,
    OS_IPUSH,
    OS_IPUSHCALL
 
 @param status - Offline status in background or when application will exit
 */
+(void) setDefaultOfflineStatus:(SipOnlineStatusT) status;


/** Turns Speaker Off during a call-
 
 On iPhone only.
 
 */
+(void) speakerOff;

/** Turns Speaker On during a call.

 On iPhone only.

 */
+(void) speakerOn;

/** Set the default UDP Tunnel server and port
 
 @param tunnelHost - Hostname of the Tunnel Server
 @param tunnelPort - Port of the Tunnel Server
 
 */
+(void) setUDPTunnelHost:(NSString *) tunnelHost andPort:(int) tunnelPort;


/** Force to use a UDP Tunnel Connection
 
 @param force - YES - Always use a tunnel connection (only for testing purpuses)
 
 */
+(void) setForceTunnel:(BOOL) force;

/** Disable the UDP Tunnel
 
 @param disable - YES - Don't use a UDP Tunnel Connection at all
 
 */
+(void) setDisableTunnel:(BOOL) disable;

/** Set this option if you want to allow calls to PSTN / Landline only for verified callerids
 
 In case the user try to call or SMS to a landline or mobile phone number and his callerId has not been verified
 via PIN SMS / PIN Call, the action will be denied by the API and an NSNotification is posted:
 
    NSNotification: SC_CALLERIDVERFICATION_REQUIRED
 
 You can handle this notification and present a dialog to the user to verify his callerid first.
 
 */
+(void) setForceCallerIdVerify:(BOOL)forceCallerIdVerify;

/** Enable G729 Codec for VoIP Audio
 
 IMPORTANT: Enabling the G729 Codec requires to license it from the patent owner.
 Default G729 is disabled. 
 
 @param use - Enable / Disable the codec
 
 */
+(void) setUseG729:(BOOL) use;

/** Use iOS 10 CallKit
 
 @param useCallKit - Enable / Disable CallKit
 @param useVideo - Enable CallKit also for Video Calls
 
 */
+(void) setUseCallKit:(BOOL)useCallKit withVideo:(BOOL) useVideo;

/** Force Ringing instead of SessionProgress
 
 SessionProgress is the ringback tone send by the receiver when the other phone is ringing.
 Sometimes, the session progress fails to deliver audio data, so no ringback tone will be played.
 Setting forceRinging will always play the locally created ringing sound.
 
 @param force - Enable / Disable
 
 */
+(void) setForceRinging:(BOOL) force;


@end
