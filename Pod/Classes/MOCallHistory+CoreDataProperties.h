//
//  MOCallHistory+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 13/06/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOCallHistory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOCallHistory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contact;
@property (nullable, nonatomic, retain) NSString *lastEventId;
@property (nullable, nonatomic, retain) NSDate *lastMissedEvent;
@property (nullable, nonatomic, retain) NSDate *lastTimestamp;
@property (nullable, nonatomic, retain) NSNumber *missedEvents;
@property (nullable, nonatomic, retain) NSNumber *userType;
@property (nullable, nonatomic, retain) NSSet<MOC2CallEvent *> *callHistory;

@end

@interface MOCallHistory (CoreDataGeneratedAccessors)

- (void)addCallHistoryObject:(MOC2CallEvent *)value;
- (void)removeCallHistoryObject:(MOC2CallEvent *)value;
- (void)addCallHistory:(NSSet<MOC2CallEvent *> *)values;
- (void)removeCallHistory:(NSSet<MOC2CallEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
