//
//  SCReplyToContainer.h
//  C2CallPhone
//
//  Created by Michael Knecht on 26.12.17.
//

#import <UIKit/UIKit.h>

@class SCReplyToContentView;

@interface SCReplyToContainer : UIView

@property(weak, nonatomic) IBOutlet SCReplyToContentView    *replyToView;
@property(weak, nonatomic) IBOutlet UIStackView             *stackView;
@property(strong, nonatomic) IBOutlet UITapGestureRecognizer    *replyToTap;
@end
