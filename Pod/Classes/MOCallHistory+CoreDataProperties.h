//
//  MOCallHistory+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 22.03.17.
//
//

#import "MOCallHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MOCallHistory (CoreDataProperties)

+ (NSFetchRequest<MOCallHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *contact;
@property (nullable, nonatomic, copy) NSString *lastEventId;
@property (nullable, nonatomic, copy) NSDate *lastMissedEvent;
@property (nullable, nonatomic, copy) NSDate *lastTimestamp;
@property (nonatomic) BOOL meeting;
@property (nullable, nonatomic, copy) NSNumber *missedEvents;
@property (nullable, nonatomic, copy) NSNumber *userType;
@property (nonatomic) BOOL requireUpdate;
@property (nullable, nonatomic, retain) NSSet<MOC2CallEvent *> *callHistory;

@end

@interface MOCallHistory (CoreDataGeneratedAccessors)

- (void)addCallHistoryObject:(MOC2CallEvent *)value;
- (void)removeCallHistoryObject:(MOC2CallEvent *)value;
- (void)addCallHistory:(NSSet<MOC2CallEvent *> *)values;
- (void)removeCallHistory:(NSSet<MOC2CallEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
