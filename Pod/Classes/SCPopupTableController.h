//
//  SCPopupTableController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** SCPopupTableController is a Child ViewController of SCPopupMenu and will be embedded.
 */
@interface SCPopupTableController : UITableViewController

/** @name Properties */
/** Array of MenuItems.
 
 For internal use only.
 */
@property(nonatomic, strong) NSMutableArray *menuSegments;

@end
