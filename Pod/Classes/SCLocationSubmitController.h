//
//  SCLocationSubmitController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@class MKMapView, FCLocation, FCPlaces, FCGeocoder, CLLocationManager;

/** Presents the standard C2Call SDK Location Submit Controller.
 
 Captures the current location or nearby places for submission.
 */

@interface SCLocationSubmitController : UITableViewController

/** @name Outlets */
/** UIView containing Header Information. */
@property(nonatomic, strong) IBOutlet UIView        *headerView;

/** The actual MapView. */
@property(nonatomic, weak) IBOutlet MKMapView     *mapView;

/** UILabel to display the current Address. */
@property(nonatomic, weak) IBOutlet UILabel       *myAddress;

/** Submits Action Button. */
@property(nonatomic, weak) IBOutlet UIButton      *submitButton;

/** Targets UserId for submission.
 
 If no submit action has been set, clicking on the submit button will submit the location to the target user.
 */
@property(nonatomic, strong) NSString   *targetUserid;

/** @name Actions */
/** Submits the location or triggers the Submit Action.
 @param sender - The initiator of the action
 */
-(IBAction)sendLocation:(id)sender;

/** Closes the view or triggers the Cancel Action.
 @param sender - The initiator of the action
 */
-(IBAction)closeView:(id)sender;

/** Sets the Submit Action. 
 Example:
 
    [controller setSubmitAction:^(NSString *key) {
        [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:targetUser];
        [self.navigationController popViewControllerAnimated:YES];
    }];

 @param submitAction - The Action Block
 */
-(void) setSubmitAction:(void (^)(NSString *)) submitAction;

/** Sets the Cancel Action. 
 Example:
 
    [controller setCancelAction:^(NSString *key) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
 
 @param cancelAction - The Action Block
 */
-(void) setCancelAction:(void (^)()) cancelAction;

@end
