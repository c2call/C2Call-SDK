//
//  SCGroupVideoCallController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "RTPVideoHandler.h"
#import "C2ExpandViewController.h"

@class ScreenControls;

/** Presents the standard C2Call SDK Group Video Call Controller.
 
 The Group Video Call Controller shows the actual group video call with up to 7 participants.
 
 */

@interface SCGroupVideoCallController : C2ExpandViewController<UIGestureRecognizerDelegate, VideoHandlerDelegate>

/** @name Outlets */
/** References to the Screen Controls. */
@property(nonatomic, strong) IBOutlet ScreenControls      *screenControls;

/** The own camera view. */
@property(nonatomic, weak) IBOutlet UIView                *previewView;

/** UIView Reference to the toolbar view. */
@property(nonatomic, weak) IBOutlet UIView                *barView;

/** UIView Rreference to the inner view. */
@property(nonatomic, weak) IBOutlet UIView                *innerView;

/** UIView Rreference to the embedded screen controls. */
@property(nonatomic, weak) IBOutlet UIView                *controlsView;

/** Background image. */
@property(nonatomic, weak) IBOutlet UIImageView           *backgroundView;

/** Connection Quality Image */
@property(nonatomic, weak) IBOutlet UIImageView           *connectionQualityImage;

/** Toolbar Background Image. */
@property(nonatomic, weak) IBOutlet UIImageView           *barBackgroundView;

/** @name Other Methods */
/** Start Video Player. */
-(void) start;

/** Resizes Video View (fo example on rotate). */
-(void) resize;

/** Shows ScreenControls view. */
-(void) showScreenControls;

/** Hides ScreenControls view. */
-(void) hideScreenControls;

/** Returns the BackgroundImage for the current screen orientation and number of participants
 
 The SCGroupViedoCallCotnroller calls this method to get the current background image, based on the number of active 
 participants and on the current screen size and orientation.
 Overwrite this method, if you want to provide your own background image.
 
 @return The background image
 */
-(UIImage *) backgroundImage;

/** Get the current number of participant views in the group call
 
 @return The number of participant views
 */
-(int) numberOfParticipantViews;

/** @name Actions */
/** HangUp.
 @param sender - The initiator of the action
 */
-(IBAction) hangUp:(id) sender;

/** Mute the Mic.
 @param sender - The initiator of the action
 */
-(IBAction) muteMic:(id)sender;

/** Switches Camera.
 
 Front / Rear / NO Camera
 
 @param sender - The initiator of the action
 */
-(IBAction) switchCamera:(id) sender;

/** Expands / Collapses Video Screen (for iPad only).
 @param sender - The initiator of the action
 */
-(IBAction) toggleVideoScreen:(id) sender;

@end
