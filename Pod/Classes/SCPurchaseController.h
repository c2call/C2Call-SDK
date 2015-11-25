//
//  SCPurchaseController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 25.06.13.
//
//

#import <UIKit/UIKit.h>

@class SKProduct;

/** A delegate protocol to inform the delegate when a product has been selected.
 */
@protocol SCPurchaseControllerDelegate <NSObject>

/** Will be called when a product has been selected on the tableView
 
 @param product - The product
 */
-(void) didSelectProduct:(SKProduct *)product;

@end

/** Presents the standard C2Call SDK Purchase Controller.

 The Purchase Controller will automatically query the consumable products added to SCStoreObserver from the iTunes Store and present it to the user for purchase.
 The ViewController can be customized and use as stand-alone view controller or as embedded view controller in a master view.
 
 */
@interface SCPurchaseController : UITableViewController

/** @name Properties */
/** The UITableViewCell reusable identifier for the product 
 
 Default is SCPurchaseControllerCell.
 */
@property(nonatomic, strong) NSString       *productCellIdentifier;

/** The SCPurchaseControllerDelegate
 */
@property(nonatomic, weak) id<SCPurchaseControllerDelegate>     delegate;

/** Buy Action for buying the selected product.
 @param sender - The initiator of the action
 */
-(IBAction)buy:(id)sender;

@end
