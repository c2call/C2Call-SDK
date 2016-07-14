//
//  SCAudioRecordingOverlayController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 12.07.16.
//
//

#import "SCAudioRecordingOverlayController.h"
#import "SCPTTRecorder.h"

@interface SCAudioRecordingOverlayController () {
    void (^useAction)(NSString *richMediaKey);
    void (^cancelAction)();

}

@property(nonatomic, strong) SCPTTRecorder      *recorder;
@property(nonatomic) BOOL                       recording;
@property(nonatomic, strong) NSString           *mediaKey;
@property (weak, nonatomic) IBOutlet UIImageView *recordingImage;

@end

@implementation SCAudioRecordingOverlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.recording) {
        [self cancelRecording];
    }
}

-(void) setUseAction:(void (^)(NSString *richMediaKey))handler
{
    useAction = handler;
}

-(void) setCancelAction:(void (^)())handler
{
    cancelAction = handler;
}

-(void) startRecording
{
    self.recorder = [[SCPTTRecorder alloc] initWithAudioType:PTT_Audio_WAVE];
    if ([self.recorder prepareRecordingSession]) {
        if ([self.recorder startRecording]) {
            self.recording = YES;
            [self recordTimer:nil];
            [self animateRecordingImage];
        }
    }
}

-(void) recordTimer:(NSTimer *) t
{
    if (self.recording) {
        self.recordingTime.text = [self.recorder recorderingTime];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTimer:) userInfo:nil repeats:NO];
    }
}

-(void) endRecording
{
    self.recording = NO;
    [self.recorder endRecordingAndUseWithCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
        self.recorder = nil;
        
        if (success) {
            self.mediaKey = richMediaKey;
            
            if (useAction) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    useAction(richMediaKey);
                });
            }

        }
    }];
    
}

-(void) cancelRecording
{
    self.recording = NO;
    [self.recorder cancelRecording];
    self.recorder = nil;
    
    if (cancelAction) {
        cancelAction();
    }
    
}

-(void) animateRecordingImage {
    if (!self.recording)
        return;
    
    __weak SCAudioRecordingOverlayController *weakself = self;
    
    if (self.recordingImage.alpha == 0.) {
        [UIView animateWithDuration:1.0 animations:^{
            self.recordingImage.alpha = 1.;
        } completion:^(BOOL finished) {
            [weakself animateRecordingImage];
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            self.recordingImage.alpha = 0.;
        } completion:^(BOOL finished) {
            [weakself animateRecordingImage];
        }];
    }
    
}

- (IBAction)startRecording:(id)sender {
    [self startRecording];
}

- (IBAction)endRecording:(id)sender {
    [self endRecording];
}

- (IBAction)cancelRecording:(id)sender {
    [self cancelRecording];
}

@end
