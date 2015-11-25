//
//  TrialpayBannerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 08.07.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import "CustomEventsBannerView.h"

@interface TrialpayBannerView : CustomEventsBannerView {
    BOOL                    validOffer;
}

@property(nonatomic) BOOL                            validOffer;

@end
