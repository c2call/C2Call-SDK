//
//  SCAdViewContainer.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
@interface SCAdViewContainer : UIView {
    CGFloat     adSpaceHeight;
}

@property(nonatomic, strong) IBOutlet UIView    *adView, *masterView;

-(void) attachAdView:(UIView *) av;
-(NSLayoutConstraint *) addEdgeConstraint:(NSLayoutAttribute)edge superview:(UIView *)superview subview:(UIView *)subview;

-(void) showAdSpace;
-(void) hideAdSpace;
-(void) hideAdSpaceWithCompletion:(void (^)(void))completion;
-(void) toggleAdSpace;

@end
