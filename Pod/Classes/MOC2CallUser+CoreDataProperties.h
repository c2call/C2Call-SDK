//
//  MOC2CallUser+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOC2CallUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOC2CallUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *callmeLink;
@property (nullable, nonatomic, retain) NSNumber *confirmed;
@property (nullable, nonatomic, retain) NSString *confirmid;
@property (nullable, nonatomic, retain) NSString *contactid;
@property (nullable, nonatomic, retain) NSString *didNumber;
@property (nullable, nonatomic, retain) NSString *displayName;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSNumber *facebook;
@property (nullable, nonatomic, retain) NSNumber *favorite;
@property (nullable, nonatomic, retain) NSString *firstname;
@property (nullable, nonatomic, retain) NSString *friendComment;
@property (nullable, nonatomic, retain) NSString *friendEmail;
@property (nullable, nonatomic, retain) NSNumber *friendInvite;
@property (nullable, nonatomic, retain) NSString *indexAttribute;
@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) NSDate *lastActivity;
@property (nullable, nonatomic, retain) NSDate *lastOnlineDate;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *online;
@property (nullable, nonatomic, retain) NSNumber *onlineStatus;
@property (nullable, nonatomic, retain) NSString *ownNumber;
@property (nullable, nonatomic, retain) NSNumber *ownNumberVerified;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSDate *recentIndicationDate;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *userid;
@property (nullable, nonatomic, retain) NSString *userImage;
@property (nullable, nonatomic, retain) NSString *userImageDate;
@property (nullable, nonatomic, retain) NSNumber *userImageUpdate;
@property (nullable, nonatomic, retain) NSString *userStatus;
@property (nullable, nonatomic, retain) NSDate *userStatusDate;
@property (nullable, nonatomic, retain) NSNumber *userType;
@property (nullable, nonatomic, retain) MOAddress *contactAddress;
@property (nullable, nonatomic, retain) NSSet<MOPhoneNumber *> *contactNumbers;
@property (nullable, nonatomic, retain) NSSet<MODidNumber *> *didNumbers;
@property (nullable, nonatomic, retain) MOAddress *friendAddress;
@property (nullable, nonatomic, retain) NSSet<MOPhoneNumber *> *friendNumbers;
@property (nullable, nonatomic, retain) MOC2CallGroup *group;
@property (nullable, nonatomic, retain) NSSet<MOOpenId *> *openIds;
@property (nullable, nonatomic, retain) NSSet<MOUserData *> *userdata;
@property (nullable, nonatomic, retain) MOC2CallBroadcast *broadcast;

@end

@interface MOC2CallUser (CoreDataGeneratedAccessors)

- (void)addContactNumbersObject:(MOPhoneNumber *)value;
- (void)removeContactNumbersObject:(MOPhoneNumber *)value;
- (void)addContactNumbers:(NSSet<MOPhoneNumber *> *)values;
- (void)removeContactNumbers:(NSSet<MOPhoneNumber *> *)values;

- (void)addDidNumbersObject:(MODidNumber *)value;
- (void)removeDidNumbersObject:(MODidNumber *)value;
- (void)addDidNumbers:(NSSet<MODidNumber *> *)values;
- (void)removeDidNumbers:(NSSet<MODidNumber *> *)values;

- (void)addFriendNumbersObject:(MOPhoneNumber *)value;
- (void)removeFriendNumbersObject:(MOPhoneNumber *)value;
- (void)addFriendNumbers:(NSSet<MOPhoneNumber *> *)values;
- (void)removeFriendNumbers:(NSSet<MOPhoneNumber *> *)values;

- (void)addOpenIdsObject:(MOOpenId *)value;
- (void)removeOpenIdsObject:(MOOpenId *)value;
- (void)addOpenIds:(NSSet<MOOpenId *> *)values;
- (void)removeOpenIds:(NSSet<MOOpenId *> *)values;

- (void)addUserdataObject:(MOUserData *)value;
- (void)removeUserdataObject:(MOUserData *)value;
- (void)addUserdata:(NSSet<MOUserData *> *)values;
- (void)removeUserdata:(NSSet<MOUserData *> *)values;

@end

NS_ASSUME_NONNULL_END
