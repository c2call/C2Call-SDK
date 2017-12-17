//
//  SCPopupMenu.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents a standard C2Call SDK Popup Menu.
 
 SCPopupMenu is a convenient PopMenu Control to show menu choices in any ViewController.
 
 Example Code:
     SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"MenuItem") andSubTitle:NSLocalizedString(@"Forward to another FriendCaller user", @"Button") andIcon:[UIImage imageNamed:@"ico_forward"] andCompletion:^{
        [self forwardMessage:nil];
    }];
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        
    }];
    [cv showMenu];


 */

@interface SCPopupMenu : UIViewController

/** Shows a Cancel Button as part of the PopupMenu.
 
 @param name - Name of the Button (e.g. @"Cancel")
 @param completion - The Block executed on Button Click
 
 */
-(void) addCancelWithName:(NSString *)name andCompletion:(void (^)())completion;

/** Shows a Menu Choice with Name, Subtitle and Icon as part of the PopupMenu.
 
 @param name - The Choice Name
 @param subTitle - Sub Title to the Choice Name (optional)
 @param icon - The Choice Icon (optional)
 @param completion - The Block executed on Button Click
 
 */
-(void) addChoiceWithName:(NSString *) name andSubTitle:(NSString *) subTitle andIcon:(UIImage *) icon andCompletion:(void (^)())_completion;

/** Shows PopupMenu.
 */
-(void) showMenu;

/** Hides PopupMenu with completion handler.
 
 For internal use...
 
 @param completion - The Block executed on hide
 */
-(void) hideMenu:(void (^)())_completion;

/** @name Static Methods */
/** Creates an Instance of SCPopupMenu. 
 
 @param parent - Presenting ViewController
 */
+(SCPopupMenu *) popupMenu:(UIViewController *) parent;

/** Use UIAlterController instead
 
 @param useActionMenu - YES or No
 
 */
+(void) setUseActionMenu:(BOOL) useActionMenu;

@end
