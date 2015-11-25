//
//  FlurryAdList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 28.08.12.
//
//

#import <Foundation/Foundation.h>

@interface FlurryAdList : NSObject {
    CFAbsoluteTime      lastRefresh, lastOfferUpdate;
}

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

+(FlurryAdList *) currentAdList;

@end
