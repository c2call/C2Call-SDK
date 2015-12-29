//
//  SCFriendListController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 05.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SCDataTableViewController.h"

typedef enum {
    SCFriendFilter_NONE,        // Show All
    SCFriendFilter_ONLINE,      // Only Online Friends and Groups
    SCFriendFilter_RECENT,      // Only Friends or Group with interaction during the past 7 days
    SCFriendFilter_FAVORITE,    // Only Friends marked as Favorites
    SCFriendFilter_GROUPS,      // Groups Only no Friends
    SCFriendFilter_FRIENDS,     // Friends Only no Groups
    
} SCFriendListFilterType;

typedef enum {
    SCFriendDetailAction_FriendDetail,
    SCFriendDetailAction_Chat
} SCFriendListDetailActionType;

@class NSManagedObjectID, SCFriendListCell, MOC2CallUser;

/** Presents the standard C2Call SDK Friend List Controller.
 
 The FriendList has support for presence information and supports several filter options:
 
    SCFriendFilter_ONLINE - Shows only Online Users
    SCFriendFilter_RECENT - Shows only Users I've been in contact in the past 7 days
    SCFriendFilter_FAVORITE - Shows only Favorite Users
    SCFriendFilter_GROUPS - Shows only Groups

 In addition a TextFilter can be set, which filters for the given text in Firstname, Lastname and Email Address.
 
 */

@interface SCFriendListController : SCDataTableViewController

/** @name Properties */
/** Highlighted Cell Background Color. 
 
 Active Group Calls will be automatically highlighted. Set the highlight color here.
 
 */
@property(nonatomic, strong) UIColor                        *highlightedCellBackground;

/** Provides a readable text, which Filters are currently active. */
@property(nonatomic, strong) NSString                       *activeFilterInfo;

/** Sets the default behavior when clicking on a Friend Item.
 
    SCFriendDetailAction_FriendDetail - Opens the Friend Detail Controller
    SCFriendDetailAction_Chat - Opens the Chat View for this Friend
 */
@property(nonatomic) SCFriendListDetailActionType           friendDetailAction;


/** Sets the filter.
 
 @param filter - The Filter Type, one of SCFriendListFilterType
 */
-(void) setFriendFilter:(SCFriendListFilterType) filter;

/** Removes the current TextFilter. 
 */
-(void) removeTextFilter;

/** Sets the current TextFilter.
 
 @param text - Text to filter for
 */
-(void) setTextFilterForText:(NSString *) text;

/** Removes all active Filter.
 @param sender - The initiator of the action
 */
-(IBAction)removeAllFilter:(id)sender;

/** Displays the Filter PopupMenu.
 
 Standard Implementation:
 
    SCPopupMenu *popup = [SCPopupMenu popupMenu:self];
    
    [popup addChoiceWithName:NSLocalizedString(@"Remove Filter", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self removeAllFilter:nil];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Online", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_ONLINE];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Groups", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_GROUPS];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Favorites", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_FAVORITE];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Recent", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_RECENT];
    }];

    [popup addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [popup showMenu];    
 
 @param sender - The initiator of the action
 */
-(IBAction)filterMenu:(id)sender;

/** @name Manage TableView Cells */

/** Configure FriendList TableView Cell
 
 Overwrite this method to change the look and colors of the friend cell in your friend list
 Call super to initially set the cells content
 
 @param cell - the actual UITableViewCell sub-class
 @param elem - MOC2CallUser object to fill the cell's content
 @param indexPath - the indexPath
 
 */
-(void) configureCell:(SCFriendListCell *) cell forElement:(MOC2CallUser *) elem atIndexPath:(NSIndexPath *) indexPath;

@end
