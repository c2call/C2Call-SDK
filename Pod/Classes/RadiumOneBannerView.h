//
//  RadiumOneBannerView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 25.10.11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import "CustomEventsBannerView.h"

@interface RadiumOneBannerView : CustomEventsBannerView {
    NSString                *adType;
    BOOL                    validOffer;
}
- (id)initWithFrame:(CGRect)frame andAdType:(NSString *) _adtype;

@property(nonatomic, strong) NSString                *adType;
@property(nonatomic) BOOL                            validOffer;

@end
