//
//  SCLinkPreviewContentView.h
//  AWSCore
//
//  Created by Manish Kungwani on 14/02/18.
//

#import <UIKit/UIKit.h>

@interface SCLinkPreviewContentView : UIView

@property (strong, nonatomic) IBOutlet UILabel *linkTitleLbl;
@property (strong, nonatomic) IBOutlet UILabel *linkDescriptionLbl;
@property (strong, nonatomic) IBOutlet UILabel *linkSiteNameLbl;
@property (strong, nonatomic) IBOutlet UIImageView *linkIconView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *linkIconWidth;

-(void)prepareLinkPreviewWithData:(NSDictionary*)metadata;

@end
