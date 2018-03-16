//
//  SCLinkPreview.h
//  AWSCore
//
//  Created by Manish Kungwani on 14/02/18.
//

#import <UIKit/UIKit.h>
#import "SCLinkPreviewContentView.h"

@interface SCLinkPreview : UIView

@property (strong, nonatomic) IBOutlet SCLinkPreviewContentView *contentView;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;

@end
