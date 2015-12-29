//
//  SCAddGroupController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
@class DDXMLElement;

/** Presents the standard C2Call SDK Add Group Controller.
 
 In C2Call SDK group represents a group of C2Call users who can participate in a voice chat, video chat and text chat.
 The Add Group Controller creates a new group and allows adding friends to this group.
 Once the group is created all members will be notified on the new group.
 When calling the group all members will be notified that a conference call is running for this group and they may join.
 When sending a message to this group all group members will receive this message as chat message.
 
 In a video group call, up to 7 participants are able to join the call. Further participants can join via voice call.
 */
@interface SCAddGroupController : UITableViewController

/** @name Properties */
/** Array of friend userids as group members. */
@property(nonatomic, strong) NSArray    *members;

/** @name Complete Actions */
/** Action Block to be called after the group has been successfully added.
 
 After the Group has been created the developer might want to show the group details:
 
    #import <SocialCommunication/UIViewController+SCCustomViewController.h>
    ...skip....
    [controller setAddGroupAction:^(NSString *groupid){
        dispatch_async(dispatch_get_main_queue(), ^(){
            // Close the Add Group Controller
            [self.navigationController popViewControllerAnimated:NO];
 
            // Present the Group Detail Controller
            [self showGroupDetailForGroupid:groupid];
 
        });
    }];
 
 @param action - The Action Block
 */
-(void) setAddGroupAction:(void (^)(NSString *groupid))action;

/** Action Block to be called on cancel add group.
 
 @param action - The Action Block
*/
-(void) setCancelAction:(void (^)())action;

/** @name Actions */
/** Add Group Members Action.
 @param sender - The initiator of the action
 */
-(IBAction)addMembers:(id)sender;

/** Creat Group Action.
 @param sender - The initiator of the action
 */
-(IBAction)createGroup:(id)sender;

@end
