//
//  MOC2CallBroadcast+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.03.17.
//
//

#import "MOC2CallBroadcast+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MOC2CallBroadcast (CoreDataProperties)

+ (NSFetchRequest<MOC2CallBroadcast *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *endDate;
@property (nullable, nonatomic, copy) NSString *groupDescription;
@property (nullable, nonatomic, copy) NSString *groupid;
@property (nullable, nonatomic, copy) NSString *groupImage;
@property (nullable, nonatomic, copy) NSNumber *groupImageTimestamp;
@property (nullable, nonatomic, copy) NSString *groupName;
@property (nullable, nonatomic, copy) NSString *groupOwner;
@property (nullable, nonatomic, copy) NSString *groupType;
@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSNumber *live;
@property (nullable, nonatomic, copy) NSString *locationName;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSString *mediaUrl;
@property (nullable, nonatomic, copy) NSNumber *onlineUsers;
@property (nullable, nonatomic, copy) NSDate *startDate;
@property (nullable, nonatomic, copy) NSNumber *featured;
@property (nullable, nonatomic, copy) NSString *reward;
@property (nullable, nonatomic, retain) MOC2CallUser *broadcastUser;
@property (nullable, nonatomic, retain) NSSet<MOGroupMember *> *members;
@property (nullable, nonatomic, retain) NSSet<MOUserData *> *userData;
@property (nullable, nonatomic, retain) NSSet<MOTag *> *tags;

@end

@interface MOC2CallBroadcast (CoreDataGeneratedAccessors)

- (void)addMembersObject:(MOGroupMember *)value;
- (void)removeMembersObject:(MOGroupMember *)value;
- (void)addMembers:(NSSet<MOGroupMember *> *)values;
- (void)removeMembers:(NSSet<MOGroupMember *> *)values;

- (void)addUserDataObject:(MOUserData *)value;
- (void)removeUserDataObject:(MOUserData *)value;
- (void)addUserData:(NSSet<MOUserData *> *)values;
- (void)removeUserData:(NSSet<MOUserData *> *)values;

- (void)addTagsObject:(MOTag *)value;
- (void)removeTagsObject:(MOTag *)value;
- (void)addTags:(NSSet<MOTag *> *)values;
- (void)removeTags:(NSSet<MOTag *> *)values;

@end

NS_ASSUME_NONNULL_END
