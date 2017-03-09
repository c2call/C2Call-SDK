//
//  SCBroadcastPlaybackController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 24/07/16.
//
//

#import <UIKit/UIKit.h>

@class SCBroadcast, SCVLCVideoPlayerView;

@interface SCBroadcastPlaybackController : UIViewController

@property (weak, nonatomic) IBOutlet SCVLCVideoPlayerView *videoView;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *infoText;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *timeInfo;

@property (nonatomic, strong) SCBroadcast *broadcast;

-(void) configureView;

@end
