//
//  C2ActionButton.h
//  C2CallPhone
//
//  Created by Michael Knecht on 02.06.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class C2BlockAction;

@interface C2ActionButton : UIButton

@property(nonatomic, strong) C2BlockAction *blockAction;

-(void) addAction:(void (^)(id sender))_action forControlEvent:(UIControlEvents) event;
-(void) addAction:(void (^)(id sender))_action;

@end
