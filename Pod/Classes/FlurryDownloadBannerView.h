//
//  FlurryDownloadBannerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12/15/11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import "CustomEventsBannerView.h"

@class FlurryOffer;

@interface FlurryDownloadBannerView : CustomEventsBannerView {
    FlurryOffer             *flurryOffer;
    BOOL                    validOffer;
}

@property(nonatomic, strong) FlurryOffer            *flurryOffer;
@property(nonatomic) BOOL                            validOffer;

@end
