//
//  FlurryEventProtocol.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.05.11.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#ifndef __FLURRYEVENTPROTOCOL
#define __FLURRYEVENTPROTOCOL

/** The C2Call SDK automatically reports Flurry Analytics events on certain activities, like calls, messages, etc.
 
 Those events will not be directly reported to the FlurryAnalytics API, but reported to the FlurryEventsDelegate instead.
 
 The FlurryEventsDelegate (typically the C2CallAppDelegate) will then call the FlurryAnalytics API to actually report the event.
 
 This default behavior can be changed, by overwriting the corresponding C2CallAppDelegate methods.
 
 */
@protocol FlurryEventsDelegate

@optional

// Flurry Events

/** See Flurry Analytics documentation for logEvent:
 */
-(void)logEvent:(NSString *)eventName;

/** See Flurry Analytics documentation for logEvent:withParameters:
 */
-(void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

/** See Flurry Analytics documentation for logError:message:exception:
 */
-(void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;

/** See Flurry Analytics documentation for logError:message:error:
 */
-(void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error;

/* 
 start or end timed events
 */
/** See Flurry Analytics documentation for logEvent:timed:
 */
-(void)logEvent:(NSString *)eventName timed:(BOOL)timed;

/** See Flurry Analytics documentation for logEvent:withParameters:timed:
 */
-(void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters timed:(BOOL)timed;

/** See Flurry Analytics documentation for endTimedEvent:withParameters:
 */
-(void)endTimedEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;	// non-nil parameters will update the parameters

/** See Flurry Analytics documentation for setUserID:
 */
-(void)setUserID:(NSString *)userID;	// user's id in your system

@end

#endif