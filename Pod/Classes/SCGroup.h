//
//  SCGroup.h
//  C2CallPhone
//
//  Created by Michael Knecht on 25.02.14.
//
//

#import <Foundation/Foundation.h>

/** SCGroup class provides access to a specified group and allows to modify and save it.
 
 */

@interface SCGroup : NSObject

/** @name Properties */
/** The groupid of the group */
@property(nonatomic, readonly) NSString *groupid;

/** The userid of the group owner*/
@property(nonatomic, readonly) NSString *groupOwner;

/** The group name */
@property(nonatomic, strong)  NSString *groupName;

/** Instantiate the group with groupid
 
 @param groupid - Groupid of the group
 @return SCGroup object
 */
- (id)initWithGroupid:(NSString *) groupid;

/** List of userids of group members 
 
 @return Array of group members
 */
-(NSArray *) groupMembers;

/** Add a member to the group
 
 
 @param member - Userid of the new group member
 */
-(void) addGroupMember:(NSString *) member;

/** Remove a group member
 
 @param member - Userid of the group member to be removed
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

/** Make this group public to allow other users to joind this group
 
 A public group can be joind by every user and don't need to be added by the group owner
 
 @param public - YES the group will be public, NO - the group will be private
 */
-(void) makePublic:(BOOL) publicGroup;

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
-(void) saveGroup;

/** Saves changes to the server.
 @param handler - Completion handler
 */
-(void) saveGroupWithCompletionHandler:(void (^)(BOOL success))handler;

@end
