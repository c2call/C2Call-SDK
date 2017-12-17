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
#import "SIPPhone.h"
#import "C2CallPhone.h"

@interface SCBroadcastStatusController () {
    CFAbsoluteTime      startTime;
}
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitch;

@end

@implementation SCBroadcastStatusController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    startTime = 0;
    if ([SCMediaManager instance].cameraPosition == AVCaptureDevicePositionBack) {
        self.cameraSwitch.selected = YES;
    } else {
        self.cameraSwitch.selected = NO;
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberJoined:) name:@"GroupCallUserJoined" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberLeft:) name:@"GroupCallUserLeft" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) memberJoined:(NSNotification *) notification
{
    NSArray *list = [[C2CallPhone currentPhone] activeMembersInGroupCall];
    
    int active = (int)[list count];
    if (active > 0) { // Do not count the sender
        active--;
    }
    
    [self onlineUsers:active];
}

-(void) memberLeft:(NSNotification *) notification
{
    NSArray *list = [[C2CallPhone currentPhone] activeMembersInGroupCall];
    int active = (int)[list count];
    if (active > 0) { // Do not count the sender
        active--;
    }
    
    [self onlineUsers:active];
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

    if (startTime == 0) {
        startTime = CFAbsoluteTimeGetCurrent();
    }
    
    [self timeElapsed:CFAbsoluteTimeGetCurrent() - startTime];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([SIPPhone currentPhone].callStatus != SCCallStatusNone) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself updateBroadcastStatus];
            });            
        }
    });
}

-(void) onlineUsers:(NSInteger) onlineUsers
{
    
}

-(void) timeElapsed:(NSTimeInterval) elapsedTime
{
    
}

@end
