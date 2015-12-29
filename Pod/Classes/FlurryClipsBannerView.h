//
//  FlurryClipsBannerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 25.10.11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomEventsBannerView.h"

@class FlurryVideoOffer;

@interface FlurryClipsBannerView : CustomEventsBannerView {
    BOOL                    validOffer;
}

-(BOOL) hasValidOffer;

@property(nonatomic) BOOL validOffer;

@end
