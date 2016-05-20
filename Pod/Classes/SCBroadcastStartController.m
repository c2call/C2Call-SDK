//
//  SCBroadcastStartController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//


#import "SCBroadcastStartController.h"
#import "SCBroadcastRecordingController.h"
#import "SCUserSelectionController.h"
#import "C2CallPhone.h"
#import "SCMediaManager.h"

@interface SCBroadcastStartController ()

@property(nonatomic, strong) NSArray    *members;

@end

@implementation SCBroadcastStartController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCUserSelectionControllerSegue"]) {
        __weak UINavigationController *nav = (UINavigationController *) segue.destinationViewController;
        
        SCUserSelectionController *vc = (SCUserSelectionController *) nav.topViewController;
        
        [vc setResultAction:^(NSArray *result) {
            self.members = result;
            
            [nav dismissViewControllerAnimated:YES completion:NULL];
        }];
        
        [vc setCancelAction:^{
            [nav dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
}


- (IBAction)broadcastNameChanged:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)startVideo:(id)sender {
    
    
    [[C2CallPhone currentPhone] createBroadcast:self.broadcastName.text withProperties:@{@"UseLocation" : @(self.locationButton.selected)} withMembers:self.members withCompletionHandler:^(BOOL success, NSString * _Nullable bcastId, NSString * _Nullable result) {
       
        if (success) {
            self.recordingController.broadcastGroupId = bcastId;
            [self.recordingController startBroadcasting];
        }
    }];
}
- (IBAction)toggleCamera:(UIButton *)cameraButton {
    if (cameraButton.selected) {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionFront];
    } else {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionBack];
    }
}

- (IBAction)closeController:(id)sender {
    [self.recordingController closeBroadcasting];
}

@end
