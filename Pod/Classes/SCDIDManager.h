//
//  SCDIDManager.h
//  C2CallPhone
//
//  Created by Michael Knecht on 20/04/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    DID_ORDER_SUCCESS,
    DID_ORDER_ERROR
} SCDIDManagerResult;

typedef enum {
    DSS_TYPE_UNKNOWN,
    DSS_TYPE_ORDER_IN_PROGRESS,
    DSS_TYPE_ORDER_CONFIRMED,
    DSS_TYPE_ORDER_ERROR,
    DSS_TYPE_REORDER_ERROR,
    DSS_TYPE_FREE_TRIAL,
    DSS_TYPE_ADDRESS_VERIFICATION_IN_PROGRESS,
    DSS_TYPE_ADDRESS_VERIFICATION_CONFIRMED,
    DSS_TYPE_RENEWAL_IN_PROGRESS,
    DSS_TYPE_RENEWAL_REJECTED,
    DSS_TYPE_RENEWAL_FREE_TRIAL_REJECTED,
    DSS_TYPE_RENEWAL_CONFIRMED,
    DSS_TYPE_DEACTIVATION_IN_PROGRESS,
    DSS_TYPE_DEACTIVATION_CONFIRMED,
    DSS_TYPE_CANCELATION_IN_PROGRESS,
    DSS_TYPE_CANCELATION_CONFIRMED
} SCDIDSubscriptionStatus;

@class SKPaymentTransaction;

//<PriceModel Name="F31D_O1M_R1M_USD" FreePeriod="1" IntervalUnitFree="MONTH" OrderPeriod="1" IntervalUnitOrder="MONTH" RenewalPeriod="1" IntervalUnitRenewal="MONTH" PriceOrder="99" PriceRenewal="99" Currency="USD"/>
@interface SCDIDPriceModel : NSObject

-(instancetype) initWithPriceModel:(NSString *) priceModel;

-(NSString *) name;
-(NSInteger) freePeriod;
-(NSString *) intervalUnitFree;
-(NSInteger) orderPeriod;
-(NSString *) intervalUnitOrder;
-(NSInteger) renewalPeriod;
-(NSString *) intervalUnitRenewal;
-(NSInteger) priceOrder;
-(NSInteger) priceRenewal;
-(NSString *) currency;

@end

@interface SCDidInfo : NSObject

-(NSDate *) activationDate;
-(NSDate *) freeTrialExpireDate;
-(NSDate *) deactivationDate;
-(NSDate *) expiryDate;
-(SCDIDPriceModel *) priceModel;
-(NSString *) country;
-(NSString *) countryISOCode;
-(NSString *) countryCode;
-(NSString *) areaCode;
-(NSString *) provider;
-(SCDIDSubscriptionStatus) subscriptionStatus;

@end

@interface SCDIDManager : NSObject

@property(nonatomic, readonly) NSDate       *lastDataUpdate;

-(void) refreshDidManagerData:(void (^)(BOOL success))completion;

-(NSArray *) availableCountryCodes;
-(NSArray *) areacodesForCountryCode:(NSString *)countryCode;
-(NSString *) countryForCountryCode:(NSString *) countryCode;

-(BOOL) orderNumber:(int) didnum forCountryCode:(NSString *) countrycode areacode:(NSString *) areaCode pricemodel:(NSString *) priceModel paymentTransaction:(SKPaymentTransaction *)transaction completion:(void (^)(SCDIDManagerResult result))completion;
-(BOOL) orderReservedNumber:(int) didnum forCountryCode:(NSString *) country number:(NSString *) number pricemodel:(NSString *) priceModel paymentTransaction:(SKPaymentTransaction *)transaction completion:(void (^)(SCDIDManagerResult result))completion;
-(BOOL) extendNumber:(int) didnum forCountry:(NSString *) country pricemodel:(NSString *) priceModel paymentTransaction:(SKPaymentTransaction *)transaction completion:(void (^)(SCDIDManagerResult result))completion;
-(BOOL) didCancelNumber:(int) didnum completion:(void (^)(SCDIDManagerResult result))completion;
-(BOOL) didReorderNumber:(int) didnum completion:(void (^)(SCDIDManagerResult result))completion;

-(BOOL) reserveNumberForCountryCode:(NSString *) countryCode areacode:(NSString *) areaCode completion:(void (^)(SCDIDManagerResult result, NSString *number))completion;

-(SCDidInfo *) didInfo:(NSUInteger) didnum;

+(instancetype) instance;

@end
