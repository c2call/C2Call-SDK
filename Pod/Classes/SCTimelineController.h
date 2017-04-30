//
//  SCTimelineController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.07.16.
//
//

#import <SocialCommunication/SocialCommunication.h>

@class SCVideoPlayerView, SCPTTPlayer, C2BlockAction, SCVLCVideoPlayerView, MOTimelineEvent, SCTimelineController;

@interface SCTimelineBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *innerContentView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;

@property (atomic, strong) NSString *mediaKey;
@property (nonatomic,strong) NSNumber *eventId;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, weak) SCTimelineController    *controller;

@property (nonatomic) BOOL featured;

-(void) addTapAction:(C2BlockAction *) tapAction;
-(void) addLongpressAction:(C2BlockAction *) longpressAction;
-(void) configureCell:(MOTimelineEvent *) event;

-(IBAction)share:(id)sender;

@end

@interface SCTimelineVideoCell : SCTimelineBaseCell
@property (weak, nonatomic) IBOutlet SCVideoPlayerView *videoView;

@end

@interface SCTimelineBroadcastCell : SCTimelineBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *broadcastInfo;
@property (strong, nonatomic) NSString  *bcastId;

-(void) isLife:(BOOL) isLife;
-(void) onlineUsers:(NSInteger) onlineUsers;

@end

@interface SCTimelineImageCell : SCTimelineBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;

@end

@interface SCTimelineAudioCell : SCTimelineBaseCell

-(IBAction)togglePlayPause:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;

@property (nonatomic, strong) SCPTTPlayer   *player;
@property (nonatomic, strong) C2BlockAction *action;
@property (nonatomic, strong) UITapGestureRecognizer    *tapGesture;

@end

@interface SCTimelineMessageCell : SCTimelineBaseCell

@end

@interface SCTimelineEventCell : SCTimelineBaseCell

@end

@interface SCTimelineLocationCell : SCTimelineBaseCell

@property (weak, nonatomic) IBOutlet UILabel *locationTitle;
@property (weak, nonatomic) IBOutlet UIImageView *locationMapImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end


@protocol SCTimelineControllerDelegate <NSObject>


-(void) timelineControllerDidScroll:(UIScrollView *)scrollView;


@end

@interface SCTimelineController : SCDataTableViewController

@property(nonatomic) int                fetchLimit;
@property(nonatomic) int                fetchSize;

@property(nonatomic, weak) id<SCTimelineControllerDelegate>     delegate;

-(void) refetchResults;
-(void) scrollToTopOnUpdate;

@end
