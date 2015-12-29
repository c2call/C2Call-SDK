//
//  SCCallStatusController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Call Status Controller.
 
 The Call Status Controller will be presented on inbound or outbound calls and shows relevant information on the call.
 
*/
@interface SCCallStatusController : UIViewController

/** @name Outlets */
/** The Callee Name. */
@property (nonatomic, weak) IBOutlet UILabel		*labelName;

/** Call Duration. */
@property (nonatomic, weak) IBOutlet UILabel		*labelDuration;

/** Connection Status. */
@property (nonatomic, weak) IBOutlet UILabel		*labelConnectionState;

/** Data Rate. */
@property (nonatomic, weak) IBOutlet UILabel		*labelDataRate;

/** Media Status (peer / relay). */
@property (nonatomic, weak) IBOutlet UILabel		*labelMediaStatus;

/** Timestamp. */
@property (nonatomic, weak) IBOutlet UILabel		*labelTimestamp;

/** Connection Quality Indicator. */
@property (nonatomic, weak) IBOutlet UIImageView    *connectionQualityImage;

/** Background Image. */
@property (nonatomic, weak) IBOutlet UIImageView    *backgroundImage;

/** Speaker Button. */
@property (nonatomic, weak) IBOutlet UIButton		*speakerButton;

/** Active Members Button (Group Call). */
@property (nonatomic, weak) IBOutlet UIButton		*activeMembersButton;

/** UIView references to the middle part. */
@property (nonatomic, weak) IBOutlet UIView         *middleview;

/** UIView references to the keypad view */
@property (nonatomic, weak) IBOutlet UIView         *keypadViewContainer;

/** @name Other Methods */
/** Sets Status Connected.
 
 Will be called by C2CallAppDelegate.
 */
-(void) setConnected;

/** Dispose View.
 
 Will be called by C2CallAppDelegate.
 */
-(void) dispose;

/** Resets View Controls.
 
 Will be called by C2CallAppDelegate.
 */
-(void) resetStatus;

/** Sets HangUp Status.
 
 Will be called by C2CallAppDelegate.
 */
-(void) setHangUp;

/** Toogles Speaker Action.
 @param sender - The initiator of the action
 */
-(IBAction) speaker:(id)sender;

/** Shows Touch Tone Dial Pad.
 @param sender - The initiator of the action
 */
-(IBAction) showDialPad:(id)sender;

/** Mutes the Mic.
 @param sender - The initiator of the action
 */
-(IBAction) muteMic:(id)sender;

/** Shows Active Members in a Group Call.
 @param sender - The initiator of the action
 */
-(IBAction) activeMembers:(id)sender;

/** HangUp.
 @param sender - The initiator of the action
 */
-(IBAction) hangUp:(id) sender;

/** @name Static Methods */
/** Creates a new Instance.
 
 Will be called by C2CallAppDelegate.
 
 @return SCCallStatusController instance
 */
+(SCCallStatusController *) new;

/** References to the current active instance.
 
 @return SCCallStatusController instance or nil
 */
+(SCCallStatusController *) instance;

@end
