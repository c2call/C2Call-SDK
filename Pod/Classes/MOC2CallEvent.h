//
//  MOC2CallEvent.h
//  C2CallPhone
//
//  Created by Michael Knecht on 25.11.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOCallHistory, MOChatHistory;

@interface MOC2CallEvent : NSManagedObject

@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * encrypted;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSString * line;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSNumber * missed;
@property (nonatomic, retain) NSNumber * missedDisplay;
@property (nonatomic, retain) NSString * originalSender;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * timeGroup;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * timevalue;
@property (nonatomic, retain) NSNumber * costs;
@property (nonatomic, retain) MOCallHistory *lastCall;
@property (nonatomic, retain) MOChatHistory *lastChat;

@end
