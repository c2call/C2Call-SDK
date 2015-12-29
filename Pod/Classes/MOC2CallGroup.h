//
//  MOC2CallGroup.h
//  C2CallPhone
//
//  Created by Michael Knecht on 24.02.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallUser, MOGroupMember, MOUserData;

@interface MOC2CallGroup : NSManagedObject

@property (nonatomic, retain) NSString * groupid;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * groupOwner;
@property (nonatomic, retain) NSSet *groupMembers;
@property (nonatomic, retain) MOC2CallUser *groupUser;
@property (nonatomic, retain) NSSet *userdata;
@end

@interface MOC2CallGroup (CoreDataGeneratedAccessors)

- (void)addGroupMembersObject:(MOGroupMember *)value;
- (void)removeGroupMembersObject:(MOGroupMember *)value;
- (void)addGroupMembers:(NSSet *)values;
- (void)removeGroupMembers:(NSSet *)values;

- (void)addUserdataObject:(MOUserData *)value;
- (void)removeUserdataObject:(MOUserData *)value;
- (void)addUserdata:(NSSet *)values;
- (void)removeUserdata:(NSSet *)values;

@end
