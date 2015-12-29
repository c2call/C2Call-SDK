//
//  SCBrowserViewController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@class C2BlockAction;

/** Presents the standard C2Call SDK Browser ViewController.
 */
@interface SCBrowserViewController : UIViewController

/** @name Outlets */
/** Activity Indicator View shown while loading a page. */
@property(nonatomic, weak) IBOutlet     UIView          *activityContainerView;

/** The actual browser view. */
@property(nonatomic, weak) IBOutlet     UIWebView       *browserView;

/** @name Properties */
/** The URL to load. */
@property(nonatomic, strong) NSString        *requestUrl;

/** The Browser Title. */
@property(nonatomic, strong) NSString        *browserTitle;

/** Alternative to the requestUrl, direct html can be set here. */
@property(nonatomic, strong) NSString        *htmlString;

/** Attaches an Action when the view is closed. */
@property(nonatomic, strong) C2BlockAction   *closeAction;

/** @name Load Methods */
/** Loads Url with String (will set the requestUrl property).
 
 @param url - Valid URL
 */
-(void) loadUrl:(NSString *) url;

/** Shows direct HTML Code in the browser view.
 
 @param html - The HTML Code to show
 */
-(void) loadString:(NSString *) html;

/** @name Actions */
/** Closes Brwoser Action.
 
 @param sender - The initiator of the action
 */
-(IBAction) closeBrowser:(id)sender;

@end
