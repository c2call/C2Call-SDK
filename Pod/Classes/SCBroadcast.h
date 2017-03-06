//
//  SCBroadcast.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14/05/16.
//
//

#import <Foundation/Foundation.h>

/** SCBroadcast class provides access to a specified broadcast group and allows to modify and save it.
 
 */

@interface SCBroadcast : NSObject

/** @name Properties */
/** The groupid of the broadcast */
@property(nonatomic, readonly) NSString *groupid;

/** The userid of the broadcast group owner*/
@property(nonatomic, readonly) NSString *groupOwner;

/** The broadcast group type  (BCG_PUBLIC, BCG_PRIVATE) */
@property(nonatomic, readonly) NSString *groupType;

/** The startDate of the broadcast group */
@property(nonatomic, readonly) NSDate *startDate;

/** The endDate of the broadcast group */
@property(nonatomic, readonly) NSDate *endDate;

/** The number of current onlineUsers of the broadcast group */
@property(nonatomic, readonly) NSInteger onlineUsers;

/** Is the current broadcast live */
@property(nonatomic, readonly) BOOL isLive;

/** Is the current broadcast featured */
@property(nonatomic, readonly) BOOL isFeatured;

/** The location latitude of the broadcast group */
@property(nonatomic, readonly) NSNumber *latitude;

/** The location longitude of the broadcast group */
@property(nonatomic, readonly) NSNumber *longitude;

/** The location name of the broadcast group */
@property(nonatomic, readonly) NSString *locationName;

/** The broadcast group name */
@property(nonatomic, strong)  NSString *groupName;

/** The broadcast group description */
@property(nonatomic, strong)  NSString *groupDescription;

/** The broadcast recorded media file */
@property(nonatomic, strong)  NSString *mediaUrl;

/** The Reward Option for this Broadcast */
@property(nonatomic, readonly) NSString *reward;

/** Tags for the current broadcast */
@property(nonatomic, readonly) NSArray *tags;


/** Instantiate the broadcast with groupid
 
 @param groupid - Groupid of the group
 @return SCGroup object
 */
- (instancetype)initWithBroadcastGroupid:(NSString *) groupid;

/** Instantiate the broadcast group with groupid
 
 @param groupid - Groupid of the broadcast group
 @param retrieve - YES - Force retrieval from Server, NO use local copy, retrieve from server if not available
 @return SCBroadcast object
 */
- (instancetype)initWithBroadcastGroupid:(NSString *) groupid retrieveFromServer:(BOOL) retrieve;

/** List of userids of broadcast group members
 
 @return Array of broadcast group members
 */
-(NSArray *) groupMembers;

/** Add a member to the group
 
 
 @param member - Userid of the new broadcast group member
 */
-(void) addGroupMember:(NSString *) member;

/** Remove a group member
 
 @param member - Userid of the broadcast group member to be removed
 */
-(void) removeMember:(NSString *) member;

/** Return the name of a group member
 
 A group member might not be in the friend list as the group member is not yet connected to the user.
 In this case addition information on a member cannot be retrieved via friendlist.
 Therefore firstname lastname and email address on each member is available via group meta info.
 
 @param member - userid of the group member
 @return Lastname of the group member if available
 */
-(NSString *) nameForGroupMember:(NSString *) member;

/** Return the firstname of a group member
 
 A group member might not be in the friend list as the group member is not yet connected to the user.
 In this case addition information on a member cannot be retrieved via friendlist.
 Therefore firstname lastname and email address on each member is available via group meta info.
 
 @param member - userid of the group member
 @return Firstname of the group member if available
 */
-(NSString *) firstnameForGroupMember:(NSString *) member;

/** Return the email address of a group member
 
 A group member might not be in the friend list as the group member is not yet connected to the user.
 In this case addition information on a member cannot be retrieved via friendlist.
 Therefore firstname lastname and email address on each member is available via group meta info.
 
 @param member - userid of the group member
 @return email address of the group member
 */
-(NSString *) emailForGroupMember:(NSString *) member;

/** Join this group
 
 The group must be a public group
 
 @return YES - The user is now member of this group
 */
-(BOOL) joinGroup;


/** Set additional meta data for the group
 
 This method adds any kind of meta data to the group.
 Declaring this meta data as public will allow to see this data
 by any member added to this group. MOC2CallUser.userdata property will allo access to this data from the friend list.
 Any changes to the user data requires to call saveGroup or saveUserGroupWithCompletionHandler in order to make the changes permanent.
 
 @param data - The actual metadata
 @param key - The access key, must be unique
 @param isPublic - Allow access this data by members
 */
-(void) setGroupdata:(NSString *) data forKey:(NSString *) key public:(BOOL) isPublic;

/** Access meta data from the group object
 
 @param key - The access key
 @return The actual meta data
 */
-(NSString *) groupdataForKey:(NSString *) key;


/** Remove a group data specified by key
 
 @param key - The access key
 */
-(void) removeGroupdataForKey:(NSString *) key;

/** Change the group image and upload the image to the server
 
 The completion handler will be called when the transfer has been completed and the group profile has been updated
 
 @param groupImage - The new profile image
 @param completionHandler - completion handler to be called on completion
 */

-(void) setGroupImage:(UIImage *)groupImage withCompletionHandler:(void (^)(BOOL finished))completionHandler;

/** Returns the group image if available
 
 @return The group image
 */
-(UIImage *) groupImage;


/** Saves changes to the server.
 */
-(void) saveBroadcast;

/** Saves changes to the server.
 @param handler - Completion handler
 */
-(void) saveBroadcastWithCompletionHandler:(void (^)(BOOL success))handler;


@end
