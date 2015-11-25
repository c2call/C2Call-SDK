//
//  SCVerifyNumberController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.05.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** The SCVerifyNumberController allows to verify the users phone number to be set as callerid.
 
 In order to use the users phone number, as callerId for outbound calls or SMS/Text message, the phone number must be verified as valid and user owned.
 
 This will be done by sending an SMS/Text message with a PIN code or initiating a PIN call to the given phone number. The user then has to enter the PIN in the SCNumberPINController to verify his number.
 
 */
@interface SCVerifyNumberController : UIViewController

/** @name Outlets */
/** The Users Phone Number to verify.

 */
@property(nonatomic, weak) IBOutlet UITextField       *phoneNumber;

/** The Users Country.
 
 */
@property(nonatomic, weak) IBOutlet UILabel           *labelCountry;

/** Button to change the country.
 */
@property(nonatomic, weak) IBOutlet UIButton          *flagButton;

/** @name Handle Prompt Methods */
/** Removes a visisble prompt.
 */
-(void) resetPrompt;

/** Removes a visisble prompt and close the view.
 */
-(void) resetPromptAndClose;

/** Removes a visisble prompt and continue with the next view.
 */
-(void) resetPromptAndContinue;

/** Shows an info prompt to the user.
 */
-(void) showPrompt:(NSString *) text;

/** @name Actions */
/** Verifies Number Action.
 
 The Number will be submitted to the server for PIN SMS or PIN Call verification.

 @param sender - The initiator of the action
 */
-(IBAction) verifyNumber:(id) sender;

/** Verifies Number Action.
 
 The Number will be submitted to the server PIN Call verification.
 
 @param sender - The initiator of the action
 */
-(IBAction) verifyNumberUsingPINCall:(id) sender;

/** Goes back or closes view.
 
 @param sender - The initiator of the action
 */
-(IBAction) back:(id) sender;


/** Select Country Action
 
 @param sender - The initiator of the action
 */
-(IBAction) selectCountry:(id) sender;

@end
