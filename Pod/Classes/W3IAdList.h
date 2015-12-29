//
//  W3IAdList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.10.12.
//
//

#import <Foundation/Foundation.h>
#import "AdListProtocol.h"

@interface W3IAdList : NSObject {
    CFAbsoluteTime      lastRefresh, lastOfferUpdate;
}

@property(nonatomic, strong) NSString *queryUrl;
@property(nonatomic, strong) NSArray  *adlist;
@property(nonatomic, strong) NSMutableDictionary    *imageCache;
@property(nonatomic, strong) NSMutableSet            *adsSeen;
@property(nonatomic, strong) id                 currentBannerAd, currentAd;
@property(nonatomic, strong) NSDictionary       *session;
@property (nonatomic) BOOL                      refreshCompleted, sessionError;

-(BOOL) createSession;
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

-(NSArray *) allOffers;

+(W3IAdList *) currentAdList;

@end
