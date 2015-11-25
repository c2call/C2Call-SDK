//
//  SCFlexibleToolbarView.h
//  SimplePhone
//
//  Created by Michael Knecht on 21.04.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCFlexibleToolbarView : UIView

@property(nonatomic, weak) IBOutlet UIView      *topView, *toolbarView;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint       *toolbarHeightContraint;

-(BOOL) resizeToolbar:(CGFloat) newHeight;

@end
