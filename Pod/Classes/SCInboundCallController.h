//
//  SCInboundCallController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Inbound Call Controller.
 
 C2CallAppDelegate will present the Inbound Call Controller on inbound calls.
 This allows the user to take or reject the call.
 
 */

@interface SCInboundCallController : UIViewController

/** @name Properties */
/** Remotes Party Userid or number. */
@property(nonatomic, strong) NSString			*remoteParty;

/** @name Outlets */
/** Remotes Party Name. */
@property(nonatomic, weak)  IBOutlet UILabel	*name;

/** Label VideoCall. */
@property(nonatomic, weak)  IBOutlet UILabel	*labelVideoCall;

/** UIView Reference to the Button Set showing the VideoCall button. */
@property(nonatomic, weak)  IBOutlet UIView     *videoButtons;

/** UIView Reference to the Button Set showing only regular call button. */
@property(nonatomic, weak)  IBOutlet UIView     *audioButtons;

/** Background Image. */
@property(nonatomic, weak)  IBOutlet UIImageView   *backgroundImage;

/** @name Actions */
/** Takes Call Action. 
 @param sender - The initiator of the action
 */
-(IBAction) takeCall:(id) sender;

/** Takes VideoCall Action.
 @param sender - The initiator of the action
 */
-(IBAction) takeVideoCall:(id) sender;

/** Rejects Call Action.
 @param sender - The initiator of the action
 */
-(IBAction) rejectCall:(id) sender;

/** @name Static Methods */
/** Creates a new Instance.
 
 Will be called by C2CallAppDelegate.
 
 @return SCInboundCallController instance
 */
+(SCInboundCallController *) new;

/** References to the current active instance.
 
 @return SCInboundCallController instance or nil
 */
+(SCInboundCallController *) instance;

@end
