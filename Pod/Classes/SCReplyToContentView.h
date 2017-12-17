//
//  SCReplyToContentView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 24.11.17.
//

#import <UIKit/UIKit.h>

@interface SCReplyToContentView : UIView

@property(weak, nonatomic, nullable) IBOutlet UILabel                *replyToName;
@property(weak, nonatomic, nullable) IBOutlet UILabel                *replyToText;
@property(weak, nonatomic, nullable) IBOutlet UIImageView            *replyToIcon;
@property(weak, nonatomic, nullable) IBOutlet UIImageView            *replyToPreviewImage;

@end
