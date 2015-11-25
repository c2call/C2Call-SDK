//
//  SCPasswordMailController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 21.07.13.
//
//

#import <UIKit/UIKit.h>

/** Standard Controller for forgot password mails
 
 The user will receive an email with a link to reset his password.
 
 */
@interface SCPasswordMailController : UIViewController

/** @name Properties */
/** EMail Address for Password Mail */
@property(nonatomic, weak) IBOutlet UITextField         *emailAddress;

/** The user will be prompted with an info text, after sending the password email.
 
 @param infoText - Message text to prompt
 @param delay - hide message text after delay
 */
-(void) showPromptWithText:(NSString *) infoText hideAfterDelay:(NSTimeInterval) delay;

/** The user will be prompted with an info text, the controller will be closed after a delay
 
 @param infoText - Message text to prompt
 @param delay - close controller after delay
 */
-(void) showPromptWithText:(NSString *) infoText closeAfterDelay:(NSTimeInterval) delay;

/** Submit the password email
 
 @param sender - The actual initator of the action.
 */
-(IBAction) submitPasswordEMail:(id) sender;

@end
