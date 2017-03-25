//
//  MOChatHistory+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 22.03.17.
//
//

#import "MOChatHistory+CoreDataProperties.h"

@implementation MOChatHistory (CoreDataProperties)

+ (NSFetchRequest<MOChatHistory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MOChatHistory"];
}

@dynamic contact;
@dynamic lastEventId;
@dynamic lastMissedEvent;
@dynamic lastTimestamp;
@dynamic meeting;
@dynamic missedEvents;
@dynamic userType;
@dynamic requireUpdate;
@dynamic chatHistory;

@end
