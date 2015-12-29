//
//  SCUserProfileController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.05.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** User Profile ViewController of the current User.
 
 This ViewController component presents the User Profile and allows changes to the following User Profile Attributes:
 
    - Firstname
    - Lastname
    - Phone Number for work, mobile, home and other
    - User Image
    
 In addition, the User Profile allows to verify the users callerId and to order a C2Call DID Number.
 
 @see SCUserProfile for programatic access to the user profile
 
 */
@interface SCUserProfileController : UITableViewController

/** @name Outlets */
/** Users Firstname.
 */
@property(nonatomic, weak) IBOutlet UITextField     *firstname;

/** Users Lastname.
 */
@property(nonatomic, weak) IBOutlet UITextField     *lastname;

/** Users Profile Image.
 */
@property(nonatomic, weak) IBOutlet UIButton        *userImageButton;;

/** Work Phone Number.
 */
@property(nonatomic, weak) IBOutlet UITextField     *phoneWork;

/** Mobile Phone Number.
 */
@property(nonatomic, weak) IBOutlet UITextField     *phoneMobile;

/** Home Phone Number.
 */
@property(nonatomic, weak) IBOutlet UITextField     *phoneHome;

/** Other Phone Number.
 */
@property(nonatomic, weak) IBOutlet UITextField     *phoneOther;

/** Users Email Address.
 */
@property(nonatomic, weak) IBOutlet UILabel         *email;

/** Users DID-Number if available.
 */
@property(nonatomic, weak) IBOutlet UILabel         *didnumber;

/** Users callerid if available.
 */
@property(nonatomic, weak) IBOutlet UILabel         *callerid;

/** Users current credit.
 */
@property(nonatomic, weak) IBOutlet UILabel         *credit;

/** @name Actions */
/** TextField didEndEditing action.
 
 @param sender - The initiator of the action
 */
-(IBAction)textFieldDidEndEditing:(id)sender;

/** Selects User Profile Image Action.
 @param sender - The initiator of the action
 */
-(IBAction)selectPhoto:(id)sender;

/** This method will be called on updated userprofile
 
 Overwrite this method to present additional data for the user profile.
 Calling super is required.
 
 */
-(void) refreshUserProfile;

/** Saves User Profile Action.
 @param sender - The initiator of the action
 */
-(IBAction)saveUserProfile:(id)sender;

@end
