//
//  MOTimelineEvent+CoreDataProperties.h
//  C2CallPhone
//
//  Created by Michael Knecht on 05/07/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOTimelineEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOTimelineEvent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contact;
@property (nullable, nonatomic, retain) NSNumber *eventId;
@property (nullable, nonatomic, retain) NSString *eventType;
@property (nullable, nonatomic, retain) NSNumber *missed;
@property (nullable, nonatomic, retain) NSString *originalSender;
@property (nullable, nonatomic, retain) NSString *senderName;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSNumber *timevalue;
@property (nullable, nonatomic, retain) NSNumber *like;
@property (nullable, nonatomic, retain) NSNumber *dislike;
@property (nullable, nonatomic, retain) NSString *timeline;
@property (nullable, nonatomic, retain) NSString *mediaUrl;

@end

NS_ASSUME_NONNULL_END
