//
//  MOC2CallUser.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.02.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOAddress, MOC2CallGroup, MODidNumber, MOOpenId, MOPhoneNumber, MOUserData;

@interface MOC2CallUser : NSManagedObject

@property (nonatomic, retain) NSNumber * callmeLink;
@property (nonatomic, retain) NSNumber * confirmed;
@property (nonatomic, retain) NSString * confirmid;
@property (nonatomic, retain) NSString * contactid;
@property (nonatomic, retain) NSString * didNumber;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * facebook;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * friendComment;
@property (nonatomic, retain) NSString * friendEmail;
@property (nonatomic, retain) NSNumber * friendInvite;
@property (nonatomic, retain) NSString * indexAttribute;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSDate * lastActivity;
@property (nonatomic, retain) NSDate * lastOnlineDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * online;
@property (nonatomic, retain) NSNumber * onlineStatus;
@property (nonatomic, retain) NSString * ownNumber;
@property (nonatomic, retain) NSNumber * ownNumberVerified;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSDate * recentIndicationDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * userImage;
@property (nonatomic, retain) NSString * userImageDate;
@property (nonatomic, retain) NSNumber * userImageUpdate;
@property (nonatomic, retain) NSString * userStatus;
@property (nonatomic, retain) NSDate * userStatusDate;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) MOAddress *contactAddress;
@property (nonatomic, retain) NSSet *contactNumbers;
@property (nonatomic, retain) MOAddress *friendAddress;
@property (nonatomic, retain) NSSet *friendNumbers;
@property (nonatomic, retain) MOC2CallGroup *group;
@property (nonatomic, retain) NSSet *openIds;
@property (nonatomic, retain) NSSet *userdata;
@property (nonatomic, retain) NSSet *didNumbers;
@end

@interface MOC2CallUser (CoreDataGeneratedAccessors)

- (void)addContactNumbersObject:(MOPhoneNumber *)value;
- (void)removeContactNumbersObject:(MOPhoneNumber *)value;
- (void)addContactNumbers:(NSSet *)values;
- (void)removeContactNumbers:(NSSet *)values;

- (void)addFriendNumbersObject:(MOPhoneNumber *)value;
- (void)removeFriendNumbersObject:(MOPhoneNumber *)value;
- (void)addFriendNumbers:(NSSet *)values;
- (void)removeFriendNumbers:(NSSet *)values;

- (void)addOpenIdsObject:(MOOpenId *)value;
- (void)removeOpenIdsObject:(MOOpenId *)value;
- (void)addOpenIds:(NSSet *)values;
- (void)removeOpenIds:(NSSet *)values;

- (void)addUserdataObject:(MOUserData *)value;
- (void)removeUserdataObject:(MOUserData *)value;
- (void)addUserdata:(NSSet *)values;
- (void)removeUserdata:(NSSet *)values;

- (void)addDidNumbersObject:(MODidNumber *)value;
- (void)removeDidNumbersObject:(MODidNumber *)value;
- (void)addDidNumbers:(NSSet *)values;
- (void)removeDidNumbers:(NSSet *)values;

@end
