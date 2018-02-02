//
//  SCBroadcastStartController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//

@class SCBroadcastRecordingController;

#import <UIKit/UIKit.h>

@interface SCBroadcastStartController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *broadcastName;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *membersButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (strong, nonatomic) NSArray   *tags;
@property (nonatomic) BOOL              featured;
@property (strong, nonatomic) NSString  *reward;
@property (strong, nonatomic) UIImage   *teaserImage;

@property (nonatomic, strong) NSDictionary  *preset;
@property(nonatomic, strong) NSArray        *members;

@property (weak, nonatomic) SCBroadcastRecordingController *recordingController;

@end
