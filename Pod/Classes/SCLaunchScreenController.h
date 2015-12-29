//
//  SCLaunchScreenController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 15.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Launch Screen. 
 
 This allows the user choosing between login and registration.
 */
@interface SCLaunchScreenController : UITableViewController

/** @name Unwind Segue Actions */
/** Closing the ViewController via Unwind Segue Action.
 */
-(IBAction)closeViewControllerSegueAction:(UIStoryboardSegue *)segue;

/** Start Login via Facebook, close the ViewController
 
 @param sender - Initiator of the action.
 */
-(IBAction)loginUsingFacebook:(id)sender;

@end
