//
//  MOChatHistory+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 22.03.17.
//
//

#import "MOChatHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MOChatHistory (CoreDataProperties)

+ (NSFetchRequest<MOChatHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *contact;
@property (nullable, nonatomic, copy) NSString *lastEventId;
@property (nullable, nonatomic, copy) NSDate *lastMissedEvent;
@property (nullable, nonatomic, copy) NSDate *lastTimestamp;
@property (nonatomic) BOOL meeting;
@property (nullable, nonatomic, copy) NSNumber *missedEvents;
@property (nullable, nonatomic, copy) NSNumber *userType;
@property (nonatomic) BOOL requireUpdate;
@property (nullable, nonatomic, retain) NSSet<MOC2CallEvent *> *chatHistory;

@end

@interface MOChatHistory (CoreDataGeneratedAccessors)

- (void)addChatHistoryObject:(MOC2CallEvent *)value;
- (void)removeChatHistoryObject:(MOC2CallEvent *)value;
- (void)addChatHistory:(NSSet<MOC2CallEvent *> *)values;
- (void)removeChatHistory:(NSSet<MOC2CallEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
