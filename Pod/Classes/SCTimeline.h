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
    SCTimeLineEvent_ActivityUserStatusChanged,
    SCTimeLineEvent_ActivityBroadcastAttended,
    SCTimeLineEvent_ActivityVideoWatched,
    SCTimeLineEvent_ActivityContentInfoRequest,
    SCTimeLineEvent_ActivityFriendsInvited,
    SCTimeLineEvent_ActivityFriendJoined,
    SCTimeLineEvent_ActivityContentShared,
    SCTimeLineEvent_ActivityLike,

} SCTimelineEventType;

@interface SCTimeline : NSObject

-(void) refreshTimeline;
-(void) refreshTimelineForEventId:(NSNumber *) eventId;

-(BOOL) submitTimelineEvent:(SCTimelineEventType) eventType withMessage:(NSString *) message andMedia:(NSString *) mediakey properties:(NSDictionary *) properties toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success))handler;
-(void) submitVideo:(NSURL *) mediaUrl withMessage:(NSString *) message properties:(NSDictionary *) properties toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey, NSError *error))handler;
-(void) submitImage:(UIImage *) originalImage withQuality:(UIImagePickerControllerQualityType) imageQuality andMessage:(NSString *) message properties:(NSDictionary *) properties toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey , NSError *error))handler;
-(void) submitAudio:(NSURL *) mediaUrl withMessage:(NSString *) message properties:(NSDictionary *) properties toTimeline:(NSString *) timeline withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey, NSError *error))handler;

-(void) likeEvent:(NSNumber *) eventId;
-(BOOL) canLikeEvent:(NSNumber *) eventId;
-(void) dislikeEvent:(NSNumber *) eventId;
-(BOOL) canDislikeEvent:(NSNumber *) eventId;
-(BOOL) deleteTimelineEvent:(NSNumber *) msgid;;

-(void) startLiveBroadcastMonitoring;

+(instancetype) instance;
+(NSString *) eventTypeForType:(SCTimelineEventType) eventType;


@end
