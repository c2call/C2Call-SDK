//
//  SCTimelineMasterController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07/07/16.
//
//

#import <UIKit/UIKit.h>
#import "SCTimelineController.h"

@interface SCTimelineMasterController : UIViewController<SCTimelineControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak, nonatomic) IBOutlet UIButton *btnAddVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnAddLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnAddAudio;
@property (weak, nonatomic) IBOutlet UIButton *btnAddAlbum;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *attachmentView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewHeight;
@property (weak, nonatomic) IBOutlet UIView *headerView;


- (IBAction) addImage:(id)sender;
- (IBAction) addVideo:(id)sender;
- (IBAction) addLocation:(id)sender;
- (IBAction) addAudio:(id)sender;

@end
