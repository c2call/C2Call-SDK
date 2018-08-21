//
//  SCWallet.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.04.18.
//

#import "SCVendor.h"

typedef NS_ENUM(NSUInteger, SCWalletReasonCode)
{
    REWARD_WATCH_CAMPAIN = 0,
    REWARD_PICKUP_POINTS = 1,
    ACTIVITY_CREATE_VENDOR = (100 + 0),
    ACTIVITY_VENDOR_PURCHASE_POINTS = (100 + 1),
    ACTIVITY_USER_PURCHASE_POINTS = (100 + 2),
    ACTIVITY_USER_ROLLBACK_FROM_ERROR = (100 + 3),
    ACTIVITY_TRANSFER_POINTS = (100 + 4),
    ACTIVITY_REIMBURSE_VENDOR_POINTS = (100 + 5),
    ACTIVITY_REDEEM_VOUCHER = (100 + 6),
    REDEEM_CAMPAIN_PRODUCT = (1000 + 0),
    REDEEM_CALL_CREDIT = (1000 + 1),
    REDEEM_EXTERNAL_POINTS = (1000 + 2),
    REDEEM_TRANSFER_POINTS = (1000 + 3),
    REDEEM_VENDOR_CAMPAIGN = (1000 + 4)
};


@interface SCWallet : SCLoyaltyBase

@property(nonatomic) NSInteger      walletPoints;

-(BOOL) purchasePoints:(NSUInteger) points amount:(NSInteger) amount currency:(NSString *_Nonnull) currency token:(NSString *_Nonnull) token withReference:(NSString *_Nonnull) reference withResult:(NSMutableDictionary *_Nullable) apiResult;
-(NSString *) preparePayUPurchase:(NSString *) xml withResult:(NSMutableDictionary *) apiResult;
-(BOOL) confirmPayUPurchase:(NSString *) xml withResult:(NSMutableDictionary *) apiResult;

-(BOOL) redeemVoucher:(NSString *_Nonnull) voucherCode withResult:(NSMutableDictionary *_Nullable) apiResult;
-(BOOL) transferPoints:(NSUInteger) points toUser:(NSString *_Nonnull) userid withResult:(NSMutableDictionary *_Nullable) apiResult;
-(BOOL) redeemPointsForCallCredit:(NSUInteger) points withResult:(NSMutableDictionary *_Nullable) apiResult;
-(BOOL) redeemPoints:(NSUInteger) points reason:(SCWalletReasonCode) reason reference:(NSString *_Nonnull) reference withResult:(NSMutableDictionary *_Nullable) apiResult;
-(void) reloadWalletHistoryWithCompletionHandler:(void (^_Nullable)(BOOL success)) completion;
-(void) requestStripeEphemeralKey:(NSString *_Nonnull) apiVersion withCompletionHandler:(void (^_Nullable)(NSString *_Nullable jsonString, int resultCode, NSString *_Nullable comment)) completion;

-(double) convertCurrency:(double) amount srcCurrency:(NSString *_Nonnull) srcCurrency targetCurrency:(NSString *_Nonnull) targetCurrency;
-(double) priceForPoints:(NSUInteger) points withCurrency:(NSString *_Nonnull) currency;
-(NSInteger) pointsForValue:(NSUInteger) value withCurrency:(NSString *_Nonnull) currency;


/**
 Valid Keys:
    - tid
    - Value (Integer)
    - OwnerId
    - ContentType
    - TStamp (UInt64)
    - Reference
    - ReferenceType (Integer) -> siehe #defines
    - Description
 */
-(NSArray<NSDictionary<NSString *, id> *> *_Nonnull) walletHistory;

+(instancetype _Nonnull ) instance;
+(instancetype _Nullable ) vendorInstance;

+(void) dispose;

@end
