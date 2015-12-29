//
//  UDUserInfoCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.05.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C2TapImageView, SCHorizontalLineView;

@interface UDUserInfoCell : UITableViewCell

@property(nonatomic, weak) IBOutlet C2TapImageView     *userImage;
@property(nonatomic, weak) IBOutlet UIImageView        *favoriteImage, *facebookImage;
@property(nonatomic, weak) IBOutlet UILabel            *displayName, *email, *onlineStatus;
@property(nonatomic, weak) IBOutlet UILabel            *statusDuration, *userStatus;
@property(nonatomic, weak) IBOutlet SCHorizontalLineView            *lineView;

@end
