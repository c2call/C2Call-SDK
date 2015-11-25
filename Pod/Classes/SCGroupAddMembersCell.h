//
//  SCGroupAddMembersCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** UITableViewCell subclass showing the number of group members.
 */
@interface SCGroupAddMembersCell : UITableViewCell

/** @name Outlets */
/** Labels number of group members. */
@property(nonatomic, weak) IBOutlet UILabel     *numMembers;

@end
