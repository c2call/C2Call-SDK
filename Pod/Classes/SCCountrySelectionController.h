//
//  SCCountrySelectionController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 15.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Delegates Protocol for Country Selection Control.
 */
@protocol SCCountrySelectionDelegate

/** Provides the selected country and the country code.
 
 @param name - Selected Country Name
 @param code - Selected Country Code
 */
-(void) selectCountry:(NSString *)name withCode:(NSString *)code;

@end

/** Presents a ViewController for User Country Selection.
 */
@interface SCCountrySelectionController : UITableViewController

/** @name Outlets */
/** The SCCountrySelectionDelegate delegate 
 */
@property(nonatomic, weak) IBOutlet id<SCCountrySelectionDelegate>		delegate;


/** @name Actions */
/** Close View Controller
 */
-(IBAction)close:(id)sender;

@end
