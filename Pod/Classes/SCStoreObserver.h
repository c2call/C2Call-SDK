//
//  SCStoreObserver.h
//  C2CallPhone
//
//  Created by Michael Knecht on 26.06.13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef enum {
    SC_CURRENCY_USD,
    SC_CURRENCY_EUR,
    SC_CURRENCY_GBP
} SCUserCreditCurrency;

/** SCStoreObserver is an SKPaymentTransactionObserver handling StoreKit transactions.
 
 Any purchase transaction will result in an action to add credit to the users account. 
 For this, the developer has to specific the products first which are available for purchase.
 Please see the StoreKit Guide for more information on how to add product for Apple InApp purchase.
 All product must be consumable items. Recurring transactions are not supported yet.
 Please use the SCPurchaseController to initiate any purchase transactions.
 
 
 */
@interface SCStoreObserver : NSObject<SKPaymentTransactionObserver>


/** Add the products available for InApp purchase in that app.
 
 In iTunes Connect you can create consumable products at a certain Tier price. 
 For every product created in iTunes Connect, that product has to be added here with Product ID and corresponding value in cent credits for the user.
 
 @param identifier - The iTunes Connect Product Id
 @param valueInCents - The cent value the user will get in his account, when purchaseing this product
 @param currency - The currency for the credit (EUR / USD / GBP)
 
 */
-(void) addConsumableProduct:(NSString *) identifier creditValue:(int) valueInCents currency:(SCUserCreditCurrency) currency;

/** Returns a set of product ids added as consumable product.
 
 @return The product ids.
 */
-(NSSet*) productIds;

/** Returns the Product NSDictionary for the specific product id.
 
 The NSDictionary contains the follwoing keys:
 
    - identifier : The Product Id
    - value : The value in cent as NSNumber
    - currency : The currency as NSString (EUR / USD / GBP)
 
 @return The product as NSDictionary.
 */
-(NSDictionary *) productForId:(NSString *) identifier;


/** Check whether there are still open transactions
 
 @return YES / NO
 */
-(BOOL) hasOpenTransactions;

/** Create a new instance of SCStoreObserver
 
 It's recommended to create an instance of SCStoreObserver in application:didFinishLaunching:withOptions: in your AppDelegate.
 This tells the subsystem, that your application is using the StoreKit for InApp purchases.
 
 In application:didFinishLaunching:withOptions: do the following:
 
    // Create a new Instance
    SCStoreObserver *observer = [SCStoreObServer new];
    
    // Add your products
    [observer addConsumableProduct:@"ProductId-1" ceditValue:99 currency:SC_CURRENCY_USD]; // 99 Cent/$ Credit
    [observer addConsumableProduct:@"ProductId-2" ceditValue:500 currency:SC_CURRENCY_USD]; // 5 $ Credit
    [observer addConsumableProduct:@"ProductId-3" ceditValue:99 currency:SC_CURRENCY_EUR];  // 99 Cent/EUR Credit
    [observer addConsumableProduct:@"ProductId-4" ceditValue:500 currency:SC_CURRENCY_EUR]; // 5 EUR Credit
 
 @return An instance of SCStoreObserver
 */
+(instancetype) new;

/** Returns an existing instance of SCStoreObserver or nil
 @return The SCStoreObserver or nil
 */
+(instancetype) instance;
+(void) setInstance:(SCStoreObserver *)observer;

@end

