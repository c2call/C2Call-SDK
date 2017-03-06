//
//  SCVLCVideoPlayerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 22/07/16.
//
//

#import <UIKit/UIKit.h>

@protocol SCVLCVideoPlayerViewDelegate <NSObject>

@optional
-(void) playerDidStart;
-(void) playerDidPause;
-(void) playerDidStop;


@end

@interface SCVLCVideoPlayerView : UIView

/** Control's View Outlet */
@property (nonatomic, weak) IBOutlet UIView           *controlsView;

/** Broken Link Image Outlet */
@property (nonatomic, weak) IBOutlet UIImageView      *imageBroken;

/** Toggles playback / stop. */
@property (nonatomic, weak) IBOutlet UIButton         *playButton;

/** Timelable Outlet */
@property(nonatomic, strong) IBOutlet UILabel           *timeLabel;

/** LoadingView Outlet */
@property (nonatomic, strong) IBOutlet UIView           *loadingView;

/** Media URL of the Video. */
@property (nonatomic, strong) NSURL                     *mediaUrl;

/** Rich Media Key of the Video. */
@property (nonatomic, strong) NSString                  *mediaKey;

/** Delegate */
@property (nonatomic, weak) id<SCVLCVideoPlayerViewDelegate>  delegate;

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

/** Reset Media Player
 */
-(void) resetPlayer;

+ (BOOL) vlcKitAvailable;

@end
