//
//  SCNumberPINController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.05.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Verifies PIN Code received via PIN SMS or PIN Call.
 
 @see SCVerifyNumberController
 */
@interface SCNumberPINController : UIViewController

/** @name Outlets */
/** PIN Code Textfield. */
@property(nonatomic, weak) IBOutlet UITextField       *pinCode;

/** @name Handle Prompt Methods */
/** Removes a visible prompt.
 */
-(void) resetPrompt;

/** Removes a visible prompt and close the view.
 */
-(void) resetPromptAndClose;

/** Shows an info prompt to the user.
 
 @param text - Information to prompt
 @param delayInSeconds - The prompt will be automatically removed after seconds
 */
-(void) showPrompt:(NSString *) text removeAfterDelay:(double)delayInSeconds;

/** @name Actions */
/** Validates PIN Action.
 
 @param sender - The initiator of the action
 */
-(IBAction) validatePIN:(id) sender;

@end
