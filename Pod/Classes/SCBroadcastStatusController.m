//
//  SCBroadcastStatusController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//

#import "SCBroadcastStatusController.h"
#import "SCBroadcastRecordingController.h"
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

@end
