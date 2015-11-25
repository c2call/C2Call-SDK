//
//  CustomEventsBannerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 25.10.11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomEventsBannerView : UIView<UIGestureRecognizerDelegate> {
}

@property (nonatomic, weak) IBOutlet UIImageView         *iconImage, *backgroundImage, *offerwallImage;
@property (nonatomic, weak) IBOutlet UILabel             *labelTitle, *labelSubtitle, *labelDescription;
@property (nonatomic, strong) UITapGestureRecognizer       *tapRecognizer;
@property (nonatomic, strong) NSTimer                      *labelTimer;

-(void) startLabelAnimation;

@end
