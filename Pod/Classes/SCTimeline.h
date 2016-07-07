//
//  SCTimeline.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.07.16.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    SCTimeLineEvent_Message,
    SCTimeLineEvent_Picture,
    SCTimeLineEvent_Video,
    SCTimeLineEvent_Location,
    SCTimeLineEvent_Audio,
    SCTimeLineEvent_ActivityProfilePictureChanged,
    SCTimeLineEvent_ActivityBroadcastEvent,
    SCTimeLineEvent_ActivityUserStatusChanged
    
} SCTimelineEventType;

@interface SCTimeline : NSObject

-(void) refreshTimeline;
-(BOOL) submitTimelineEvent:(SCTimelineEventType) eventType withMessage:(NSString *) message andMedia:(NSString *) mediakey toTimeline:(NSString *) timeline;
-(void) submitVideo:(NSURL *) mediaUrl withMessage:(NSString *) message toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey, NSError *error))handler;
-(void) submitImage:(UIImage *) originalImage withQuality:(UIImagePickerControllerQualityType) imageQuality andMessage:(NSString *) message toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey , NSError *error))handler;
-(void) submitAudio:(NSURL *) mediaUrl withMessage:(NSString *) message toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey, NSError *error))handler;

+(instancetype) instance;
+(NSString *) eventTypeForType:(SCTimelineEventType) eventType;


@end
