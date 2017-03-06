//
//  SCActivity.h
//  C2CallPhone
//
//  Created by Michael Knecht on 02.03.17.
//
//

#import <Foundation/Foundation.h>


@interface SCActivity : NSObject

+(void) reportSuccessfulUserInvite:(NSString *) reference;
+(void) reportFeaturedContentInfoRequest:(NSString *) reference;
+(void) reportBroadcastComment:(NSString *) reference;
+(void) reportBroadcastVideoEnd:(NSString *) reference;
+(void) reportBroadcastVideo:(NSString *) reference progress:(int) progress;
+(void) reportBroadcastVideoStart:(NSString *) reference;
+(void) reportBroadcastAttendEnd:(NSString *) reference;
+(void) reportBroadcastAttend:(NSString *) reference progress:(int) progress;
+(void) reportBroadcastAttendStart:(NSString *) reference;
+(void) reportBroadcastPresentationEnd:(NSString *) reference;
+(void) reportBroadcastPresentation:(NSString *) reference progress:(int) progress;
+(void) reportBroadcastPresentationStart:(NSString *) reference;
+(void) reportTimelineVideoEnd:(NSString *) reference;
+(void) reportTimelineVideo:(NSString *) reference progress:(int) progress;
+(void) reportTimelineVideoStart:(NSString *) reference;

+(NSArray *) listActivityRewards;
+(void) setUseActivityReports:(BOOL) useReports;


@end
