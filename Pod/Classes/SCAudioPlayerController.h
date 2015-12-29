//
//  SCAudioPlayerController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CALevelMeter;

/** Presents the standard C2Call SDK Audio Player Controller.
 */
@interface SCAudioPlayerController : UIViewController

/** @name Outlets */
/** Play Button. */
@property(nonatomic, weak) IBOutlet UIButton             *btnPlay;

/** Shows the current play time. */
@property(nonatomic, weak) IBOutlet UILabel              *labelTime;

/** Shows the audio file duration. */
@property(nonatomic, weak) IBOutlet UILabel              *labelDuration;

/** Shows play progress. */
@property(nonatomic, weak) IBOutlet UIProgressView       *progress;

/** Level Meter. */
@property(nonatomic, weak) IBOutlet CALevelMeter         *levelMeter;

/** Rich Media Key of the audio file. */
@property(nonatomic, strong) NSString                    *messageKey;

/** @name Action */
/** Start / Stop Playback. 
 @param sender - The initiator of the action
*/
-(IBAction)togglePlayback:(UIButton *)sender;
/** Forward VoiceMail.
 @param sender - The initiator of the action
 */
-(IBAction)forwardMessage:(id) sender;

/** Shows the default content menu using SCPopupMenu.
 
 Default Implementation:
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"MenuItem") andSubTitle:NSLocalizedString(@"Forward to another FriendCaller user", @"Button") andIcon:[UIImage imageNamed:@"ico_forward"] andCompletion:^{
        [self forwardMessage:nil];
    }];
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        
    }];
    [cv showMenu];

 @param sender - The initiator of the action

*/
-(IBAction)contentAction:(id)sender;

@end
