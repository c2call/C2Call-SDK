//
//  SCAbstractRegistrationController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.05.14.
//
//

#import <UIKit/UIKit.h>
#import "SCCountrySelectionController.h"

@class EditCell, C2TapImageView;

@interface SCAbstractRegistrationController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSString            *countryName, *countryCode;
    BOOL                registrationInProgress;
}

/** @name Outlets */
/** The Users Email Address.
 */
@property(nonatomic, weak) IBOutlet EditCell            *email;

/** The Users Phone Number.
 */
@property(nonatomic, weak) IBOutlet EditCell            *phoneNumber;

/** The Users Password.
 */
@property(nonatomic, weak) IBOutlet EditCell            *password1;

/** The Users Password (re-enter).
 */
@property(nonatomic, weak) IBOutlet EditCell            *password2;

/** The Users Country (automatically determined).
 */
@property(nonatomic, weak) IBOutlet UITableViewCell     *country;

/** The Users Firstname.
 */
@property(nonatomic, weak) IBOutlet UITextField         *firstName;

/** The Users Lastname.
 */
@property(nonatomic, weak) IBOutlet UITextField         *lastName;

/** The Users Profile Image.
 */
@property(nonatomic, weak) IBOutlet UIButton            *imageButton;

/** @name Actions */
/** Register User Action.
 */
-(void) performUserRegistration;

/** Callback for register result
 
 This method will be called after registration success or failure
 
 @param status - Registration result status code
 @param statusText - Registration result status text message
 
 */
-(void) handleRegisterResult:(int) status comment:(NSString *)statusText;


@end
