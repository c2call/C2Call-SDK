//
//  SCBroadcastRecordingController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//

#import "SCBroadcastRecordingController.h"
#import "SCBroadcastController.h"
#import "SCBroadcastStartController.h"
#import "SCBroadcastStatusController.h"
#import "C2CallPhone.h"
#import "SCMediaManager.h"
#import "SCBroadcast.h"
#import "SCTimeline.h"
#import "SCUserProfile.h"
#import "SCMediaManager.h"
#import "SCActivity.h"
#import "debug.h"

@interface SCBroadcastRecordingController ()<UIGestureRecognizerDelegate> {
    BOOL        _toggleView;
    
    BOOL        mediaRecordingStarted;
    BOOL        broadcastStarted;
}

@property (nonatomic, weak) AVCaptureVideoPreviewLayer *preview;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@end

@implementation SCBroadcastRecordingController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBroadcastStatusController:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    self.view.userInteractionEnabled = YES;
    
    self.broadcastStatusController.view.superview.hidden = YES;
    self.broadcastStartController.view.superview.hidden = NO;
    self.broadcastStatusController.view.alpha = 0.;
    self.broadcastStartController.view.alpha = 1.;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(broadcastConnected:) name:@"SCBroadcastConnected" object:nil];
    
}

-(void) broadcastConnected:(NSNotification *) notification
{
    //[[SCMediaManager instance] startMediaRecording];
    //mediaRecordingStarted = YES;
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    
    if (!self.preview) {
        AVCaptureVideoPreviewLayer *preview = [SCMediaManager instance].previewLayer;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        if (preview) {
            preview.frame = self.videoView.layer.bounds;
            [self.videoView.layer addSublayer:preview];
            self.preview = preview;
            
            if (![[SCMediaManager instance].videoCaptureSession isRunning]) {
                [[SCMediaManager instance] startVideoCapture];
            }
        }
    } else {
        self.preview.frame = self.videoView.layer.bounds;
    }
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        //[self stopBroadcasting];
        
        if ([[SCMediaManager instance].videoCaptureSession isRunning]) {
            [[SCMediaManager instance] stopVideoCapture];
        }
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastController class]]) {
        
        self.broadcastController = (SCBroadcastController *) segue.destinationViewController;
        if (_broadcastGroupId)
            self.broadcastController.broadcastGroupId = _broadcastGroupId;
        
    }
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastStatusController class]]) {
        self.broadcastStatusController = (SCBroadcastStatusController *) segue.destinationViewController;
        self.broadcastStatusController.recordingController = self;
    }
    
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastStartController class]]) {
        self.broadcastStartController = (SCBroadcastStartController *) segue.destinationViewController;
        self.broadcastStartController.recordingController = self;
        self.broadcastStartController.preset = self.preset;
    }
}

-(void) setBroadcastGroupId:(NSString *)broadcastGroupId
{
    _broadcastGroupId = broadcastGroupId;
    self.broadcastController.broadcastGroupId = _broadcastGroupId;
}

-(void) reportProgress
{
    __weak SCBroadcastRecordingController *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakself) {
            [SCActivity reportBroadcastPresentation:weakself.broadcastGroupId progress:1];
            [weakself reportProgress];
        }
    });
}

-(void) startBroadcasting
{
    broadcastStarted = YES;
    
    //[SCMediaManager instance].useGPUImageVideoCapture = YES;
    [[C2CallPhone currentPhone] callVideo:self.broadcastGroupId groupCall:YES];
    
    self.broadcastStartController.view.superview.hidden = YES;
    self.broadcastStatusController.view.superview.hidden = NO;
    
    SCBroadcast *bcast = [[SCBroadcast alloc] initWithBroadcastGroupid:self.broadcastGroupId retrieveFromServer:NO];
    
    if ([bcast.groupType isEqualToString:@"BCG_PUBLIC"]) {
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];
        properties[@"featured"] = bcast.isFeatured? @"true" : @"false";
        
        if (bcast.reward) {
            properties[@"reward"] = bcast.reward;
        }
        
        NSArray *tags = bcast.tags;
        if (tags) {
            properties[@"tag"] = tags;
        }
        
        BOOL res = [[SCTimeline instance] submitTimelineEvent:SCTimeLineEvent_ActivityBroadcastEvent withMessage:bcast.groupDescription andMedia:[NSString stringWithFormat:@"bcast://%@", bcast.groupid] properties:properties toTimeline:[SCUserProfile currentUser].userid withCompletionHandler:^(BOOL success) {
            
        }];
    }
    
    [self.broadcastStatusController updateBroadcastStatus];
    
    [SCActivity reportBroadcastPresentationStart:self.broadcastGroupId];
    [self reportProgress];
}

-(void) stopBroadcasting
{
    if (!broadcastStarted) {
        return;
    }
    broadcastStarted = NO;
    
    [[C2CallPhone currentPhone] hangUp];
    [SCActivity reportBroadcastPresentationEnd:self.broadcastGroupId];
    
    //[SCMediaManager instance].useGPUImageVideoCapture = NO;
    
    if (mediaRecordingStarted) {
        // This does not happen, we record server side...
        [[SCMediaManager instance] stopMediaRecordingWithCompletionHandler:^(NSString * _Nullable mediaKey) {
            
            if (mediaKey) {
                
                SCBroadcast *bcast = [[SCBroadcast alloc] initWithBroadcastGroupid:self.broadcastGroupId retrieveFromServer:YES];
                bcast.mediaUrl = mediaKey;
                [bcast saveBroadcast];
                
                /*
                 if ([bcast.groupType isEqualToString:@"BCG_PUBLIC"]) {
                 BOOL res = [[SCTimeline instance] submitTimelineEvent:SCTimeLineEvent_ActivityBroadcastEvent withMessage:bcast.groupDescription andMedia:[NSString stringWithFormat:@"bcast://%@", bcast.groupid] toTimeline:[SCUserProfile currentUser].userid withCompletionHandler:^(BOOL success) {
                 [self closeBroadcasting];
                 }];
                 
                 if (!res) {
                 [self closeBroadcasting];
                 }
                 } else {
                 [self closeBroadcasting];
                 }
                 */
                
                /*
                 NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:mediaKey];
                 
                 NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
                 DLog(@"File Attributes: %@", attr);
                 //[[C2CallPhone currentPhone] submitRichMessage:mediaKey message:nil toTarget:self.broadcastGroupId];
                 */
            }
            [self closeBroadcasting];
            
        }];
    } else {
        [self closeBroadcasting];
    }
}

-(void) closeBroadcasting
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)toggleBroadcastStatusController:(id)sender
{
    if (_toggleView)
        return;
    
    _toggleView = YES;
    
    if (self.broadcastStatusController.view.alpha == 0.) {
        [self.view bringSubviewToFront:self.broadcastStatusController.view];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.broadcastStatusController.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            _toggleView = NO;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.broadcastStatusController.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            _toggleView = NO;
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    
    if (self.broadcastStatusController.view.superview.hidden) {
        return NO;
    }
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}

-(UIImage *) capturePreviewImage
{
    if (self.preview) {
        UIView *snapView = [self.videoView snapshotViewAfterScreenUpdates:YES];
        UIGraphicsBeginImageContext(snapView.bounds.size);
        [snapView drawViewHierarchyInRect:snapView.bounds afterScreenUpdates:NO];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
    
    return nil;
}

-(BOOL) shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end

