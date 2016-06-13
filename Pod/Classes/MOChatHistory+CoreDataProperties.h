//
//  MOChatHistory+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 13/06/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOChatHistory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOChatHistory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contact;
@property (nullable, nonatomic, retain) NSString *lastEventId;
@property (nullable, nonatomic, retain) NSDate *lastMissedEvent;
@property (nullable, nonatomic, retain) NSDate *lastTimestamp;
@property (nullable, nonatomic, retain) NSNumber *missedEvents;
@property (nullable, nonatomic, retain) NSNumber *userType;
@property (nullable, nonatomic, retain) NSSet<MOC2CallEvent *> *chatHistory;

@end

@interface MOChatHistory (CoreDataGeneratedAccessors)

- (void)addChatHistoryObject:(MOC2CallEvent *)value;
- (void)removeChatHistoryObject:(MOC2CallEvent *)value;
- (void)addChatHistory:(NSSet<MOC2CallEvent *> *)values;
- (void)removeChatHistory:(NSSet<MOC2CallEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
