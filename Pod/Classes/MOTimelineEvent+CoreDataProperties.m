//
//  MOTimelineEvent+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 01.03.17.
//
//

#import "MOTimelineEvent+CoreDataProperties.h"

@implementation MOTimelineEvent (CoreDataProperties)

+ (NSFetchRequest<MOTimelineEvent *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MOTimelineEvent"];
}

@dynamic contact;
@dynamic dislike;
@dynamic eventId;
@dynamic eventType;
@dynamic like;
@dynamic mediaUrl;
@dynamic missed;
@dynamic originalSender;
@dynamic senderName;
@dynamic status;
@dynamic text;
@dynamic timeline;
@dynamic timeStamp;
@dynamic timevalue;
@dynamic featured;
@dynamic reward;
@dynamic tags;

@end
