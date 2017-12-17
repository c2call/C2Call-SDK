//
//  SCUserSelectionController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@class DDXMLElement;

/** Presents the standard C2Call SDK User Selection Controller.
 
 The User Selection Controller provides a GUI to select users from the current friend list.
 It will be used as part of the create group process, to choose the group members from the users friend list, but can also be used for other purposes when ever the users has to choose friends for a specific action.
 
 */
@interface SCUserSelectionController : UITableViewController<UISearchBarDelegate>

/** @name Properties */
/** Array of userids which will be pre-selected when presenting the controller. */
@property(nonatomic, strong) NSArray    *selectedUserList;

/** SearchBar Outlet */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

/** @name Contacts */

/** Provides the user object for indexPath position
 
 In order to overwrite cellForRowAtIndexPath this is required.
 
 @param indexPath - The indexpath
 @return contact at indexpath position
 */
-(NSDictionary *) contactForIndexPath:(NSIndexPath *) indexPath;

/** @name Completion Actions */
/** Sets the result action block to be called, when the users has finished his choice.
 
 Inside the action block the developer has to take care of closing the controller.
 
 @param action - The action block with the array of selected userids
 */
-(void) setResultAction:(void (^)(NSArray *result))action;

/** Sets the result action block to be called when the users has has cancelled the user selection.
 
 Inside the action block the developer has to take care of closing the controller.
 
 @param action - The action block
 */
-(void) setCancelAction:(void (^)())action;

/** @name Actions */
/** Cancels Action. 
 @param sender - The initiator of the action
 */
-(IBAction)cancel:(id)sender;

/** Confirms Selection Action.
 @param sender - The initiator of the action
 */
-(IBAction)confirmSelection:(id)sender;

/** Filter unwanted users
 @param elem - XML Format user
 @return YES - Filter / NO - Show User
 */

-(BOOL) filterUser:(DDXMLElement *) elem;

@end
