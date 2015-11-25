//
//  SCPromptController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Prompt Controller.
 
 Typical Prompt is "Online (Wifi)", "Offline".
 */
@interface SCPromptController : UIViewController {    
}

/** @name Static Methods */
/** Shows the Message Prompt.
 
 @param prompt - The Message to prompt
 @param parentView - ParentView
 @param t - Timeout in Seconds to disappear
 */
+(void) promptController:(NSString *) prompt parentView:(UIView *)parentView timeout:(NSTimeInterval) t;

@end

