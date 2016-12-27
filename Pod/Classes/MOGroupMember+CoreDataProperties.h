//
//  MOGroupMember+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOGroupMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOGroupMember (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstname;
@property (nullable, nonatomic, retain) NSString *lastname;
@property (nullable, nonatomic, retain) NSString *userid;
@property (nullable, nonatomic, retain) MOC2CallGroup *group;
@property (nullable, nonatomic, retain) MOC2CallBroadcast *broadcast;

@end

NS_ASSUME_NONNULL_END
