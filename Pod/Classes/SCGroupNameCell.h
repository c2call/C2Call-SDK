//
//  SCGroupNameCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** UITableViewCell subclass to implement an editable group name.
 */
@interface SCGroupNameCell : UITableViewCell

/** @name Outlets */
/** Group Name Textfield. */
@property(nonatomic, weak) IBOutlet UITextField     *groupName;

@end
