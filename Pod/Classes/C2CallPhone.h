//
//  C2CallPhone.h
//  C2CallPhone
//
//  Created by Michael Knecht on 5/11/11.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "SIPPhone.h"

#define C2_C2CALLAPIURL      @"C2CallAPIUrl"
#define C2_EMAIL             @"EMail"
#define C2_AFFILIATEID       @"AffiliateId"
#define C2_SECRET            @"Secret"
#define C2_VOIPPUSH          @"VoIPPush"

typedef enum {
    SCMEDIATYPE_TEXT,
    SCMEDIATYPE_IMAGE,
    SCMEDIATYPE_USERIMAGE,
    SCMEDIATYPE_VIDEO,
    SCMEDIATYPE_VOICEMAIL,
    SCMEDIATYPE_FILE,
    SCMEDIATYPE_VCARD,
    SCMEDIATYPE_FRIEND,
    SCMEDIATYPE_LOCATION,
} SCRichMediaType;

typedef enum {
    SC_NOTIFICATIONTYPE_REWARD,
    SC_NOTIFICATIONTYPE_NEWFRIENDS,
    SC_NOTIFICATIONTYPE_USERMESSAGE,
    SC_NOTIFICATIONTYPE_ADDCREDIT
} SCNotificationType;

typedef enum {
    SC_PHOTO_NOEFFECTS,
    SC_PHOTO_APPLYEFFECTS,
    SC_PHOTO_USERCHOICE
} SCPhotoEffects;

typedef enum {
    SCCALLERID_USE_VERIFIEDNUMBER,
    SCCALLERID_USE_DID,
    SCCALLERID_USE_DID1,
    SCCALLERID_USE_DID2,
    SCCALLERID_USE_DID3,
    SCCALLERID_USE_DID4,
} SCCallerId;

/** C2CallPhoneDelegate protocol inherits the SIPPhoneDelegate protocol.
 
 In C2Call SDK the C2CallAppDelegate registers automtically as C2CallPhoneDelegate and therefore receives all delegate calls.
 In case the delegate methods need to be changed, overwrite this methods in C2CallAppDelegate and call the [super <method name>].
 
 */
@protocol C2CallPhoneDelegate <SIPPhoneDelegate>

/** Will be called only once after successful login of the user.
 */
-(void) c2callLoginSuccess;

/** Will be called in case user login failed.
 */
-(void) c2callLoginFailed;

/** For later use.
 */
-(void) c2callCreateUserFromFacebook;

@end

@class MOC2CallUser, MOC2CallEvent, C2BlockAction;

/**---------------------------------------------------------------------------------------
 * @defgroup Mainclasses
 *  ---------------------------------------------------------------------------------------
 */
/** C2CallPhone - Base class for low-level C2Call phone and messaging API.

 This class provides the low-level API methods for major C2Call communications features:
    - Phone calls to PSTN and mobile phone networks,
    - VoIP and video calls,
    - Group calls (voIP and Video)
    - Instant Messaging,
    - SMS / Text Messages
    - Rich Media Messages like photo, video, voicemail, location, etc.
 
 This class also provides the core functionality to start and stop the C2CallPhone and handle the background behavior.
 The C2CallAppDelegate uses this Class in order to initialize the connection to the C2Call service and to handle the background status of the app.
 
 Example call functionality:
 
    // Call the C2Call TestCall
    [[C2CallPhone currentPhone] callVoIP:@"9bc2858f1194dc1c107"];
 
 Example messaging functionality:
 
    // Send an SMS / Text message
    [[C2CallPhone currentPhone] submitMessage:@"Hi, this is an SMS" toNumber:@"+1408234123456"];

 
 Example Rich Messaging Functionality:
    #import <SocialCommunication/UIViewController+SCCustomViewController.h>
    ...skip...
    [self captureImageFromCameraWithQuality:UIImagePickerControllerQualityTypeMedium andCompleteAction:^(NSString *key) {
        [[C2CallPhone currentPhone] submitRichMessage:key message:@"Hi, see my photo..." toTarget:@"max@gmail.com"];
    }];
 */


@interface C2CallPhone : NSObject

/**---------------------------------------------------------------------------------------
 * @name Properties
 *  ---------------------------------------------------------------------------------------
 */
/** C2CallPhone delegate.
 */
@property(weak, nonatomic, nullable) id<C2CallPhoneDelegate>    delegate;

/** SIPPhone instantiated by C2CallPhone.
 */
@property(nonatomic, strong, nullable) SIPPhone                   *sipphone;

/** Start-up properties.
 */
@property(nonatomic, strong, nonnull) NSDictionary               *properties;

/** Is login completed after start-up.
 */
@property(nonatomic) BOOL                             loginCompleted;

/** Facebook Login in progress.
 */
@property(nonatomic, readonly) BOOL                             processingFacebookLogin;

/** Set the Sandbox Mode.
 
 If set to YES, Push Notifications will use the Developer Push Certificate.
 
 If set to NO, Push Notification will use the Production Push Ceterificate.
 
 Also, in Sandbox Mode all type of rewarded offers are available.
 
 */
@property(nonatomic) BOOL                             useSandboxMode;

/** Automatically sets the Application Badge to the number of missed events
 */
@property(nonatomic) BOOL                             useApplicationBadge;

/** Automatically uses public key encryption for instant messages if available for the receiver
 
 In case the receiver provides a public key in his user record, automatically force end-to-end encryption
 for instant messages
 
 */
@property(nonatomic) BOOL                             preferMessageEncryption;


/** Automatically hang up on connection timeout
 
 @see setConnectionTimeout:
 */
@property(nonatomic) BOOL                             hangupOnConnectionTimeout;

/** AffiliateId available in C2Call SDK Developer Area.
 */
@property(nonatomic, readonly, nonnull) NSString               *affiliateId;

/** Current SessionId
 */
@property(nonatomic, readonly, nullable) NSString               *sessionId;



/** Application Secret available in C2Call SDK Developer Area.
 */
@property(nonatomic, readonly, nonnull) NSString               *secret;

/** Auto-Login Token (Enterprise Customers only)
 */
@property(nonatomic, strong, nullable) NSString *loginToken;

/** Auto-Login Session (Enterprise Customers only)
 */
@property(nonatomic, strong, nullable) NSString       *loginSession;

/** registerStatus
 
 Numeric return value only available after after registration
 */
@property(nonatomic, readonly) NSInteger    registerStatus;


/**---------------------------------------------------------------------------------------
 * @name C2CallPhone lifecycle handling
 *  ---------------------------------------------------------------------------------------
 */
/** Class Initialization with a dictionary of properties.
 
 The actual C2CallPhone initialization is actually done by the C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 @param properties A dictionary of properties
 @return C2CallPhone instance
 */
-(nullable id) initWithProperties:(nonnull NSDictionary *) properties;

/** Initializes Affiliate Data.
 
 The actual C2CallPhone start is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) initAffiliate;

/** Starts the C2CallPhone, connect to the C2Call Service and launch the SIPPhone.
 
 The actual C2CallPhone start is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) startC2CallPhone;

/** Starts the C2CallPhone from background launch, connect to the C2Call Service and launch the SIPPhone.
 
 The actual C2CallPhone startC2CallPhoneInBackground is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) startC2CallPhoneInBackground;

/** Stops the C2CallPhone and disconnect from C2Call Service.
 
 The actual C2CallPhone stop is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) stopC2CallPhone;

/** Handles the Application Status willResignActive.
 
 The actual C2CallPhone willResignActive is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) willResignActive;

/** Handles the Application Status didEnterBackground.
 
 The actual C2CallPhone didEnterBackground is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) didEnterBackground;


/** Handles the Application Status willEnterForeground.
 
 The actual C2CallPhone willEnterForeground is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */ 
-(void) willEnterForeground;

/** Handles the Application Status didBecomeActive.
 
 The actual C2CallPhone didBecomeActive is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) didBecomeActive;

/** Handles the Application Status willTerminate.
 
 The actual C2CallPhone willTerminate is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) willTerminate;

/** Logout the current active user.
 
 The actual C2CallPhone logoutUser is handled automatically by C2CallAppDelegate.
 It's not recommended to call this method manually.
 
 */
-(void) logoutUser;

/** WakeUp in Background Handler
 
 With VoIP Push Notifications, the App will wakeup in background on notification receive.
 However, the actual C2CallPhone handler is not active then and tasks like refresh
 Call or Message history will not work. 
 
 With this wakeUpInBackground method, the C2Call Phone Handler can be temporary activated
 and a task like retrieving the call or message histroy from the server can be completed
 in a block handler. 
 wakeUpInBackground only works when not in active status.
 
 @param wakeUpAction - Block of actions to be fired after the C2Call Phone handler has been 
 connected.
 */

-(void) wakeUpInBackground:(nullable C2BlockAction *) wakeUpAction;

/**---------------------------------------------------------------------------------------
 * @name Other Methods
 *  ---------------------------------------------------------------------------------------
 */

/** Check if user exists for a given email address
 
 This method can be used before login in order to check whether a given email address would be a new user 
 or an existing user.
 
 @param email Email address to check
 @return YES - User exists / NO - User does not exist
 */
-(BOOL) existingUser:(nonnull NSString *) email;

/** Check if user exists for a given phone number
 
 This method can be used before login in order to check whether a given phone number would be a new user
 or an existing user.
 This method can only be used on dedicated server installations where a phone number of a user must be system wide unique.
 
 @param phone Phone number to check
 @return Email address of the user if exists else nil
 */
-(nullable NSString *) userForPhoneNumber:(nonnull NSString *) phone;


/** Get the name for a given userid.

 This method returns the Firstname / Lastname or Email address for a given user ID.
 Typically "Firstname Lastname" if both are available. Alternative Firstname or Lastname if one is available or the email address if both are not available.
 
 @param userid C2Call Userid of registered user.
 @return Name of the user
 */
-(nullable NSString *) nameForUserid:(nonnull NSString *) userid;

/** Check whether a given userid is actually a group.
 
 @return YES / NO
*/
-(BOOL) isGroupUser:(nonnull NSString *) userid;

/** Register Apple Push Notification Token.
 
 The C2Call Backend Service needs the push notification token in order to sumit push notifications to your app.
 This method is called by C2CallAppDelegate on didRegisterForRemoteNotificationsWithDeviceToken.
 It's not recommended to call this method manually.
 
 */
-(void) registerAPS:(nonnull NSData *)token;

/** Set the Application Badge Number with current number of missed events.
 
 This Method will be called automatically on Application will resign active.
 */
-(void) refreshApplicationBadgeNumber;

/** keepAliveHandler for maintaining background connections.
 
 This Method will be called automatically every 10 minutes while in background.
 It maintains the session and remote data updates once every hour.
 */
-(void) keepAliveHandler;

// SIPPhone Wrapper Functions
/**---------------------------------------------------------------------------------------
 * @name SIPPhone wrapper methods
 *  ---------------------------------------------------------------------------------------
 */
/** Call a phone number.

 Calling a phone number, the number should typically start with the + and the international country code followed by the area code without leading "0" and then the number (e.g. +14081234567).
 If the submitted number is not in international format the function automatically tries to convert the number into international format.
 
 @param number - Phone number in international format
 */

-(void) callNumber:(nonnull NSString *) number;

/** Call another C2Call Service user or group via VoIP call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId. 
 For example, the userid of the C2Call Test Call is "9bc2858f1194dc1c107". 
 In order to call the Test Call simply do:
 
    [[C2CallPhone currentPhone] callVoIP:@"9bc2858f1194dc1c107"];
 
 In order to call a user by his email address, simply do:
 
    [[C2CallPhone currentPhone] callVoIP:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 */
-(void) callVoIP:(nonnull NSString *) callee;

/** Call another C2Call Service user or group via Video call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 In order to call a user by his email address, simply do:
 
    [[C2CallPhone currentPhone] callVideo:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 */
-(void) callVideo:(nonnull NSString *) callee;

/** Call another C2Call Service user or group via Video call.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 In order to call a user by his email address, simply do:
 
 [[C2CallPhone currentPhone] callVideo:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param callee - C2Call Userid or Email Address of a registered user
 @param isGroupCall - Specify whether it's a group call.
 */
-(void) callVideo:(nonnull NSString *) callee groupCall:(BOOL) isGroupCall;

/** Accept an incoming call.
 
 @param useVideo - Allow video for this call
 */
-(void) takeCall:(BOOL) useVideo;

/** Hang up a call.

 Hang up an active call.
 */
-(void) hangUp;

/** Reject an incoming call.
 */
-(void) rejectCall;


/** Set the active callerid for the call or SMS
 
 The C2Call SDK support a number verification for your own phone number and up to 5 C2Call numbers.
 If the user has a verified number and one or more DIDs (C2Call numbers), this method can be used to choose
 the phone number which will be used for outbound calls or SMS.
 The active number can be changed on the fly before the actuall call or SMS.
 
 The following options are available:
 
    SCCALLERID_USE_VERIFIEDNUMBER   - Use your own verified number
    SCCALLERID_USE_DID              - Use the 1st DID
    SCCALLERID_USE_DID1             - Use the 2nd DID
    SCCALLERID_USE_DID2             - Use the 3rd DID
    SCCALLERID_USE_DID3             - Use the 4th DID
    SCCALLERID_USE_DID4             - Use the 5th DID

 In case the choosen caller id is not available, use own verified number will be the default
 
 @param cid - The callerid to use
 */
-(BOOL) setActiveCallerId:(SCCallerId) cid;

/** Returns the type of the active callerId
 
 @return Active CallerId
 */
-(SCCallerId) activeCallerIdType;

/** Returns  the active callerId as phone number
 
 @return Active CallerId
 */
-(nullable NSString *) activeCallerId;

/** connectionTimeout set the timeout in seconds, when the connection will be dropped,
 because no packets are received any longer.
 
 @param connectionTimeout - Timeout when the connection will be dropped.
 */
-(void) setConnectionTimeout:(NSTimeInterval)connectionTimeout;

/** videoPacketTimeout sets the timeout intervall for a notification, 
 when video packets are not longer received. 
 
 In case the remote party send the app in background, video stops but audio continues.
 Set the timeout intervall when to receive an NSNotification on that issue, 
 for example to present an avatar image to the user .
 
 The default timeout is 3s.
 
 It will send the following NSNotification:
 C2Call:VideoStalling - No video packet received for the last timeout seconds
 C2Call:VideoResume - No video packet received for the last timeout seconds
 
 
 @param timeout - Timeout when the VideoStalling notification will be sent
 */
-(void) setVideoStallingTimeout:(NSTimeInterval)timeout;

/** connection stalling timeout sets the timeout intervall for a notification,
 when packets are not longer received.

 In case of a network intterupt, it may happen that no packet are received for a couple of seconds.
 The system will send a notification when this issues is detected.
 
 The default timeout is 3s.
 
 It will send the following NSNotification:
 C2Call:ConnectionStalling - No packet received for the last timeout seconds
 C2Call:ConnectionResume - No packet received for the last timeout seconds
 
 @param timeout - Timeout when the ConnectionStalling notification will be sent
 */
-(void) setConnectionStallingTimeout:(NSTimeInterval)timeout;


/** @name Call Status Information Methods */
/** Provides a list of Userid's for the current active members in a Group Call.
 @return List of userids
 */
-(nullable NSArray *) activeMembersInGroupCall;

/** Provides a list of Userid's for the current active members in a Group Call.
 
 @param groupid - groupid of the group
 @return List of userids
 */
-(nullable NSArray *) activeMembersInCallForGroup:(nonnull NSString *) groupid;

/** Return the video status of an active group call
 
 @param groupid - groupid of the group
 @return YES: Video call / NO: Audio call
 */
-(BOOL) activeVideoCallForGroup:(nonnull NSString *) groupid;


/** Provides Userid or Phone Number of the remote party in the current active call.
 @return Userid or Phone Number
 */
-(nullable NSString *) remotePartyInActiveCall;

/** Provides the Display Name of the remote party in the current active call
 @return Display Name of Remote Party
 */
-(nullable NSString *) displayNameForRemotePartyInActiveCall;

/** @name User / Group Management */

/** Submit a phone number verification PIN for register user with phone number
 
 If you want to implement a WhatsApp style user registration with phone number, use this method to 
 submit a verification PIN to the users phone. Typically the PIN will be submitted as SMS, however 
 for landline phone numbers or some mobile networks, SMS will not be received by the user. 
 In this case, use forcePinCall, the user will be then called on his phone and the PIN code will be read to the user.
 This method requires to master credit in your developer account, as the costs for the SMS or the PIN Call 
 will be charged from your master credit.
 
 In case of SMS, a PIN message can be specified. Please use %PIN as placeholder where the actual PIN will be set 
 in your message text.
 
 @param number - phone number in international format (e.g. +1408123456)
 @param pinMessage - The PIN Message sent to the user or nil (default message is : PIN: <your pin>)
 @param forcePinCall - YES / Use a pin call instead of SMS. NO / Use SMS if possible else use PIN call
 
*/
-(void) numberVerificationForRegister:(nonnull NSString *) number withPinMessage:(nullable NSString *) pinMessage forcePinCall:(BOOL) force withCompletionHandler:(nullable void (^)(BOOL success))handler;

/** Register a new User
 
 This method takes a dictionary of the following Key/Value pairs to register a user:
 
    Firstname   : Firstname of the User
    Lastname    : Lastname of the User
    EMail       : EMail address of the user (must have a valid email domain)
    Password    : The user password. If nil, the user will be created with a generated password.
    Phone       : Phone number of the user in international format (e.g. +14081234567)
    NumberPIN   : Verification PIN for phone number (see numberVerificationForRegister Method)
    Country     : Country of the User. If nil, will be determined automatically.
    CountryCode : Default country code. If nil, will be determined automatically.
 
 The Country and CountryCode parameter is very important to differentiate between local and international phone numbers.
 Typically users have phone number in local format in their phone book. In order to convert those numbers correctly in international format which is required by the service,
 the the SDK needs to know the users home country and country code.
 For user registration with phone number (like WhatsApp or other apps doing it) please use numberVerificationForRegister method first to request a PIN.
 Fill the Phone and NumberPIN fields then. As email address you may use a generic address like phonenumber@domain (domain must be a valid email domain) or nickname@domain.
 The NumberPIN must be valid, otherwise registration fails.
 
 SampleCode:
 
    NSDictionary *itsme = [NSDictionary dictionaryWithObjectsAndKeys:@"Georg", @"Firstname", @"Simple", @"Lastname", @"Georg.Simple@gmail.com", @"EMail", nil];
    
    [[C2CallPhone currentPhone] registerUser:itsme 
                                withCompletionHandler:^(BOOL success, NSString *result) {
        NSLog(@"Success : %d / %@", success, result);

		if (success) {
        	[[C2CallPhone currentPhone] startC2CallPhone];
		}
    }];

 
 @param registration - The registration dictionary
 @param handler - The completion handler. Will be called with a success parameter and a result string.
 
 */
-(void) registerUser:(nonnull NSDictionary *) registration  withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable result))handler;

/** Login existing user 
 
 Login an existing user with email address and password.
 The completion handler will be called on success or on failure
 
 Available result codes are as follows:
 
 0: successful login
 2: invalid password
 14: error - please see error message
 
 @param email - email address
 @param password - password
 @param handler - the completion handler
 @return YES - Login initiated, completion handler will be called, NO - error in parameters
 
 */
-(BOOL) loginWithUser:(nonnull NSString *)email andPassword:(nonnull NSString *) password withCompletionHandler:(nullable void (^)(BOOL success, int resultCode, NSString * _Nullable resultMessage))handler;

/** Login existing user with temporary loginToken
 
 Login an existing user with temporary autologin token
 This API is only available to enterprise users using the server side affiliate API to create autologin tokens.
 This can be used for conferencing systems, to create invite links with automatic login.
 The completion handler will be called on success or on failure
 
 Available result codes are as follows:
 
 0: successful login
 2: invalid password
 14: error - please see error message
 
 @param token - auto login token
 @param handler - the completion handler
 @return YES - Login initiated, completion handler will be called, NO - error in parameters
 
 */
-(BOOL) loginWithToken:(nonnull NSString *)token andCompletionHandler:(nullable void (^)(BOOL success, int resultCode, NSString * _Nullable resultMessage))handler;

/** Login existing user with sessionid
 
 Login an existing user with sessionid create by Affiliate API call
 This API is only available to enterprise users using the server side affiliate API user sessions.
 This can be used for conferencing systems, to create invite links with automatic login.
 The completion handler will be called on success or on failure
 
 Available result codes are as follows:
 
 0: successful login
 2: invalid password
 14: error - please see error message
 
 @param token - auto login token
 @param handler - the completion handler
 @return YES - Login initiated, completion handler will be called, NO - error in parameters
 
 */
-(BOOL) loginWithSession:(nonnull NSString *)session andCompletionHandler:(nullable void (^)(BOOL success, int resultCode, NSString * _Nullable resultMessage))handler;

/** Send Password Email

 Send a password email to reset the user password
 This method is only available to customers with dedicated SDK server.
 @param email - email address
 */
-(void) submitPasswordEMail:(nonnull NSString *) email;

/** Get the last time the user was active in the app
 
 This method returns the date when the user was active in the App (using in foreground)
 
 @param userid - Userid of the user
 @return The last online timestamp as date
 */
-(nullable NSDate *) lastTimeOnlineForUser:(nonnull NSString *) userid;

/** Get the last time the user was active in the app
 
 This method returns the date when the user was active in the App (using in foreground)
 The last online time is provided as time ago string (like 1h ago).
 
 @param userid - Userid of the user
 @return The last online timestamp as date
 */
-(nullable NSString *) lastTimeOnlineForUserAsString:(nonnull NSString *) userid;

/** Enable Public/Private Key Encryption for message communication
 
 This is a restricted API for Enterprise Developers only.
 End-to-End Group Encryption uses 2048-Bit Public/Private Key encryption in order to privately share messages and attachemens between users.
 With enable encryption, messages and attachements will be automatically encrypted with the public key of the receiver, so that only the receiver will be able
 to decrypt messages and attachements using his private key, stored only on his device. Attachments and messages are stored on the servers are not longer readable to any 3rd party.
 Public/Private Key encrytion requires every communication partnerto enable encryption for his account.
 
 @param handler - completion handler, will be called after public/private key-pair has been created and the public key has been distributed.
 
 @return YES - encrytion will be enabled, completion handler will be called. NO - encryption cannot be enabled or is already enabled, the completion handler will not be called.
 */
-(BOOL) enableEncryptionWithCompletionHandler:(nullable void (^)(BOOL success))handler;

/** Disable encrytion and removed public/private key-pair.
 
 @param handler - completion handler, will be called after user profile has been updated.
 
 @return YES - encrytion will be dis-abled, completion handler will be called. NO - encryption cannot be disabled or is already disabled, the completion handler will not be called.
 */

-(BOOL) disableEncryptionWithCompletionHandler:(nullable void (^)(BOOL success))handler;

/** Is encryption enabled for this account on this device
 
 This method checks whether encryption is enable for this account and whether the certificates are installed correctly.
 Returning YES means, the user is ready for encryption on this device.
 
 @return YES encryption is enabled, NO else.
 */
-(BOOL) encryptionEnabled;

/** Is encryption enabled for this account
 
 This method checks whether encryption is generally enabled for this user.
 This might have been done on a different device. In case encryptionEnabledForAccount returns YES and
 encryptionEnabled return NO, the keypair has to be transferred from the remote device.
 
 @return YES encryption is enabled, NO else.
 */
-(BOOL) encryptionEnabledForAccount;

/** Is encryption enabled for target user
 
 This method checks whether a message can be encrypted for a specific target user.
 
 @return YES encryption is enabled, NO else.
 */
-(BOOL) canEncryptMessageForTarget:(nonnull NSString *) targetUserid;

/** Is the local certificate valid for this account

 The Public/Private Key-Pair might have been changed on another device for this account
 
 @return YES valid, NO else.
*/
-(BOOL) validateCertificateForAccount;

/** Create a new VoIP, Video, Text Chat Group
    
 This method creates a new group with a group name, and array of userids of group members.
 It calls the complete handler when the creation has been completed.
 
 SampleCode:
 
    #import <SocialCommunication/UIViewController+SCCustomViewController.h>
    ...
    -(IBAction)createGroup:(id)sender
    {
        [[C2CallPhone currentPhone] createGroup:@"That's my Simple Group" 
                                    withMembers:[NSArray arrayWithObjects:@"ebb4fe4a13fe7c0fd51", @"56489fa913fe7c49497", nil] 
                                    withCompletionHandler:^(BOOL success, NSString *groupId, NSString *result) {
            
            if (success) {
                [self showGroupDetailForGroupid:groupId];
            }
        }];
    }

 
 @param groupName - Name of the Group
 @param members - Array of userids of group members. The current active user will be automatically added.
 @param handler - The completion handler. Will be called with a success parameter the groupid and a result string.

 */
-(void) createGroup:(nonnull NSString *) groupName withMembers:(nonnull NSArray *) members withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable groupId, NSString * _Nullable result))handler;

/** Create a CallMe Link for the specified group
 
 This allows Anonymous Users to participate on a group call via browser based CallMe Link
 
 A dictionary with the following keys will be returned:
 
    LinkId - The Link Id for the CallMe Link
    CallLink - The URL for the Link
 
 @param groupid - groupid for the group
 @return NSDictionary
 */
-(nullable NSDictionary *) createGroupLinkForGroup:(nonnull NSString *) groupid;

/** Enable Group Encryption 
 
 This is a restricted API for Enterprise Developers only.
 End-to-End Group Encryption uses 2048-Bit Public/Private Key encryption in order to privately share messages and attachemens between group members.
 Only the group members are able to decrypt messages and attachements. Attachments and messages are stored encrypted on the servers and will be automatically decrypted on the group members device.
 Group encrytion requires every group member to enable encryption for his account, as group private key information will be distributed individually encrypted with the group members personal public key.
 
 enableEncyptionForGroup generates the public/private key pair for the group and distribute the keys to the group members who have encryption enabled.
 As result, a list of encryptedMembers userids will be returned, so that the group admin can check whether all members can participate on encrypted communication and may notifiy the remaining group members to enable 
 encryption for their account.
 
 In case, some group members will enable their encryption after group encrytion has been enabled, refreshKeysForGroup must be called in order to re-distribute the public/private key-pair to the remaining group members.
 
 @param groupid - Group which is supposed to be enabled for encryption
 @param handler - completion handler, will be called after public/private key-pair has been created and distributed to the members. encryptedMembers contains a list of members ready for encrypted communication.
 
 @return YES - encrytion will be enabled, completion handler will be called. NO - group encryption cannot be enabled, the completion handler will not be called.
 */
-(BOOL) enableEncryptionForGroup:(nonnull NSString *) groupid withCompletionHandler:(nullable void (^)(BOOL success, NSSet * _Nullable encryptedMembers))handler;

/** Re-distribute public/private key-pair to the group members
 
 In case new members have been added to an encrypted group or some group members have just enabled their encrytion, the key-pair must be re-distributed.
 The completion handler will be called on success with a new list of encryption ready group members.
 
 @param groupid - The group
 @param handler - completion handler, will be called after public/private key-pair has been cre-distributed to the members. encryptedMembers contains a list of members ready for encrypted communication.
 
 @return YES - keys will be re-distributed, completion handler will be called. NO - error, the completion handler will not be called.
 
 */
-(BOOL) refreshKeysForGroup:(nonnull NSString *) groupid withCompletionHandler:(nullable void (^)(BOOL didUpdate, NSSet * _Nullable encryptedMembers))handler;

/** List of encryption enabled group members
 
 List of group members, ready to received encrypted group messages.
 
 @param groupid - The group
 
 @return List of userids
 */
-(nullable NSSet *) encryptionEnabledGroupMembersForGroup:(nonnull NSString *) groupid;

/** Encryption Status of a Group
 
 @param groupid - The group
 @return YES - Encryption enabled for Group / NO - Encrytion dis-abled for group
 */
-(BOOL) encryptedGroup:(nonnull NSString*) groupid;

/** Dis-able group encryption
 
 The public/private key-pair will be removed.
 
 @param groupid - The group
 @param handler - completion handler, will be called after public/private key-pair has been removed.
 
 @return YES - remove key-pair, completion handler will be called. NO - error, the completion handler will not be called.
 
 */
-(BOOL) disableEncryptionForGroup:(nonnull NSString *) groupid withCompletionHandler:(nullable void (^)(BOOL success))handler;

/** Import Public/Private Keypair from QR-Code Scan
 
 SCQRCertExportController presents a QR Code from the Public/Private Key-Pair, which can be imported using this method.
 
 @param keypair - resulting QR-Code String to import
 
 @return YES - Key-Pair successfully imported
 
 */
-(BOOL) importKeyPairFromQRCode:(nonnull NSString *) keypair;

/** Get a QR-Code Image from the current public/private key-pair.
 
 @param dimensions - Size of the QR-Code image
 @return The QR-Code image or nil if no key are available.
 
 */
-(nullable UIImage *) exportQRCodeFromKeyPairWithDimensions:(int) dimensions;


/**---------------------------------------------------------------------------------------
 * @name Message Functions
 *  ---------------------------------------------------------------------------------------
 */
/** Submits an instant message.
 
 Every C2Call user can be addressed by his email address or his C2Call UserId.
 An instant message will be either delivered via SIP message to the receiver while the application is in foregound
 or via Push Notification while the app is in background.
 
    [[C2CallPhone currentPhone] submitMessage:@"This is a message" toUser:@"max.muster@registeredemail.com"];
 
 To access user data, please see also SCDataManager class.
 
 @param message - The message
 @param target - C2Call Userid or email address
 */
-(void) submitMessage:(nonnull NSString *) message toUser:(nonnull NSString *) target;

/** Is secure messaging available for target user
 
 This method checks whether the public key for the target user is available for encryption of text messages or attachments to that user.
 
 @param userid - userid of the target user
 
 @return YES - message can be sent encrypted, NO otherwise
 */
-(BOOL) canSubmitEncryptedToUser:(nonnull NSString *) userid;

/** Submits an SMS/Text message.
 
 Sending an SMS/Text message will be charged to the user credit according to our pricelist.
 SMS/Text messages are 160 characters or 70 2-Byte characters. Longer messages will be automatically split into multiple SMS and charged accordingly.
 In of mixing 1-Byte character and 2-Bytes character in a message, you have only 70 characters per messages even it contains only one 2-Byte character.
 Sending SMS/Text messages into the USA requires a C2Call DID-Number.
 
 [[C2CallPhone currentPhone] submitMessage:@"This is a message" toNumber:@"+14081234567"];
 
 The number should typically start with the + and the international country code followed by the area code without leading "0" and then the number (e.g. +14081234567).
 If the submitted number is not in international format, the function automatically tries to convert the number into international format automatically, based on the users country settings.
 To access user data, please see also SCDataManager class.
 
 @param message - The message
 @param number - Receiver number in international format
 */
-(void) submitMessage:(nonnull NSString *) message toNumber:(nonnull NSString *) number;

// Rich Media Message Functions
/**---------------------------------------------------------------------------------------
 * @name Rich Media Message Functions
 *  ---------------------------------------------------------------------------------------
 */
/** Submits a video to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userId or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file. 
 The current methods submitVideo:withMessage:toTarget:withCompletionHandler uses an existing video referenced by an NSURL, convert it into the internally supported media format and stores it into the internal media store.
 After this steps are completed, it will call submitRichMessage:message:toTarget with the generated rich media key , the given message and target
 and finally calls the completionHandler with the rich media key, success or error status.
 NOTE: Video messages can also be send as SMS/Text message to a mobile phone number. In this case, the receiver will get a text message with an embedded short URL to see the rich media item in the mobile browser.
 
 @param mediaUrl - An NSURL to the actual video file
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param handler - The completion handler called after submitting the message.
 
 */
-(void) submitVideo:(nonnull NSURL *) mediaUrl withMessage:(nullable NSString *) message toTarget:(nonnull NSString *) target withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error))handler;

/** Submits an image to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current methods submitImage:withQuality:andMessage:toTarget:withCompletionHandler uses an existing image referenced by an UIImage, converts it into the internally supported media format and stores it into the internal media store.
 After this steps are completed, it will call submitRichMessage:message:toTarget with the generated rich media key , the given message and target
 and finally calls the completionHandler with the rich media key, success or error status.
 NOTE: Image messages can be also send as SMS/Text message to a mobile phone number. In this case, the receiver will get a text message with an embedded short URL to see the rich media item in the mobile browser.
 
 @param originalImage - The UIImage to be submitted.
 @param imageQuality - The imageQuality (UIImagePickerControllerQualityType is supported here). Images with higher resolutions will be scaled down.
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param handler - The completion handler called after submitting the message.
 
 */
-(void) submitImage:(nonnull UIImage *) originalImage withQuality:(UIImagePickerControllerQualityType) imageQuality andMessage:(nullable NSString *) message toTarget:(nonnull NSString *) target withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable richMediaKey , NSError * _Nullable error))handler;

/** Submits an audio file to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current methods submitAudio:withMessage:toTarget:withCompletionHandler uses an existing audio file referenced by an NSURL and stores it in the internal media store. No audio file conversion will be done. Support Audio Formats are the same as for the AVAudioPlayer.
 After this steps are completed, it will call submitRichMessage:message:toTarget with the generated rich media key , the given message and target
 and finally calls the completionHandler with the rich media key, success or error status.
 NOTE: Audio messages can be also send as SMS/Text message to a mobile phone number. In this case, the receiver will get a text message with an embedded short URL to see the rich media item in the mobile browser.

 @param mediaUrl - An NSURL to the actual audio file.
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param handler - The completion handler called after submitting the message.
 
 */
-(void) submitAudio:(nonnull NSURL *) mediaUrl withMessage:(nullable NSString *) message toTarget:(nonnull NSString *) target withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error))handler;

/** Submits an file to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current methods submitAudio:withMessage:toTarget:withCompletionHandler uses an existing audio file referenced by an NSURL and stores it into the internal media store. No audio file conversion will be done. Support Audio Formats are the same as for the AVAudioPlayer.
 After this steps are completed, it will call submitRichMessage:message:toTarget with the generated rich media key , the given message and target
 and finally calls the completionHandler with the rich media key, success or error status.
 NOTE: Audio messages can be also send as SMS/Text message to a mobile phone number. In this case, the receiver will get a text message with an embedded short URL to see the rich media item in the mobile browser.
 
 @param mediaUrl - An NSURL to the actual audio file.
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param handler - The completion handler called after submitting the message.
 
 */
-(void) submitFile:(nonnull NSURL *) fileUrl withMessage:(nullable NSString *) message toTarget:(nonnull NSString *) target withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error))handler;

/** Submits a VCARD file to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current method submitVCard:withMessage:toTarget:withCompletionHandler uses an ABRecordRef contact from ABAddressbook, generate the VCARD File from that contact stores it into the internal media store.
 After this steps are completed, it will call submitRichMessage:message:toTarget with the generated rich media key , the given message and target
 and finally calls the completionHandler with the rich media key, success or error status.
 NOTE: VCARDs are not supported as SMS/Text message
 
 @param person - A person record from ABAddressbook
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param handler - The completion handler called after submitting the message.
 
 */
-(void) submitVCard:(nonnull ABRecordRef) person withMessage:(nullable NSString *) message toTarget:(nonnull NSString *) target withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error))handler;

/** Submits a Friend Contact to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current method submitFriend:withMessage:toTarget:withCompletionHandler can be used to submit an existing and connected Friend Contact to another registered user, in order to connect each other. The method will check whether the given userid or email is existing in the current users friendlist and create a rich media key from the Friend Contact.
 After this steps are completed, it will call submitRichMessage:message:toTarget with the generated rich media key , the given message and target
 and finally calls the completionHandler with the rich media key, success or error status.
 NOTE: Friends Contacts are not supported as SMS/Text message
 
 @param useridOrEMail - The userid or email address of a connected Friend
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param handler - The completion handler called after submitting the message.
 
 */
-(void) submitFriend:(nonnull NSString *) useridOrEMail withMessage:(nullable NSString *) message toTarget:(nonnull NSString *) target withCompletionHandler:(nullable void (^)(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error))handler;

/** Submits a Rich Media Message to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current method submitRichMessage:withMessage:toTarget:withCompletionHandler can be used to submit an existing and connected Friend Contact to another registered user, in order to connect each other. The method will check whether the given userid or email is existing in the current users friendlist and create a rich media key from the Friend Contact.
 After this steps are completed, it will call submitRichMessage:message:toTarget will transfer the rich media file, refrenced by the rich media key to the server and the sends an instant message or SMS/Text message with the given message and rich message key refrence to the target address.
 NOTE: Not all types of rich media messages are supported for SMS/Text Messages. 
 
 @param richMessageKey - rich message key of the media file
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer

 @return success / failure
 
 */
-(BOOL) submitRichMessage:(nonnull NSString *) richMessageKey message:(nullable NSString *) messageText toTarget:(nonnull NSString *) target;

/** Submits a Rich Media Message to a registered user.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 The current method submitRichMessage:withMessage:toTarget:withCompletionHandler can be used to submit an existing and connected Friend Contact to another registered user, in order to connect each other. The method will check whether the given userid or email is existing in the current users friendlist and create a rich media key from the Friend Contact.
 After this steps are completed, it will call submitRichMessage:message:toTarget will transfer the rich media file, refrenced by the rich media key to the server and the sends an instant message or SMS/Text message with the given message and rich message key refrence to the target address.
 NOTE: Not all types of rich media messages are supported for SMS/Text Messages.
 
 @param richMessageKey - rich message key of the media file
 @param message - An additional text message (may be nil)
 @param target - An email address, userid or phone numer
 @param sendEncrypted - If the target user has encrytion enabled and a public key is available, the message will be encrypted with the public key on YES
 
 @return success / failure
 
 */
-(BOOL) submitRichMessage:(nonnull NSString *) richMessageKey message:(nullable NSString *) messageText toTarget:(nonnull NSString *) target preferEncrytion:(BOOL)sendEncrypted;

/** Share a Rich Media Message on facebook.
 
 In case the user has logged in via facebook, a rich media message of type text, image, video and location can be 
 shared on facebook.
 
 @param message - The message text
 @param richMediaKey - The rich media attachment
 @return YES - Message has been shared / NO - No facebook login or wrong attachment
*/
-(BOOL) shareMessageOnFacebook:(nonnull NSString *) message usingAttachment:(nullable NSString *) mediaKey;

// Rich Media Object Functions
/**---------------------------------------------------------------------------------------
 * @name Rich Media Object Functions
 *  ---------------------------------------------------------------------------------------
 */

/** Downloads a rich media object from the server.
 
 The Rich Media Message methods are submitting rich media files like photos, videos, voicemails, vcards or other files to a registered userid or email address.
 Rich Media Messages will be internally referenced as rich media key, which is an URL like reference to the actual rich media file.
 While the app typically receives messages via SIP Instant Message or Apple Push Notification, the actual media file has to be downloaded asynchronusly from the server.
 The method retrieveObjectForKey:completion: will download the actual media file and calls the completion handler after downloading the object.
 The download progress will be additionally posted as NSNotification in the following form:
 
    [NSNotificationCenter defaultCenter] postNotificationName:richMessageKey object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:percent] forKey:@"progress"]];
 
 So, in case you want to show the download progress to the user, just register for the notification event and show the progress accordingly.
 
 @param key - rich message key of the media file
 @param completion - Completion Handler, once the file download is completed.
 
 @return success / failure
 
 */
-(BOOL) retrieveObjectForKey:(nonnull NSString *)key completion:(nullable void (^)(BOOL finished))completion;

/** Upload rich media object to server
 
 Upload a locally stored rich media object to the server.
 
 @param url - Local file url
 @param prefix - Name prefix
 @param completion - Completion handler when the upload job is done
 @return YES - Uploading / NO - Upload failed completion handler will not be called
 */
-(BOOL) uploadFileObjectWithUrl:(nonnull NSURL *) url withPrefix:(nullable NSString *) prefix completion:(nullable void (^)(BOOL finished, NSString * _Nullable mediaKey, NSError * _Nullable error ))handler;

/** Import rich media file object into media files directories
 
 Import a locally stored rich media file object into media files directory.
 
 @param url - Local file url
 @param prefix - Name prefix
 @param error - Error if not null
 @return MediaKey of imported object
 */
-(nullable NSString *) importFileObject:(nonnull NSURL *) url withPrefix:(nullable NSString *) prefix error:( NSError * _Nullable * _Nullable) error;

/** Upload rich media file object to server
 
 Upload a locally stored rich media object to the server.
 
 @param mediaKey - MediaKey of the local available file object
 @param completion - Completion handler when the upload job is done
 @return YES - Uploading / NO - Upload failed completion handler will not be called
 */
-(BOOL) uploadFileObjectForKey:(nonnull NSString  *) mediaKey completion:(nullable void (^)(BOOL finished)) handler;

/** Retrieve remote size of object
 
 @param key - rich message key of the media file
 
 @return >= 0 : Size of object < 0 : Object not available
 */

-(int) remoteSizeForKey:(nonnull NSString *) key;

/** Check whether a rich media file for a given rich media key is locally available on the device.
 
 @param key - rich message key of the media file
 
 @return YES - Available / NO - Not available (use retrieveObjectForKey:completion:)
 
 */
-(BOOL) hasObjectForKey:(nonnull NSString *) key;

/** Check whether a rich media file for a given rich media key is currently downloading.
 
 @param key - rich message key of the media file
 
 @return YES - Download in progress / NO - No Download
 
 */
-(BOOL) downloadStatusForKey:(nonnull NSString *) key;

/** Check whether a download of a rich media file for a given rich media key has failed.
 
 @param key - rich message key of the media file
 
 @return YES - Last download failed / NO
 
 */
-(BOOL) failedDownloadStatusForKey:(nonnull NSString *) key;

/** UIImage for a given rich media key.
 
 @param key - rich message key of the media file
 
 @return Referenced Image
 
 */
-(nullable UIImage *) imageForKey:(nonnull NSString *) key;

/** Gets the user image for a given userId.
 
 To get a user image, the user must be a confirmed friend.
 
 @param userid of the user (friend)
 
 @return Referenced Image
 
 */
-(nullable UIImage *) userimageForUserid:(nonnull NSString *) userid;

/** Gets the larger user image for a given userId.
 
 To get a user image, the user must be a confirmed friend.
 Returns the larger image if available.
 
 @param userid of the user (friend)
 
 @return Referenced Image
 
 */
-(nullable UIImage *) largeUserImageForUserid:(nonnull NSString *) userid;


/** NSURL for a given rich media key.
 
 @param key - rich message key of the media file
 
 @return Referenced Url
 
 */
-(nullable NSURL *) mediaUrlForKey:(nonnull NSString *) key;

/** Local file system path for rich media key
 
 @param key - rich message key of the media file
 
 @return Referenced Path
 
 */
-(nullable NSString *) pathForKey:(nonnull NSString *) key;

/** Return the duration for a media object if available.
 
 Duration is available for video and audio files
 
 @param key - rich message key of the media file
 
 @return duration as string
 
 */
-(nullable NSString *) durationForKey:(nonnull NSString *) key;

/** Return the meta data for a media object if available
 
 Meta data is available for documents and contains the original file name and possibly further information.
 
 @param key - rich message key of the media file
 
 @return duration as string
 
 */
-(nullable NSDictionary *) metaInfoForKey:(nonnull NSString *) key;


/** Return the mime type for a given mediakey
 
 @param key - rich message key of the media file
 
 @return mimetype
 
 */
-(nullable NSString *) contentTypeForKey:(nonnull NSString *) mediaKey;


/** Return the file name for a given media key
 
 @param key - rich message key of the media file
 
 @return filename
 
 */
-(nullable NSString *) nameForKey:(nonnull NSString *) mediaKey;

/** Thumbnail Image for a given rich media key.
 
 The system automatically creates thumbnails from video and picture messages. 
 
 @param key - rich message key of the media file
 
 @return Thumbnail Image
 
 */
-(nullable UIImage *) thumbnailForKey:(nonnull NSString *) key;

/** Helper Function to discover the media type of an incoming message.
 
 A message can always be a regular text message or a rich media key. 
 This method can help to differentiate between the following media types:
 
    - SCMEDIATYPE_TEXT
    - SCMEDIATYPE_IMAGE
    - SCMEDIATYPE_USERIMAGE
    - SCMEDIATYPE_VIDEO
    - SCMEDIATYPE_VOICEMAIL
    - SCMEDIATYPE_FILE
    - SCMEDIATYPE_VCARD
    - SCMEDIATYPE_FRIEND
    - SCMEDIATYPE_LOCATION
 
 @param key - rich message key of the media file
 
 @return SCRichMediaType
 
 */
-(SCRichMediaType) mediaTypeForKey:(nonnull NSString *) key;

/** Save an image or video to photo album.
 
 
 @param mediaKey - rich message key of the media file
 @param handler - completion handler which will be called after the media object has been stored.
 
 @return YES: OK / NO: Invalid Media Object
 
 */
-(BOOL) saveToAlbum:(nonnull NSString *) mediaKey withCompletionHandler:(nullable void (^)(NSURL * _Nullable assetURL, NSError * _Nullable error)) handler;

// Friend Finder
/**---------------------------------------------------------------------------------------
 * @name Friend Finder
 *  ---------------------------------------------------------------------------------------
 */
/** Find a friend and add the friend to the users friendlist.
 
 The C2Call SDK provides different visibility levels for users inside the C2Call user database. 
 
    1. Global (All FriendCaller users)
    2. Affiliate (All users from apps of the same developer account)
    3. App local (Only users registered by this App)
 
 Based on the visibility level chosen by the app (in the developer portal), this method tries to find the given phone number or email address in the user database and add the user to the friend list. 
 The friend finder operates in the background asynchronously. The App will be notified if new friends are added.
 
 @param numberOrEMailAddress - phone number (international format) or email address
 */
-(void) findFriend:(nonnull NSString *) numberOrEMailAddress;

/** Find a list of friends and add found friends to the users friendlist.
 
 The C2Call SDK provides different visibility levels for users inside the C2Call user database.
 
 1. Global (All FriendCaller users)
 2. Affiliate (All users from apps of the same developer account)
 3. App local (Only users registered by this App)
 
 Based on the visibility level chosen by the app (in the developer portal), this method tries to find the given phone number or email address in the user database and add the user to the friend list.
 The friend finder operates in the background asynchronously. The App will be notified if new friends are added.
 
 @param listOfNumberOrEMailAddresses - an array of phone numbers (international format) or email addresses
 */
-(void) findFriends:(nonnull NSArray *) listOfNumberOrEMailAddresses;

/** Reload the friendlist from server
 */
-(void) reloadFriendList;

/** Reload the Message History from Server
 */
-(void) reloadMessageHistory;

/** Load the Group History from Server
 
 If a user joins a group, he will not automatically receive the group message history for that group, only new messages after he joined will be presented.
 Older messages needs to be explicitely retrieved. This method retrieves the messages of the past 7 days.
 
 @param groupid - Groupid of the group
 */
-(void) loadGroupHistory:(nonnull NSString *) groupid;

/** Load the Group History from Server for days
 
 If a user joins a group, he will not automatically receive the group message history for that group, only new messages after he joined will be presented.
 Older messages needs to be explicitely retrieved. This method retrieves the messages of the past "number of days" days.
 
 @param groupid - Groupid of the group
 @param days - Number of days to retrieve the group messages for.
 */
-(void) loadGroupHistory:(nonnull NSString *) groupid forDays:(int) days;

/** Reload the Call History from Server
 */
-(void) reloadCallHistory;

/** Get public user information for non-friend users.
 
 Some applications may not maintain explicit friend connections between communication partners
 However, additional user information beyond email address and userid might be necessary.
 getUserInfoForUserid will query those information from the server without being connected as friends
 
 The information will be returned as dictionary with the following elements:
 
 
    Firstname       - The users firstname
    Lastname        - The users name
    Email           - The users email address
    Userid          - The users userid
    Status          - The status of the user
    Language        - The users language setting
    ImageLarge      - The user image as large image (as media key)
    ImageSamll      - The user image as small image (as media key)
    Country         - The users country

 @param userid - The userid of the user
 @return The user information as dictionary
 
 */
-(nullable NSDictionary *) getUserInfoForUserid:(nonnull NSString *) userid;

/** Transfers the iOS address book to automatically find friends.
 
 The C2Call SDK provides different visibility levels for users inside the C2Call user database.
 
 1. Global (All FriendCaller users)
 2. Affiliate (All users from apps of the same developer account)
 3. App local (Only users registered by this App)
 
 Based on the visibility level chosen by the App (in the developer portal), this method tries to find friends by automatically transferring email address and phone numbers from the iOS address book in a hashed format (no real phone number and email addressed will be transferred).
 The friend finder operates in the background asynchronously. The App will be notified if new friends are found and added to the friend list.
 
 @param force - NO means the address book will be only transferred in case of changes since last transfer / YES - force the address book transfer 
 */
-(void) transferAddressBook:(BOOL) force;

// Manage Manual Invites with Confirm
/**---------------------------------------------------------------------------------------
 * @name Manage Manual Invites with Confirm
 *  ---------------------------------------------------------------------------------------
 */

/** Request a connection to an existing user via email address

 Request a friend connection it an existing user.
 The user must confirm this connection request using method 
 confirmInviteForId:
 
 @param email - email address
 @param comment - Optional comment
 */
-(BOOL) addInviteForEmail:(nonnull NSString *) email comment:(nullable NSString *) comment;

/** List invitations to connect
 
 The method return an array of dictionaries with open invitations
 This invitations must be confirmed, revoked or blocked
 
 Dictionary Values:
    id - The id for confirm, revoke, block
    InvitedUserid - Userid of the invited user (the current active user)
    ByUserid - Userid of the inviting user
    TStamp - TimeStamp in MS since 1970 UTC
    comment - Optional comment for this invite
 
 
 @return Array of Dictionaries
 */
-(nullable NSArray *) listOpenInvitations;

/** List my own invite requests
 
 The method return an array of dictionaries with open/unconfirmed invitations
 This invitations can revoked id not longer valid
 
 Dictionary Values:
 id - The id for confirm, revoke, block
 InvitedUserid - Userid of the invited user (the current active user)
 ByUserid - Userid of the inviting user
 TStamp - TimeStamp in MS since 1970 UTC
 comment - Optional comment for this invite
 
 
 @return Array of Dictionaries
 */
-(nullable NSArray *) listRequestedInvitations;

/** Confirm open Invite
 
 Use the "id" value from listOpenInvitations to confirm the invite
 
 @param id  - ID of the open invitation
 @return YES - success
 */
-(BOOL) confirmInviteForId:(int) idnum;

/** Revoke/Reject open/pending Invite
 
 Use the "id" value from listOpenInvitations or
 listRequestedInvitations to revoke the invite
 
 @param id  - ID of the open invitation
 @return YES - success
 */
-(BOOL) revokeInviteForId:(int) idnum;

/** Block open/pending Invite
 
 Use the "id" value from listOpenInvitations or
 listRequestedInvitations to block the invite
 
 @param id  - ID of the open invitation
 @return YES - success
 */
-(BOOL) blockInviteForId:(int) idnum;


// Manage User Credits
/**---------------------------------------------------------------------------------------
 * @name Manage User Credits
 *  ---------------------------------------------------------------------------------------
 */

/** Query Price Information for a specific number
 
 The price information will be queried ansychronously 
 Please register an NSNofication observer for @"PriceInfoEvent"
 
 @param number - Phone number in international format
 @param isSMS - YES : Query the prices for sending SMS / NO : query the price for phone calls
 */

-(void) queryPriceForNumber:(nonnull NSString *) number isSMS:(BOOL) isSMS;


/** Adds Credit to the users account to use paid services like PSTN calls or SMS/Text messages.
 
 For all paid services inside C2Call SDK, the application user is required having credit on his account, as all paid transactions will be directly charged to the App user account.
 The App developer might implement Apple InApp Purchase or other payment methods in his application. Once the payment is done by the App user, this method 
 addCredit:currency:transactionid:receipt: can be used to top up the App users account with the requested credit.

 The App developer requires having enough credit on his developer account in order to process the transaction, as the amount of credit will be deducted from the developer account and added to the user account. 
 In case of an InApp Purchase transaction, the receipt from that transaction can be provided as parameter and will be automatically validated with the Apple payment servers in order to prevent any InApp Purchase fraud.
 
 @param valueInCent - Cent value to add to the users pre-paid account
 @param currency - EUR / USD
 @param tid - Unique Transaction id, either from Apple InApp purchase or from other payment mothods
 @param receipt - Receipt from Apple InApp Purchase or nil
 
 */
-(BOOL) addCredit:(nonnull NSString *)valueInCent currency:(nonnull NSString *) currency transactionid:(nonnull NSString *) tid receipt:(nullable NSData *) receipt;

/** Request Braintree Client Token
    
    Support for Braintree Payment. Enterprise Customer only.
 
    @return client token
 */
-(nullable NSString *) requestBTClientToken;

/** Add Credit using Braintree Payment 
 
 Support for Braintree Payment. Enterprise Customer only.

 @param value - Payment Amount as decimal value (10.00)
 @param currency - Currency
 @param nonce - Payment Nonce created by Braintree
 @param channel - Purchase Channel
 
 @return NSDictionary with transaction result
 */
-(nullable NSDictionary *) addBrainTreeCredit:(nonnull NSString *)value currency:(nonnull NSString *)currency nonce:(nonnull NSString *) nonce channel:(nonnull NSString *) channel;


/** Get C2Call credits for the current user
 
 C2Call SDK supports different types of credits for users.
 - C2Call (user) credits to charge the user for calls and SMS into mobile phone and pstn networks
 - Application credits - to charge the user for application internal services.
 
 getUserCredits returns a dictionary with the following keys:
 
 CreditValue - NSNumber with the actual credit value (double)
 Currency - The currency for the credit value
 CreditString - The localized string representation of the credit value and currency
 
 User credits are typically updated automatically in the background during a call or when sending an SMS.
 Use force to retrieve the current value from the server.
 
 @param forceRefresh - Force requesting the current credits from the server
 @return The credit dictionary or nil if no application credit is available.
 */
-(nullable NSDictionary *) getUserCredits:(BOOL) forceRefresh;

/** Get application credits for the current user
 
 C2Call SDK supports different types of credits for users.
 - C2Call credits to charge the user for calls and SMS into mobile phone and pstn networks
 - Application credits - to charge the user for application internal services. 
 
 The Application credits are completely under control of the application developer and be freely added
 to the users account and charge accordingly for internal application services.
 
 getApplicationCredits returns a dictionary with the following keys:
 
    CreditValue - NSNumber with the actual credit value (double)
    Currency - The currency for the credit value
    CreditString - The localized string representation of the credit value and currency
 
 @return The credit dictionary or nil if no application credit is available.
 */
-(nullable NSDictionary *) getApplicationCredits;

/** Redeem a voucher for C2Call Credit

 Voucher Codes for different credit values can be provided by C2Call.
 
 @param voucher - Voucher Code to redeem
 @return YES - success / NO - failure
 */
-(BOOL) redeemVoucher:(nonnull NSString *) voucher;

/** Redeem a voucher for Application Credit
 
 Voucher Codes for different credit values can be provided by C2Call.
 
 @param voucher - Voucher Code to redeem
 @return YES - success / NO - failure
 */
-(BOOL) redeemApplicationVoucher:(nonnull NSString *) voucher;

/** Charge the user for a service provided by the Application
 
 The amount will be deducted from the users application credit.
 
 @param value - Amount to charge the user, 0.03 will charge 3 cents
 @param tid - Application definable transactionid, should be unique
 @return YES - success / NO - failure
 */
-(BOOL) chargeApplicationCredit:(double) value forTransactionId:(nonnull NSString *) tid;

/** Return the URL for C2Call Phone Number Service
 
 Get an US Phone number as virtual number 
 
 @return URL for C2Call Number service
 */
-(nullable NSString *) urlForC2CallNumber;

/**---------------------------------------------------------------------------------------
 * @name Enterprise Project Methods
 *  ---------------------------------------------------------------------------------------
 */

/** Return a smart dial number
 
 GencomAPI Smart Dial Number Service
 
 @param country - Country for Smart Dial Number
 @param number - Destination Number
 @param description - Description
 @return Number for Smart Dial Service
 */
-(nullable NSString *) getSmartDialNumber:(nonnull NSString *) country number:(nonnull NSString *) number description:(nonnull NSString *) description;

/** Request a Web Callback Service
 
 GencomAPI Web Callback Service
 
 @param number1 - First Number
 @param number2 - Second Number
 @return CallbackId of the WebCall. Use this to cancel a request
 */
-(nullable NSString *) requestWebCallbackForNumber:(nonnull NSString *) number1 number2:(nonnull NSString *) number2;

/** Cancel a Web Callback Service
 
 GencomAPI Web Callback Service
 
 @param callbackId - Id of the WebCall to cancel
 @return YES - succes / NO - error
 */

-(BOOL) cancelWebCallback:(nonnull NSString *) callbackId;

/** List of Countries for Smart Dial Access Numbers
 
 GencomAPI Countries for Access Numbers
 
 @return Array of Countries
 */
-(nullable NSArray *) getCountriesForAccessNumbers;

/** List of Tollfree AccessNumbers
 
 GencomAPI List of Tollfree AccessNumbers
 
 @return Dictionary of Country (key) / Access Number (value)
 */

-(nullable NSDictionary *) getTollfreeAccessNumbers;

/** List of Calling Plans available for User
 
 GencomAPI Calling Plans
 It returns an array of dictionaries for the available calling plans.
 The dictionary keys are:
 
    Name - CallingPlan Name
    MinutesLeft - Minutes left on this calling plan
    Status - Active / Not Active
 
 @return Array of Dictionaries
 */

-(nullable NSArray *) getCallingPlans;


/**---------------------------------------------------------------------------------------
 * @name Static Methods
 *  ---------------------------------------------------------------------------------------
 */
/** Gets the current C2CallPhone instance.
 
    Only one C2CallPhone instance is allowed.
 
 */

+(nullable C2CallPhone *) currentPhone;

/** Set the default country code
 The default country code will be used to convert a local number into international number format
 
 @param cc - The Country Code (e.g. "+1")
 */
+(void) setDefaultCountryCode:(nonnull NSString *)cc;

/** Set the default area code
 The default area code will be used to convert a local number into international number format
 
 @param ac - The Area Code (e.g. "408")
 */

+(void) setDefaultAreaCode:(nonnull NSString *)ac;

@end
