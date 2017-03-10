//
//  SCBroadcastRecordingController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//

#import <UIKit/UIKit.h>

@class SCBroadcastController, SCBroadcastStartController, SCBroadcastStatusController;

@interface SCBroadcastRecordingController : UIViewController

@property(nonatomic, weak) SCBroadcastController    *broadcastController;
@property(nonatomic, weak) SCBroadcastStartController    *broadcastStartController;
@property(nonatomic, weak) SCBroadcastStatusController    *broadcastStatusController;

@property(nonatomic, strong) NSDictionary   *preset;
@property(nonatomic, strong) NSString   *broadcastGroupId;

-(void) startBroadcasting;
-(void) stopBroadcasting;
-(void) closeBroadcasting;

-(UIImage *) capturePreviewImage;

@end
