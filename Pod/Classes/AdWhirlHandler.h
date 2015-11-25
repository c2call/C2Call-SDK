//
//  AdWhirlHandler.h
//  C2CallPhone
//
//  Created by Michael Knecht on 02.05.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C2BlockAction.h"

@interface C2CustomAdView : UIView {
    UIView *currentBannerView;
    BOOL    replacing;
}

- (void)replaceBannerViewWith:(UIView*)bannerView;

@end

@interface AdWhirlHandler : NSObject<UIGestureRecognizerDelegate> {
    UIView                  *parentView, *shrinkView, *secondShrinkView;
    C2CustomAdView             *adView;
    UITapGestureRecognizer      *tapRecognizer;

    NSString                *currentBannerNetwork;
    BOOL                    showAd, bannerLoaded, newBanner, useDownloadOffers, ignoreAds;
}

@property(nonatomic, strong) UIView                                  *parentView, *shrinkView, *secondShrinkView;
@property (nonatomic,strong) C2CustomAdView                          *adView;
@property (nonatomic,strong) NSString                                *currentBannerNetwork;
@property(nonatomic, strong) IBOutlet    UITapGestureRecognizer      *tapRecognizer;
@property(nonatomic) BOOL showAd, useDownloadOffers, active;
            
-(void) setParentView:(UIView *) _parentView andShrinkView:(UIView *) _shrinkView;
-(void) setParentView:(UIView *) _parentView andShrinkView:(UIView *) _shrinkView andSecondShrinkView:(UIView *) _secondShrinkView;
-(void) setParentView:(UIView *) _parentView showAction:(C2BlockAction *) show hideAction:(C2BlockAction *) hide;

-(void) viewWillAppear;
-(void) viewWillDisappear;
-(void) showAdBanner;
-(void) hideAdBanner;
-(void) showAdBanner:(BOOL) animate;
-(void) hideAdBanner:(BOOL) animate;
-(void) removeAdBanner;
-(void) willResignActive;
-(void) didBecomeActive;
-(void) refreshAd;

+(BOOL) hasCredit;
+(BOOL) isAdWhirlEnabled;
+(AdWhirlHandler *) handler;
+(void) disposeHandler;

@end
