//
//  MOChatHistory+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 13/06/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MOChatHistory+CoreDataProperties.h"

@implementation MOChatHistory (CoreDataProperties)

@dynamic contact;
@dynamic lastEventId;
@dynamic lastMissedEvent;
@dynamic lastTimestamp;
@dynamic missedEvents;
@dynamic userType;
@dynamic chatHistory;

@end
