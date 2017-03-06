//
//  MOTimelineEvent+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.03.17.
//
//

#import "MOTimelineEvent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MOTimelineEvent (CoreDataProperties)

+ (NSFetchRequest<MOTimelineEvent *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *contact;
@property (nullable, nonatomic, copy) NSNumber *dislike;
@property (nullable, nonatomic, copy) NSNumber *eventId;
@property (nullable, nonatomic, copy) NSString *eventType;
@property (nullable, nonatomic, copy) NSNumber *like;
@property (nullable, nonatomic, copy) NSString *mediaUrl;
@property (nullable, nonatomic, copy) NSNumber *missed;
@property (nullable, nonatomic, copy) NSString *originalSender;
@property (nullable, nonatomic, copy) NSString *senderName;
@property (nullable, nonatomic, copy) NSNumber *status;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *timeline;
@property (nullable, nonatomic, copy) NSDate *timeStamp;
@property (nullable, nonatomic, copy) NSNumber *timevalue;
@property (nullable, nonatomic, copy) NSNumber *featured;
@property (nullable, nonatomic, copy) NSString *reward;
@property (nullable, nonatomic, retain) NSSet<MOTag *> *tags;

@end

@interface MOTimelineEvent (CoreDataGeneratedAccessors)

- (void)addTagsObject:(MOTag *)value;
- (void)removeTagsObject:(MOTag *)value;
- (void)addTags:(NSSet<MOTag *> *)values;
- (void)removeTags:(NSSet<MOTag *> *)values;

@end

NS_ASSUME_NONNULL_END
