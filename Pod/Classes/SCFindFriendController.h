//
//  SCFindFriendController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 03.05.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Find Friend Controller.

 In C2Call SDK a friend can be added to the users friend list by sending the email address or the phone number of a registered user to the C2Call service.
 The C2Call service will search in its database for that user and establish a friend relation.
 
 This task will be done in the background as it might take some time. Once a new friend relation is established, both users will receive a notification that a new friend has been added.
 The new friend will then appear in the friend list.
 
 */
@interface SCFindFriendController : UITableViewController

/** @name Outlets */
/** Phone number or email address of a friend to add. */
@property(nonatomic, weak) IBOutlet     UITextField     *numberOrEmailAddress;

/** @name Actions */
/** Finds Friend Action. 
 @param sender - The initiator of the action
 */
-(IBAction)findFriend:(id)sender;

/** Closes View Action. 
 @param sender - The initiator of the action
 */
-(IBAction) close:(id) sender;

@end
