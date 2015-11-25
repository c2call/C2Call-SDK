//
//  SCVideoPlayerController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "C2ExpandViewController.h"

/** Internal Component to present the video
 */

@interface SCVideoView : UIView

/** Control's View Outlet */
@property (nonatomic, weak) IBOutlet UIView           *controlsView;

/** Broken Link Image Outlet */
@property (nonatomic, weak) IBOutlet UIImageView      *imageBroken;

@end

/** Presents the standard C2Call SDK Video Player Controller.
 */
@interface SCVideoPlayerController : C2ExpandViewController {
}

/** @name Outlets */
/** SCVideoView; the actual player view. */
@property (nonatomic, weak) IBOutlet SCVideoView      *playerView;

/** Toggles playback / stop. */
@property (nonatomic, weak) IBOutlet UIButton         *playButton;

/** Timelable Outlet */
@property(nonatomic, strong) IBOutlet UILabel           *timeLabel;

/** LoadingView Outlet */
@property (nonatomic, strong) IBOutlet UIView           *loadingView;

/** Expand Collapse Button Outlet */
@property (nonatomic, strong) IBOutlet UIButton           *expandCollapseButton;

/** @name Properties */
/** Player Item; see AVPlayerItem. */
@property (nonatomic, strong) AVPlayerItem              *playerItem;

/** Player; see AVPlayer. */
@property (nonatomic, strong) AVPlayer                  *player;

/** Media URL of the Video. */
@property (nonatomic, strong) NSURL                     *mediaUrl;

/** Rich Media Key of the Video. */
@property (nonatomic, strong) NSString                  *richMessageKey;

/** @name Actions */
/** Saves video to the photo album.
 
 @param sender - The initiator of the action
 */
- (IBAction) saveToAlbum:(id)sender;

/** Forwards video.
 
 @param sender - The initiator of the action
 */
- (IBAction) forwardMessage:(id) sender;

/** Shares video via email.
 
 @param sender - The initiator of the action
 */
- (IBAction) shareEmail:(id) sender;


/** Shows the default content menu using SCPopupMenu.
 
 Default Implementation:
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:self.richMessageKey]) {
        [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via FriendCaller", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward"] andCompletion:^(){
            [self forwardMessage:nil];
        }];
        
        if ([MFMailComposeViewController canSendMail]) {
            [cv addChoiceWithName:NSLocalizedString(@"Email", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via Email", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_email"] andCompletion:^(){
                [self shareEmail:nil];
            }];
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [cv addChoiceWithName:NSLocalizedString(@"Save", @"Choice Title") andSubTitle:NSLocalizedString(@"Save to your Camera Roll", @"Button") andIcon:[UIImage imageNamed:@"ico_image"] andCompletion:^{
                [self saveToAlbum:nil];
            }];
        }
    } else {
        [cv addChoiceWithName:NSLocalizedString(@"Download", @"Choice Title") andSubTitle:NSLocalizedString(@"Download from Server", @"Button") andIcon:[UIImage imageNamed:@"ico_download"] andCompletion:^{
            [[C2CallPhone currentPhone] retrieveObjectForKey:self.richMessageKey];
        }];
        
    }
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        
    }];
    [cv showMenu];

 @param sender - The initiator of the action
 */
- (IBAction) contentAction:(id)sender;

/** Plays video.
 @param sender - The initiator of the action
 */
- (IBAction) play:sender;

/** Pauses video.
 @param sender - The initiator of the action
 */
- (IBAction) pause:(id) sender;

/** Jumps to start.
 @param sender - The initiator of the action
 */
- (IBAction) toStart:(id) sender;

/** Jumps to end.
 @param sender - The initiator of the action
 */
- (IBAction) toEnd:(id) sender;

/** Shows / Hides Player Controls.
 @param sender - The initiator of the action
 */
- (IBAction) toggleControls:(id) sender;

@end
