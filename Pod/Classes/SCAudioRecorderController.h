//
//  SCAudioRecorderController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CALevelMeter;

/** Presents the standard C2Call SDK Audio Recorder Controller.
 
 Captures a VoiceMail for submission.
 */

@interface SCAudioRecorderController : UIViewController

/** @name Outlets */
/** Record Button. */
@property(nonatomic, weak) IBOutlet UIButton             *btnRecord;

/** Play Button. */
@property(nonatomic, weak) IBOutlet UIButton             *btnPlay;

/** Submit Button. */
@property(nonatomic, weak) IBOutlet UIButton             *btnSubmit;

/** Record Again Button. */
@property(nonatomic, weak) IBOutlet UIButton             *btnRecordAgain;

/** Shows the recorded Time. */
@property(nonatomic, weak) IBOutlet UILabel              *labelTime;

/** Shows the max. recording Time */
@property(nonatomic, weak) IBOutlet UILabel              *labelMaxtime;

/** StartView shows Record Button only. */
@property(nonatomic, weak) IBOutlet UIView               *startView;

/** EditView shows Play and Record Again Button. */
@property(nonatomic, weak) IBOutlet UIView               *editView;

/** Shows recording progress. */
@property(nonatomic, weak) IBOutlet UIProgressView       *progress;

/** Shows Level Meter. */
@property(nonatomic, weak) IBOutlet CALevelMeter         *levelMeter;

/** Targets Userid for Submit. */
@property(nonatomic, strong) NSString *targetUserid;

/** Rich Media Key of the recorded Message. */
@property(nonatomic, strong) NSString *messageKey;

/** @name Actions */
/** Start / Stop Recording. 
 @param sender - The initiator of the action
 */
-(IBAction)toogleRecording:(UIButton *)sender;

/** Start / Stop Playback.
 @param sender - The initiator of the action
 */
-(IBAction)togglePlayback:(UIButton *)sender;

/** Record Again.
 @param sender - The initiator of the action
 */
-(IBAction)recordAgain:(UIButton *)sender;

/** Submits the VoiceMail or triggers the Submit Action.
 @param sender - The initiator of the action
 */
-(IBAction)submitMessage:(UIButton *)sender;

/** Sets the Submit Action.
 Example:
 
    [controller setSubmitAction:^(NSString *key) {
        [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:targetUser];
        [self.navigationController popViewControllerAnimated:YES];
    }];
 
 @param submitAction - The Action Block
 */
-(void) setSubmitAction:(void (^)(NSString *)) submitAction;

/** Sets the Cancel Action.
 Example:
 
    [controller setCancelAction:^(NSString *key) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
 
 @param cancelAction - The Action Block
 */
-(void) setCancelAction:(void (^)()) cancelAction;

@end
