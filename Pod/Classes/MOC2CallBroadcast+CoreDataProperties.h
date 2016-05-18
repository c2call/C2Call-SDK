//
//  MOC2CallBroadcast+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOC2CallBroadcast.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOC2CallBroadcast (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *groupid;
@property (nullable, nonatomic, retain) NSString *groupName;
@property (nullable, nonatomic, retain) NSString *groupOwner;
@property (nullable, nonatomic, retain) NSString *groupDescription;
@property (nullable, nonatomic, retain) NSString *groupType;
@property (nullable, nonatomic, retain) NSString *groupImage;
@property (nullable, nonatomic, retain) NSNumber *groupImageTimestamp;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSString *mediaUrl;
@property (nullable, nonatomic, retain) NSNumber *onlineUsers;
@property (nullable, nonatomic, retain) NSNumber *live;
@property (nullable, nonatomic, retain) NSString *locationName;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) MOC2CallUser *broadcastUser;
@property (nullable, nonatomic, retain) NSSet<MOUserData *> *userData;
@property (nullable, nonatomic, retain) NSSet<MOGroupMember *> *members;

@end

@interface MOC2CallBroadcast (CoreDataGeneratedAccessors)

- (void)addUserDataObject:(MOUserData *)value;
- (void)removeUserDataObject:(MOUserData *)value;
- (void)addUserData:(NSSet<MOUserData *> *)values;
- (void)removeUserData:(NSSet<MOUserData *> *)values;

- (void)addMembersObject:(MOGroupMember *)value;
- (void)removeMembersObject:(MOGroupMember *)value;
- (void)addMembers:(NSSet<MOGroupMember *> *)values;
- (void)removeMembers:(NSSet<MOGroupMember *> *)values;

@end

NS_ASSUME_NONNULL_END
