//
//  SCVideoPlayerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09/07/16.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SCVideoPlayerViewDelegate <NSObject>

@optional
-(void) playerDidFailToLoad;
-(void) playerDidLoad;
-(void) playerReadyToDisplay:(CGRect) videoRect;
-(void) playerDidStop;
-(void) playerDidStart;
-(void) playerDidReachEnd;
-(void) playerProgress:(NSUInteger) progress;

@end


@interface SCVideoPlayerView : UIView

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


/** @name Properties */
/** Player Item; see AVPlayerItem. */
@property (nonatomic, strong) AVPlayerItem              *playerItem;

/** Player; see AVPlayer. */
@property (nonatomic, strong) AVPlayer                  *player;

/** Media URL of the Video. */
@property (nonatomic, strong) NSURL                     *mediaUrl;

/** AVURLAsset of the Video. */
@property (nonatomic, readonly) AVURLAsset              *urlAsset;

/** Rich Media Key of the Video. */
@property (nonatomic, strong) NSString                  *richMessageKey;

/** Video Play Delegate */
@property (nonatomic, weak) id<SCVideoPlayerViewDelegate>   delegate;

/** Video Size if available, else CGSizeZero */
-(CGSize) videoSize;

/** Set the AVAsset directly instead of mediaUrl
 
 Call in MainThread only
 
 @param asset - The media asset. Status must be loaded.
 */
-(void) setMediaAsset:(AVURLAsset *) asset;

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
