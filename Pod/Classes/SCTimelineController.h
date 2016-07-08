//
//  SCTimelineController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.07.16.
//
//

#import <SocialCommunication/SocialCommunication.h>

@interface SCTimelineBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *innerContentView;
@property (weak, nonatomic) IBOutlet UITextView *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (atomic, strong) NSString *mediaKey;

@end

@interface SCTimelineVideoCell : SCTimelineBaseCell

@end

@interface SCTimelineImageCell : SCTimelineBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;

@end

@interface SCTimelineAudioCell : SCTimelineBaseCell

@end

@interface SCTimelineMessageCell : SCTimelineBaseCell

@end

@protocol SCTimelineControllerDelegate <NSObject>


-(void) timelineControllerDidScroll:(UIScrollView *)scrollView;


@end

@interface SCTimelineController : SCDataTableViewController

@property(nonatomic) int                fetchLimit;
@property(nonatomic) int                fetchSize;

@property(nonatomic, weak) id<SCTimelineControllerDelegate>     delegate;

@end
