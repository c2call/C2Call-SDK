//
//  SCGroupMemberCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** UITableViewCell subclass to show a group member.
 */
@interface SCGroupMemberCell : UITableViewCell

/** @name Outlets */
/** User image of the group member. */
@property(nonatomic, weak) IBOutlet UIImageView         *imageView;

/** Name of the group member. */
@property(nonatomic, weak) IBOutlet UILabel             *textLabel;

/** Online Status of the group member. */
@property(nonatomic, weak) IBOutlet UILabel             *detailTextLabel;

/** Invite Button. */
@property(nonatomic, weak) IBOutlet UIButton            *inviteButton;

/** Encyption Status for Group Member */
@property(nonatomic, weak) IBOutlet UIImageView         *encryptionStatus;

@end
