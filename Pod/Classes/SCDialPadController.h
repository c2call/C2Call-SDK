//
//  SCDialPadController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Smart Dial Pad Controller.

 The Dial Pad implements a phone keyboard with several enhanced options:
 
    - Global Database for country and area codes: shows the destination country and area while typing the number
    - Automatic price information on the entered target number
    - Support for several international phone number formats
    - Dial Assistant 
    - Country Selector
 */

@interface SCDialPadController : UIViewController

/** @name Outlets */
/** UIView reference to the keyboard view. */
@property (nonatomic, weak) IBOutlet UIView         *keyboardView;

/** UIView reference to the Info Area. */
@property (nonatomic, weak) IBOutlet UIView         *infoView;

/** The actual phone number to display. */
@property (nonatomic, weak) IBOutlet UILabel		*numberField;

/** The comment field shows user hints like dialed country or area. */
@property (nonatomic, weak) IBOutlet UILabel		*commentField;

/** The available user credit label. */
@property (nonatomic, weak) IBOutlet UILabel		*userCredit;

/** The price info for the destination number. */
@property (nonatomic, weak) IBOutlet UITextField    *priceInfoLabel;

/** SMS/Text Messsage Button. */
@property (nonatomic, weak) IBOutlet UIButton				*smsButton;

/** Flag Button for Country Selection shows the flag of the selected country. */
@property (nonatomic, weak) IBOutlet UIButton				*flagButton;

/** @name other Methods */
/** Refreshes price information; will be automatically called on entering a phone number.
 */
-(void) refreshPriceInfo;

/** @name Actions */
/** Shows iOS PeoplePicker controller to pick a number from address book.
 @param sender - The initiator of the action
 */
-(IBAction) showPicker:(id)sender;

/** Calls the entered number.
 @param sender - The initiator of the action
 */
-(IBAction) callNumber:(id)sender;

/** Dials a single digit.
 
 The [sender tag] provides the actual digit.
 
 @param sender - The initiator of the action
 */
-(IBAction) dial:(id)sender;
/** Removes the last digit.
 @param sender - The initiator of the action
 */
-(IBAction) del:(id)sender;

/** Shows the dial assistant.
 @param sender - The initiator of the action
 */
-(IBAction) showDialAssistant:(id)sender;

/** Shows the Call History of the last called numbers.
 @param sender - The initiator of the action
 */
-(IBAction) showCallHistory:(id)sender;

/** Plays a touch tone.
 
 The touch tone will be chosen by the [sender tag] (0-11).
 @param sender - The initiator of the action
 */
-(IBAction) touchTone:(id)sender;

/** Opens the SMS Chat.

 Opens the SMS Chat with the entered phone number.
 
 @param sender - The initiator of the action
 */
-(IBAction) smsAction:(id)sender;

/** Chooses Country Code Action.
 
 Shows the CountrySelection Controller.
 
 @param sender - The initiator of the action
 */
-(IBAction) chooseCountry:(id)sender;

/** Set the pre-defined number for the number field
 
 @param number - The number to set
 */

-(void) pickNumber:(NSString *) number;

@end
