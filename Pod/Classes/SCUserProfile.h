//
//  SCUserProfile.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.05.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <Foundation/Foundation.h>

/** SCUserProfile class provides access to the current users profile.
 
 */
@interface SCUserProfile : NSObject

/** The users first and last name if both are available, else the available name.
 */
@property(nonatomic, readonly) NSString *displayname;

/** C2Call userid of the user.
 */
@property(nonatomic, readonly) NSString *userid;

/** The users registered email address.
 */
@property(nonatomic, readonly) NSString *email;

/** Current active DID Number, if available or nil.
 */
@property(nonatomic, readonly) NSString *didnumber;

/** The users callerid, if available or nil.
 */
@property(nonatomic, readonly) NSString *callerid;

/** Verification status of the users callerid.
 
 The callerId needs to be verified in order to use it in a outbound call or SMS/Text message.
 
 @see SCVerifyNumberController
 */
@property(nonatomic, readonly) BOOL isCalleridVerified;

/** The users current credit as readable string (e.g. $ 1.35 / 1,35 €).
 */
@property(nonatomic, readonly) NSString *credit;

/** The users status update time.
 */
@property(nonatomic, readonly) NSDate *userStatusDate;

/** The users profile image.
 */
@property(nonatomic, readonly) UIImage *userImage;

/** The users Firstname.
 */
@property(nonatomic, strong) NSString *firstname;

/** The users Lastname.
 */
@property(nonatomic, strong) NSString *lastname;

/** The users country.
 */
@property(nonatomic, strong) NSString *country;

/** The users status.
 */
@property(nonatomic, strong) NSString *userStatus;

/** The users work phone number.
 */
@property(nonatomic, strong) NSString *phoneWork;

/** The users home phone number.
 */
@property(nonatomic, strong) NSString *phoneHome;

/** The users mobile phone number.
 */
@property(nonatomic, strong) NSString *phoneMobile;

/** The users other phone number.
 */
@property(nonatomic, strong) NSString *phoneOther;


/** Is facebook login
 @return YES : User has logged-in via facebook / NO : Regular login
 */
-(BOOL) useFacebook;

/** Reload User Profile Data from Server (async operation)
 */
-(void) refreshUserProfile;

/** Reload User Credit Data from Server (async operation)
 */
-(void) refreshUserCredits;

/** Saves changes to the server.
 */
-(void) saveUserProfile;

/** Saves changes to the server.
 @param handler - Completion handler
 */
-(void) saveUserProfileWithCompletionHandler:(void (^)(BOOL success))handler;

/** Change the user image and upload the image to the server
 
 The completion handler will be called when the transfer has been completed and the user profile has been updated
 
 @param userImage - The new profile image
 @param completionHandler - completion handler to be called on completion
 */
-(void) setUserImage:(UIImage *)userImage withCompletionHandler:(void (^)(BOOL finished))completionHandler;

/** Set additional meta data for the user

 This method adds any kind of meta data to the user profile. 
 Declaring this meta data as public will allow to see this data 
 by any friend added to this user. MOC2CallUser.userdata property will allo access to this data from the friend list.
 Any changes to the user data requires to call saveUserProfile or saveUserProfileWithCompletionHandler in order to make the changes permanent.
 
 @param data - The actual metadata 
 @param key - The access key, must be unique
 @param isPublic - Allow access this data by a friends
 */
-(void) setUserdata:(NSString *) data forKey:(NSString *) key public:(BOOL) isPublic;

/** Access meta data from the user profile
 
 @param key - The access key
 @return The actual meta data
 */
-(NSString *) userdataForKey:(NSString *) key;

/** Remove a user data specified by key
 
 @param key - The access key
 */
-(void) removeUserdataForKey:(NSString *) key;


/** Get extended DID Numer
 
 In case the users has subscribed for multiuple DIDs, 
 access the DID with index (num) 0-5
 
 @param num - Index of the requested did
 @return DID number or nil
 */
-(NSString *) didNumberExt:(int)num;

/** Get available DIDs 
 
 This mothod returns the list of avilable (active) DIDs for this user.
 The return value is an array of NSDictionary with the following keys:
 
    DidNumber - The actual DID
    Index - The actual DID index to reference the DID for cancellation or renewal
 
 @return Array of DIDs

 */
-(NSArray *) activeDIDs;

/** Accesses to the current SCUserProfile instance.
 
 @return Current SCUserProfile instance
 */
+(SCUserProfile *) currentUser;

/** List of user status templates
 
 @return Array of NSString for default user status
 */
+(NSArray *) defaultUserStatusTemplates;


/** Save a list of user status templates
 
 @param items - Array of NSString for default user status
 */
+(void) setUserStatusTemplates:(NSArray *) templates;

@end
