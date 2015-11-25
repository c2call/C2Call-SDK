//
//  SCOfferwallController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.05.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Offerwall Controller.
 
 The Offerwall Controller shows an offerwall of rewarded offers from your AdNetworks. 
 C2Call SDK supports offers from Flurry, Aarki, RadiumOne and SponsorPay.
 
 */

@interface SCOfferwallController : UITableViewController

/** @name Outlets */
/** Label No offers available. */
@property(nonatomic, weak) IBOutlet UILabel         *labelNoOffers;
/** UIView refrerence for No Offers Label. */
@property(nonatomic, strong) IBOutlet UIView        *noOffersView;

/** @name Other Methods */
/** Hides NoOffers View. */
-(void) hideNoOffers;

/** Shows NoOffers View. */
-(void) showNoOffers;

/** Prepares the AdList for presentation. 
 
 Default Implementation :

    // Make sure to do that in main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *list = [AdManager instance].adList;
        if ([list count] > 0) {
            adList = [NSArray arrayWithArray:list];
            [self hideNoOffers];
        } else {
            [self showNoOffers];
        }
        [self.tableView reloadData];
    });
 

 */
-(void) prepareAdList;

@end
