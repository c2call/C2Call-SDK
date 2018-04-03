//
//  SCWallet.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.04.18.
//

#import "SCVendor.h"

#define REWARD_WATCH_CAMPAIN                0
#define REWARD_PICKUP_POINTS                1

#define ACTIVITY_CREATE_VENDOR              (100 + 0)
#define ACTIVITY_VENDOR_PURCHASE_POINTS     (100 + 1)
#define ACTIVITY_USER_PURCHASE_POINTS       (100 + 2)
#define ACTIVITY_USER_ROLLBACK_FROM_ERROR   (100 + 3)
#define ACTIVITY_TRANSFER_POINTS            (100 + 4)
#define ACTIVITY_REIMBURSE_VENDOR_POINTS    (100 + 5)

#define REDEEM_CAMPAIN_PRODUCT              (1000 + 0)
#define REDEEM_CALL_CREDIT                  (1000 + 1)
#define REDEEM_EXTERNAL_POINTS              (1000 + 2)
#define REDEEM_TRANSFER_POINTS              (1000 + 3)
#define REDEEM_VENDOR_CAMPAIGN              (1000 + 4)


@interface SCWallet : SCLoyaltyBase

@property(nonatomic) NSInteger      walletPoints;

-(BOOL) transferPoints:(NSUInteger) points toUser:(NSString *_Nonnull) userid withResult:(NSMutableDictionary *_Nullable) apiResult;
-(BOOL) redeemPointsForCallCredit:(NSUInteger) points withResult:(NSMutableDictionary *_Nullable) apiResult;
-(BOOL) redeemPoints:(NSUInteger) points reason:(NSString *_Nonnull) reason reference:(NSString *_Nonnull) reference withResult:(NSMutableDictionary *_Nullable) apiResult;
-(void) reloadWalletHistoryWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;

-(NSArray<NSDictionary *> *_Nonnull) walletHistory;

+(instancetype _Nonnull ) instance;
+(instancetype _Nullable ) vendorInstance;

+(void) dispose;

@end
