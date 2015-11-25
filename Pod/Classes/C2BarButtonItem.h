//
//  C2BarButtonItem.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07.05.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class C2BlockAction;

@interface C2BarButtonItem : UIBarButtonItem<UIGestureRecognizerDelegate> {
    UILongPressGestureRecognizer *longpressGesture;
    
    void (^longpressAction)();
}

@property(nonatomic, strong) C2BlockAction *blockAction;

-(id) initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem andAction:(void (^)(id sender))_action;
-(id) initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style andAction:(void (^)(id sender))_action;
-(id) initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style andAction:(void (^)(id sender))_action;
-(id) initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style andAction:(void (^)(id sender))_action;


-(void) setLongpressAction:(void (^)()) _longpressAction;
-(void) dispose;

@end
