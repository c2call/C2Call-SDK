//
//  MOTimelineEvent+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 26.05.17.
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
@dynamic featured;
@dynamic like;
@dynamic mediaUrl;
@dynamic missed;
@dynamic originalSender;
@dynamic reward;
@dynamic senderName;
@dynamic status;
@dynamic text;
@dynamic timeline;
@dynamic timeStamp;
@dynamic timevalue;
@dynamic mediaWidth;
@dynamic mediaHeight;
@dynamic tags;

@end
