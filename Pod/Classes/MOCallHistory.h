//
//  MOCallHistory.h
//  C2CallPhone
//
//  Created by Michael Knecht on 03.06.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallEvent;

@interface MOCallHistory : NSManagedObject

@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * lastEventId;
@property (nonatomic, retain) NSDate * lastMissedEvent;
@property (nonatomic, retain) NSDate * lastTimestamp;
@property (nonatomic, retain) NSNumber * missedEvents;
@property (nonatomic, retain) NSSet *callHistory;
@end

@interface MOCallHistory (CoreDataGeneratedAccessors)

- (void)addCallHistoryObject:(MOC2CallEvent *)value;
- (void)removeCallHistoryObject:(MOC2CallEvent *)value;
- (void)addCallHistory:(NSSet *)values;
- (void)removeCallHistory:(NSSet *)values;

@end
