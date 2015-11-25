//
//  MOChatHistory.h
//  C2CallPhone
//
//  Created by Michael Knecht on 03.06.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallEvent;

@interface MOChatHistory : NSManagedObject

@property (nonatomic, retain) NSString * lastEventId;
@property (nonatomic, retain) NSDate * lastMissedEvent;
@property (nonatomic, retain) NSDate * lastTimestamp;
@property (nonatomic, retain) NSNumber * missedEvents;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSSet *chatHistory;
@end

@interface MOChatHistory (CoreDataGeneratedAccessors)

- (void)addChatHistoryObject:(MOC2CallEvent *)value;
- (void)removeChatHistoryObject:(MOC2CallEvent *)value;
- (void)addChatHistory:(NSSet *)values;
- (void)removeChatHistory:(NSSet *)values;

@end
