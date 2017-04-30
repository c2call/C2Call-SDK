//
//  SCBroadcastStatusController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//

#import "SCBroadcastStatusController.h"
#import "SCBroadcastRecordingController.h"
#import "SCBroadcast.h"
#import "SCMediaManager.h"

@interface SCBroadcastStatusController ()
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitch;

@end

@implementation SCBroadcastStatusController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    if ([SCMediaManager instance].cameraPosition == AVCaptureDevicePositionBack) {
        self.cameraSwitch.selected = YES;
    } else {
        self.cameraSwitch.selected = NO;
    }

}



- (IBAction)toggleCamera:(UIButton *)cameraButton {
    
    if ([SCMediaManager instance].cameraPosition == AVCaptureDevicePositionBack) {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionFront];
        cameraButton.selected = NO;
    } else {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionBack];
        cameraButton.selected = YES;
    }
}

- (IBAction)stopBroadcast:(id)sender {
    [self.recordingController stopBroadcasting];
}


-(void) updateBroadcastStatus
{
    __weak SCBroadcastStatusController *weakself = self;
    NSString * bcastId = self.recordingController.broadcastGroupId;
    
    if (!bcastId)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SCBroadcast *bcast = [[SCBroadcast alloc]initWithBroadcastGroupid:bcastId retrieveFromServer:YES];
        
        if (bcast.startDate) {
            [weakself timeElapsed:[bcast.startDate timeIntervalSinceReferenceDate]];
        }
        
        [weakself onlineUsers:bcast.onlineUsers];
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself updateBroadcastStatus];
    });
}

-(void) onlineUsers:(NSInteger) onlineUsers
{
    
}

-(void) timeElapsed:(NSTimeInterval) elapsedTime
{
    
}

@end
