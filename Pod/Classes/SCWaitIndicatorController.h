//
//  SCWaitIndicatorController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Wait Indicator Controller.
 
 The Wait Indicator Controller shows a standard wait message with an UIActivityIndicatorView to inform the user that an activity requires some time to process.
 */
 @interface SCWaitIndicatorController : UIViewController

/** @name Outlets */
/** Activity Indicator. */
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView		*activity;

/** Title of the activity to wait for. */
@property(nonatomic, weak) IBOutlet UILabel						*labelMessageTitle;

/** A Wait Message.
 
 Default : "Please wait..."
 */
@property(nonatomic, weak) IBOutlet UILabel						*labelWaitMessage;

/** Auto Hide flag.
 
 Automatically hides after 30 seconds.
 */
@property(nonatomic, assign) BOOL                                   autoHide;

/** @name Show / Hide Methods */
/** Shows Wait Indicator View. 
 
 @param parentView - Parent View showing the Wait Indicator view on.
 */
-(void) show:(UIView *)parentView;

/** Hide View.
 */

-(void) hide;

/** @name Static Methods */
/** Creates an Instance of SCWaitIndicatorController with Title and Wait Message.
 
 @param messageTitle - Title of the Activity
 @param waitMessage - Wait Message, can be nil
 */
+(SCWaitIndicatorController *) controllerWithTitle:(NSString *) messageTitle andWaitMessage:(NSString*) waitMessage;

@end
