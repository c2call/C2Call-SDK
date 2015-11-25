//
//  SCLoginController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 15.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@class EditCell;

/** Presents the C2Call SDK Standard Login Controller.
 */
@interface SCLoginController : UITableViewController<UITextFieldDelegate>

/** @name Outlets */
/** The users email address. */
@property(nonatomic, weak) IBOutlet EditCell            *email;

/** The users password. */
@property(nonatomic, weak) IBOutlet EditCell            *password;

/** Forgot password button. */
@property(nonatomic, weak) IBOutlet UIButton            *forgotPasswordButton;

/** @name Actions */
/** Login Action.
 @param sender - The initiator of the action
 */
-(IBAction) loginUser:(id) sender;


/** @name Complete Actions */
/** Sets an Action Block to be called after login is done.
 @param action - The Action Block
 */
-(void) setLoginDoneAction:(void (^)())_action;


/** @name Handle Prompt Methods */
/** Removes a visisble prompt.
 */
-(void) resetPrompt;

/** Shows an info prompt to the user.
 
 @param text - Text Information to prompt
 */
-(void) showPrompt:(NSString *) text;

@end
