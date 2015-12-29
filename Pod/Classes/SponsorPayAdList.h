//
//  SponsorPayAdList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 26.10.11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdListProtocol.h"

@class DDXMLElement;

@interface SponsorPayAdList : NSObject<AdListProtocol> {
    NSMutableSet            *adsSeen;
	NSArray                 *adList;
    NSMutableDictionary		*adListByType, *imageCache;
    
	NSString                *queryUrl;
    int                     currentVideoIndex, currentFreeIndex;
    BOOL                    doQuery;
    CFAbsoluteTime      lastRefresh, lastOfferUpdate;
}

@property(strong) NSArray		*adList;
@property(strong) NSMutableDictionary		*adListByType;
@property(strong) NSString		*queryUrl;
@property (nonatomic) BOOL                      refreshCompleted;


-(DDXMLElement *) currentVideoAd;
-(BOOL) nextVideoAd;
-(BOOL) nextFreeAd;
-(DDXMLElement *) currentFreeAd;

-(BOOL) nextBannerAd;
-(id) currentBannerAd;


-(UIImage *) lowresImageForAd:(DDXMLElement *) ad;
-(UIImage *) hiresImageForAd:(DDXMLElement *) ad;
-(NSString *) imageUrlForAd:(id)ad;
-(NSString *) linkForAd:(DDXMLElement *) ad;

-(NSArray *) freeOfferlist;
-(NSArray *) freeSmallOfferlist;
-(NSArray *) videoOfferlist;
-(NSArray *) allOffers;


+(SponsorPayAdList *) currentAdList;
@end
