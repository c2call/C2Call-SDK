//
//  SCDialButton.h
//  C2CallPhone
//
//  Created by Michael Knecht on 02.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface SCDialButton : UIButton


@property(nonatomic, strong) UIColor        *baseColor; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *baseColor_h; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *baseColor_s; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *baseColor_d; UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor        *baseColor2; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *baseColor2_h; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *baseColor2_s; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *baseColor2_d; UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor        *numberTextColor; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *smallTextColor; UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIFont         *numberTextFont; UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont         *smallTextFont; UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) NSString       *numberText, *smallText;
@property(nonatomic) BOOL                   isDeleteButton, isAddContactButton, isCallButton;

@end
