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

@property (weak, nonatomic) SCBroadcastRecordingController *recordingController;

@end
