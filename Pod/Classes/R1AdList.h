//
//  R1AdList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 28.09.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdListProtocol.h"

@class DDXMLElement;

@interface R1AdList : NSObject<AdListProtocol> {
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
-(DDXMLElement *) currentFreeAd;
-(BOOL) nextFreeAd;
-(NSArray *) freeOfferlist;
-(NSArray *) freeSmallOfferlist;
-(NSArray *) videoOfferlist;
-(NSArray *) allOffers;

-(NSString *) imageUrlForAd:(DDXMLElement *) ad;

+(R1AdList *) currentAdList;



@end
