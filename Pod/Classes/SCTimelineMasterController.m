//
//  SCTimelineMasterController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 07/07/16.
//
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "SCTimelineMasterController.h"
#import "SCTimelineController.h"
#import "SCTimeline.h"

#import "C2CallPhone.h"
#import "SocialCommunication.h"
#import "SCUserProfile.h"
#import "UIViewController+SCCustomViewController.h"

@interface SCTimelineMasterController ()<UITextViewDelegate>

@property(nonatomic, strong) NSMutableDictionary    *currentMessage;
@property(nonatomic, weak) SCTimelineController     *timelineController;
@property(nonatomic, strong) NSString               *progressKey;

@end

@implementation SCTimelineMasterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.textView.delegate = self;
    self.progressViewHeight.constant = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    self.placeholderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView;
{
    if ([textView.text length] == 0) {
        self.placeholderLabel.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView;
{
    NSString *newtext = textView.text;
    CGSize maximumLabelSize = textView.bounds.size;
    maximumLabelSize.height = 999;
    CGSize expectedTextSize = [newtext boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:textView.font} context:nil].size;
    
    if (expectedTextSize.height > 120) {
        textView.scrollEnabled = YES;
    } else {
        textView.scrollEnabled = NO;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCTimelineController class]]) {
        self.timelineController = (SCTimelineController *) segue.destinationViewController;
        self.timelineController.delegate = self;
    }
}

-(void) timelineControllerDidScroll:(UIScrollView *)scrollView
{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

-(void) updateMessage
{
    if (self.currentMessage) {
        self.attachmentView.image = self.currentMessage[@"preview"];
        
        NSString *text = self.currentMessage[@"text"];
        if ([text length] > 0) {
            self.textView.text = text;
            self.placeholderLabel.hidden = YES;
        }
    } else {
        self.attachmentView.image = [UIImage imageNamed:@"transparent1x1"];
        self.textView.text = nil;
        self.placeholderLabel.hidden = NO;
        
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
        }
    }
}

- (IBAction)addFromAlbum:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;

    [self captureMediaFromImagePicker:imagePicker andCompleteAction:^(NSString *key) {
        if (key) {
            UIImage *image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            if (!image) {
                return;
            }
            
            NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithCapacity:3];
            msg[@"preview"] = image;
            msg[@"mediakey"] = key;
            msg[@"eventType"] = [key hasPrefix:@"image://"]? @(SCTimeLineEvent_Picture): @(SCTimeLineEvent_Video);
            
            self.currentMessage = msg;
            [self updateMessage];
        }
    }];
}

- (IBAction)addImage:(id)sender {
    [self captureImageFromCameraWithQuality:UIImagePickerControllerQualityTypeMedium andCompleteAction:^(NSString *key) {
        
        if (key) {
            UIImage *image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            if (!image) {
                return;
            }
            
            NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithCapacity:3];
            msg[@"preview"] = image;
            msg[@"mediakey"] = key;
            msg[@"eventType"] = @(SCTimeLineEvent_Picture);
            
            self.currentMessage = msg;
            [self updateMessage];
        }
    }];
}

- (IBAction)addVideo:(id)sender {
    [self captureVideoFromCameraWithQuality:UIImagePickerControllerQualityTypeLow andCompleteAction:^(NSString *key) {
        
        if (key) {
            UIImage *image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            if (!image) {
                return;
            }
            
            NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithCapacity:3];
            msg[@"preview"] = image;
            msg[@"mediakey"] = key;
            msg[@"eventType"] = @(SCTimeLineEvent_Video);
            
            self.currentMessage = msg;
            [self updateMessage];
        }
    }];
}

- (IBAction)addLocation:(id)sender {
    [self requestLocation:^(NSString *key) {
        if (key) {
            UIImage *image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            if (!image) {
                return;
            }
            
            NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithCapacity:3];
            msg[@"preview"] = image;
            msg[@"mediakey"] = key;
            msg[@"eventType"] = @(SCTimeLineEvent_Location);
            
            self.currentMessage = msg;
            [self updateMessage];
        }
    }];
}

- (IBAction)addAudio:(id)sender {
    [self recordVoiceMail:^(NSString *key) {
        if (key) {
            NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithCapacity:3];
            msg[@"preview"] = [UIImage imageNamed:@"ico_voice_msg"];
            msg[@"mediakey"] = key;
            msg[@"eventType"] = @(SCTimeLineEvent_Audio);
            
            self.currentMessage = msg;
            [self updateMessage];
        }
    }];
}

- (IBAction)submitTimelineEvent:(id)sender {
    NSString *text = self.textView.text;
    NSString *mediakey = self.currentMessage[@"mediakey"];
    NSNumber *eventType = self.currentMessage[@"eventType"];
    
    if (!eventType && !mediakey)
        eventType = @(SCTimeLineEvent_Message);
    
    if (([text length] > 0 || [mediakey length] > 0) && eventType) {
        [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:@"Uploading content" andWaitMessage:nil];
        [self.timelineController scrollToTopOnUpdate];
        
        if ([mediakey length] > 0 && ![mediakey hasPrefix:@"loc://"]) {
            [self addProgressObserverForKey:mediakey];
        }
        BOOL res = [[SCTimeline instance] submitTimelineEvent:[eventType intValue] withMessage:text andMedia:mediakey toTimeline:[SCUserProfile currentUser].userid withCompletionHandler:^(BOOL success) {
            
            self.currentMessage = nil;
            [self updateMessage];
            [[C2CallAppDelegate appDelegate] waitIndicatorStop];
        }];
        
        if (!res) {
            [[C2CallAppDelegate appDelegate] waitIndicatorStop];
        }
    }
}

-(void) addProgressObserverForKey:(NSString *) key
{
    if (self.progressKey) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:self.progressKey object:nil];
        self.progressKey = nil;
    }
    
    [self showProgress];
    
    self.progressKey = key;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNotification:) name:key object:nil];

}


-(void) uploadProgressNotification:(NSNotification *) notification
{
    if (self.progressKey && [[notification name] isEqualToString:self.progressKey]) {
        
        NSNumber *p = [notification.userInfo objectForKey:@"progress"];
        if (p) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.progressViewHeight.constant == 0) {
                    [self showProgress];
                }
                [self.progress setProgress:[p floatValue] / 100.];
            });
        }
        
        NSNumber *finished = [notification.userInfo objectForKey:@"finished"];
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:self.progressKey object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgress];
            });
        }
    }
}

-(void) showProgress
{
    self.progressViewHeight.constant = 26;
    [UIView animateWithDuration:0.5 animations:^{
        [self.headerView layoutIfNeeded];
    }];
}

-(void) hideProgress
{
    self.progressViewHeight.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.headerView layoutIfNeeded];
    }];
}

@end
