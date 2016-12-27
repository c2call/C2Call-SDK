//
//  MOUserData+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOUserData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOUserData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSNumber *public;
@property (nullable, nonatomic, retain) NSString *value;
@property (nullable, nonatomic, retain) MOC2CallUser *friend;
@property (nullable, nonatomic, retain) MOC2CallGroup *group;
@property (nullable, nonatomic, retain) MOC2CallBroadcast *broadcast;

@end

NS_ASSUME_NONNULL_END
