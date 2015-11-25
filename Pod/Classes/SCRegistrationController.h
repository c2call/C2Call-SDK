//
//  SCRegistrationController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SCCountrySelectionController.h"
#import "SCAbstractRegistrationController.h"

@class EditCell, C2TapImageView;

/** Presents a Registration Controller to the user to register with the C2Call Service.
 
 */
@interface SCRegistrationController : SCAbstractRegistrationController<SCCountrySelectionDelegate>

/** @name Actions */
/** Register User Action.
 @param sender - The initiator of the action
 */
-(IBAction) registerUser:(id) sender;

/** Shows Terms Action.
 @param sender - The initiator of the action
 */
-(IBAction) showTerms:(id) sender;

/** Sets FristResponder Action.
 @param sender - The initiator of the action
 */
-(IBAction) setFirstResponder:(id)sender;

/** @name Complete Actions */
/** Sets an Action Block to be called after registration is done.
 @param action - The Action Block
 */
-(void) setRegisterDoneAction:(void (^)())action;

/** Selects User Profile Image Action.
 @param sender - The initiator of the action
 */
-(IBAction) selectPhoto:(id)sender;

@end
