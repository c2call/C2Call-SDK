//
//  MOTag+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.03.17.
//
//

#import "MOTag+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MOTag (CoreDataProperties)

+ (NSFetchRequest<MOTag *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *tag;
@property (nullable, nonatomic, copy) NSNumber *featured;
@property (nullable, nonatomic, retain) NSSet<MOTimelineEvent *> *timelineItems;
@property (nullable, nonatomic, retain) NSSet<MOC2CallBroadcast *> *broadcasts;

@end

@interface MOTag (CoreDataGeneratedAccessors)

- (void)addTimelineItemsObject:(MOTimelineEvent *)value;
- (void)removeTimelineItemsObject:(MOTimelineEvent *)value;
- (void)addTimelineItems:(NSSet<MOTimelineEvent *> *)values;
- (void)removeTimelineItems:(NSSet<MOTimelineEvent *> *)values;

- (void)addBroadcastsObject:(MOC2CallBroadcast *)value;
- (void)removeBroadcastsObject:(MOC2CallBroadcast *)value;
- (void)addBroadcasts:(NSSet<MOC2CallBroadcast *> *)values;
- (void)removeBroadcasts:(NSSet<MOC2CallBroadcast *> *)values;

@end

NS_ASSUME_NONNULL_END
