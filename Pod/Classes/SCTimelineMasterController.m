//
//  SCTimelineMasterController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 07/07/16.
//
//

#import "SCTimelineMasterController.h"
#import "SCTimeline.h"
#import "C2CallPhone.h"
#import "SCUserProfile.h"
#import "UIViewController+SCCustomViewController.h"

@interface SCTimelineMasterController ()

@property(nonatomic, strong) NSMutableDictionary    *currentMessage;

@end

@implementation SCTimelineMasterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) updateMessage
{
    if (self.currentMessage) {
        self.attachmentView.image = self.currentMessage[@"preview"];
        
        NSString *text = self.currentMessage[@"text"];
        if (text) {
            self.textView.text = text;
        }
    } else {
        self.attachmentView.image = nil;
        self.textView.text = nil;
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
        }
    }
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
    
}

- (IBAction)addLocation:(id)sender {
    
}

- (IBAction)addAudio:(id)sender {
    
}

- (IBAction)submitTimelineEvent:(id)sender {
    NSString *text = self.textView.text;
    NSString *mediakey = self.currentMessage[@"mediakey"];
    NSNumber *eventType = self.currentMessage[@"eventType"];
    
    if (!eventType && !mediakey)
        eventType = @(SCTimeLineEvent_Message);
    
    if (([text length] > 0 || [mediakey length] > 0) && eventType) {
        [[SCTimeline instance] submitTimelineEvent:[eventType intValue] withMessage:text andMedia:mediakey toTimeline:[SCUserProfile currentUser].userid];
        self.currentMessage = nil;
        [self updateMessage];
    }
}

@end
