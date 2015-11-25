//
//  SCFriendList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 13.08.13.
//
//


#import <Foundation/Foundation.h>
#import "MOC2CallUser.h"

/** SCFriendList base class provides access to the users friend list
 
 The SCFriendList is a conveniencs class using SCDataManager fetchRequestForFriendlist: 
 and fetchedResultsControllerWithFetchRequest:
 SCFriendList is a singleton instance and can be always accessed via [SCFriendList instance];
 
 You can register a handler for added friends, removed friends and updated friends.
 An online status update of a friend is also causing an update event.
 */
@interface SCFriendList : NSObject

/** Register a Block Handler for initialization completion
 
 The SCFriendList class is using core data, for accessing the friend list.
 Therefore the SCFriendList cannot provide any data, unless core data is initialized 
 correctly after user login or registration.
 This completion handler will be called when core data is initialized and the FriendList data is available
 
 
 @param handler - The handler being called on on initialization completion
 @return YES - Complete Handler is registered, NO - the data is already initialized and ready for access.
 */
-(BOOL) registerForInitializationCompletion:(void (^)(BOOL success, NSError *error)) handler;

/** Register a Block Handler if you want to be informed about new friends
 
 @param handler - The handler being called on new friends
 */
-(void) registerForAddedFriends:(void (^)(MOC2CallUser *user)) handler;

/** Register a Block Handler if you want to be informed about removed friends
 
 @param handler - The handler being called on removed friends
 */
-(void) registerForRemovedFriends:(void (^)(MOC2CallUser *user)) handler;

/** Register a Block Handler if you want to be informed about any update to a friend
 
 @param handler - The handler being called on updated friends
 */
-(void) registerForUpdatedFriends:(void (^)(MOC2CallUser *user)) handler;

/** Returns a list of email addresses of all friends
 */
-(NSArray *) listFriendsEmail;

/** Returns a list of userids of all friends
 */
-(NSArray *) listFriendsUserids;

/** Returns a list of NSDictionary info elements of all friends
 
 The dictionary contains the following keys:
 
    Firstname       - The friends firstname
    Lastname        - The friends name
    Email           - The friends email address
    Userid          - The friends userid
    OnlineStatus    - The friends OnlineStatus
    UserType        - The friends User Type (0 = normal friend, 2 = group)
    CallerId        - The friends phone number for calls
    DIDNumber       - The friends C2Call SDK Number
    NT_WORK         - The work phone number
    NT_MOBILE       - The mobile phone number
    NT_HOME         - The home phone number
    NT_OTHER        - Other phone number
 
 @return An array of NSDictionaries
 */
-(NSArray *) listFriendsInfo;


/** @name Static Methods */
/** Returns a shared instance of SCFriendList
 
 @return shared instance
 */
+(SCFriendList *) instance;

/** Destroys a shared instance and removed all handlers
 */
+(void) dispose;

@end
