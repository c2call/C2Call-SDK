//
//  UIViewController+AdView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (AdSpace)

-(void) initAdSpace;
-(void) attachAdSpaceView:(UIView *)v;
-(void) showAdSpace;
-(void) hideAdSpace;
-(UIView *) adSpace;

@end
