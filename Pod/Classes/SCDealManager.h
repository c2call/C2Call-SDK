//
//  SCDealManager.h
//  C2CallPhone
//
//  Created by Michael Knecht on 05.04.18.
//

#import <Foundation/Foundation.h>

@class CLLocation, SCLoyaltyCampaign;

#define C2DEAL_KEY_id @"id"
#define C2DEAL_KEY_campaignId @"campaignId"
#define C2DEAL_KEY_CampaignDescription @"CampaignDescription"
#define C2DEAL_KEY_campaignType @"campaignType"
#define C2DEAL_KEY_name @"name"
#define C2DEAL_KEY_vendorId @"vendorId"
#define C2DEAL_KEY_ownerId @"ownerId"
#define C2DEAL_KEY_startDate @"startDate"
#define C2DEAL_KEY_endDate @"endDate"
#define C2DEAL_KEY_mediaKey @"mediaKey"
#define C2DEAL_KEY_reward @"reward"
#define C2DEAL_KEY_locationName @"locationName"
#define C2DEAL_KEY_latitude @"latitude"
#define C2DEAL_KEY_longitude @"longitude"
#define C2DEAL_KEY_active @"active"
#define C2DEAL_KEY_userDeal @"userDeal"
#define C2DEAL_KEY_pointsWatched @"pointsWatched"
#define C2DEAL_KEY_pointsPickup @"pointsPickup"
#define C2DEAL_KEY_dealTStamp @"dealTStamp"
#define C2DEAL_KEY_dealCompleted @"dealCompleted"

@interface SCDealManager : NSObject

-(void) reloadAllWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;
-(void) reloadVendorDealsWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;
-(void) reloadUserDealsWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;
-(void) reloadActiveDealsWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;
-(void) reloadReviewDealsWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;

-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) activeDealsForTags:(NSArray *_Nonnull) taglist;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) activeDealsForLocation:(CLLocation *_Nonnull)location radius:(int) km;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) activeDealsForUser;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) activeDeals;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) reviewDeals;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) activeOnlineDeals;

-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) activeCampaignsForVendor;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) inactiveCampaignsForVendor;
-(NSArray<NSDictionary<NSString *, id> *> *_Nullable) allVendorCampaigns;

-(CLLocation *_Nullable) locationForDeal:(NSDictionary<NSString*, id> *_Nonnull) deal;

-(BOOL) retrieveCampaignForDeal:(NSDictionary<NSString*, id> *_Nonnull) deal completion:(void (^_Nullable)(SCLoyaltyCampaign *campaign)) completion;
-(BOOL) retrieveCampaignForDeal:(NSDictionary<NSString*, id> *_Nonnull) deal loadMedia:(BOOL) loadMedia completion:(void (^_Nullable)(SCLoyaltyCampaign *campaign)) completion;

+(instancetype _Nonnull) instance;

@end
