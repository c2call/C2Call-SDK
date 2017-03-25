//
//  MOCallHistory+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 22.03.17.
//
//

#import "MOCallHistory+CoreDataProperties.h"

@implementation MOCallHistory (CoreDataProperties)

+ (NSFetchRequest<MOCallHistory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MOCallHistory"];
}

@dynamic contact;
@dynamic lastEventId;
@dynamic lastMissedEvent;
@dynamic lastTimestamp;
@dynamic meeting;
@dynamic missedEvents;
@dynamic userType;
@dynamic requireUpdate;
@dynamic callHistory;

@end
