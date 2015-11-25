//
//  SCGroupDetailController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SCAdTableViewController.h"

@class DDXMLElement;

/** Presents the standard C2Call SDK Group Detail Controller.
 
 The Group Detail Controller shows the group members and their online status.
 It provides controls to call, video call or chat of the group.
 The group owner is allowed to edit the group, add a group image, change the group name and add or remove members.
 
 Please use showGroupDetailForGroupid: from UIViewController+SCCustomViewController.h to present this controller programatically.

 
*/
@interface SCGroupDetailController : SCAdTableViewController

/** @name Outlets */
/** UIView references for the embedded group header view. */
@property(nonatomic, weak) IBOutlet UIView    *headerView;


/** @name Properties */
/** GroupId of the group. */
@property(nonatomic, strong) NSString       *groupid;

/** @name Actions */
/** Connect a Group Member as Friend 

 This Action is connected to the GroupMemberCell Invite Button.
 @param sender - The initiator of the action
 */
-(IBAction) inviteContact:(id)sender;

/** Edit Group Action
 
 Add or remove group members. Only available for the group owner.
 @param sender - The initiator of the action
 */
-(IBAction) editGroup:(id)sender;


/** Enable / Disable Encryption for Group
 
 @param sender - The initiator of the action
 */
-(IBAction) toggleEncryption:(id) sender;

@end
