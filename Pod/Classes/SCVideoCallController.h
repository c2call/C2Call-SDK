//
//  SCVideoCallController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "C2ExpandViewController.h"

@class ScreenControls, EAGLViewController, EAGLView;

/** Presents the standard C2Call SDK Video Call Controller.
 
 The Video Call Controller shows the actual video call.
 
 */
@interface SCVideoCallController : C2ExpandViewController<UIGestureRecognizerDelegate>

/** @name Outlets */
/** References to the Screen Controls. */
@property(nonatomic, strong) IBOutlet ScreenControls        *screenControls;

/** The own camera view. */
@property(nonatomic, weak) IBOutlet UIView                *previewView;

/** UIView Rreference to the inner view. */
@property(nonatomic, weak) IBOutlet UIView                *innerView;

/** UIView reference to the embeeded screen controls. */
@property(nonatomic, weak) IBOutlet UIView                *controlsView;

/** The actual remote video view. */
@property(nonatomic, weak) IBOutlet EAGLView              *videoView;

/** Background Image. */
@property(nonatomic, weak) IBOutlet UIImageView           *backgroundView;

/** Connection Quality Image. */
@property(nonatomic, weak) IBOutlet UIImageView           *connectionQualityImage;

/** References to the OpenGles View Controller. */
@property(nonatomic, strong) IBOutlet EAGLViewController    *eaglViewController;

/** Use letterboxFormat for Video which doesn't fit the aspect ratio */
@property(nonatomic) BOOL                                  useLetterboxFormat;

/** @name Other Methods */

/** Set the completion handling.
 
 Set your own code block to initate action after the call has been finished. 
 Typically, the video controller will be removed from the UI.
 
 @param handler - Code Block to execute when the call is finished
 */
-(void) setCompletionHandler:(void (^)())handler;

/** Stop the video player 
 
 After stopping, the VideoController will be disposed and the completion handler will be excecuted.
 It will not hang up the actual call.
 
 */
-(void) stop;

/** Resizes Video View (fo example on rotate). */
-(void) resize;

/** Shows ScreenControls view. */
-(void) showScreenControls;

/** Hides ScreenControls view. */
-(void) hideScreenControls;

/** Capture Image of current VideoCall 
 @return Image of the call
 */
-(UIImage *) captureImage;

/** @name Actions */
/** HangUp.
 @param sender - The initiator of the action
 */
-(IBAction) hangUp:(id) sender;

/** Mutes the Mic.
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
