//
//  AarkiBannerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 26.10.11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import "CustomEventsBannerView.h"

@interface AarkiBannerView : CustomEventsBannerView {
    BOOL                    validOffer;
}

@property(nonatomic) BOOL                            validOffer;

@end
