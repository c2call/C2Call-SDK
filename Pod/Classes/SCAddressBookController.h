//
//  SCAddressBookController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 15.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SCAdTableViewController.h"

/** Presents the standard C2Call SDK iOS Address Book Controller.
 
 The Address Book Controller provides access to the iOS Address Book. 
 It uses the ABAddressBook API but implements its own user interface allowing a better customization.
 
*/
@interface SCAddressBookController : UITableViewController {
    NSMutableArray          *segmentedContacts;
}

@property(nonatomic) ABAddressBookRef       addressBook;
@property(nonatomic, strong) NSArray       *searchResult;


-(BOOL) refreshAddressBook;

@end
