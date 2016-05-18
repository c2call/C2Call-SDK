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

@implementation SCBroadcastStatusController

- (IBAction)toggleCamera:(UIButton *)cameraButton {
    
    if (cameraButton.selected) {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionFront];
    } else {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionBack];
    }
}

- (IBAction)stopBroadcast:(id)sender {
    [self.recordingController stopBroadcasting];
}

@end
