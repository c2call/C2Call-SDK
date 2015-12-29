//
//  TapjoyAdList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07.07.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrialpayAdList : NSObject {
    CFAbsoluteTime      lastRefresh, lastOfferUpdate;
}

@property(nonatomic, strong) NSString *queryUrl;
@property(nonatomic, strong) NSArray  *adlist;
@property(nonatomic, strong) NSMutableDictionary    *imageCache;
@property(nonatomic, strong) NSMutableSet            *adsSeen;
@property(nonatomic, strong) id                 currentBannerAd, currentAd;
@property (nonatomic) BOOL                      refreshCompleted;


-(void) refreshAds;
-(BOOL) hasCategory:(NSString *) category forAd:(id) ad;
-(BOOL) isBannerAd:(id) ad;
-(BOOL) nextBannerAd;
-(NSString *) linkForAd:(id) ad;
-(UIImage *) imageForAd:(id) ad;
-(NSString *) imageUrlForAd:(id) ad;
-(NSString *) descriptionForAd:(id) ad;
-(NSString *) titleForAd:(id) ad;
-(NSString *) valueForAd:(id) ad;
-(NSSet *) kindOfAd:(id) ad;
-(BOOL) hasOffers;
-(void) markAsSeen:(id) ad;
-(BOOL) offerSeen:(id) ad;

-(NSArray *) allOffers;

+(TrialpayAdList *) currentAdList;

@end
