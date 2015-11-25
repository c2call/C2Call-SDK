//
//  SCFriendDetailController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SCDataTableViewController.h"

@class NSManagedObjectID, UDConnectionCell, UDUserInfoCell, MOC2CallUser, UDPhoneCell;

/** Presents the standard C2Call SDK Friend Detail Controller.
 
 The Friends Detail Controller shows the details of a connected friend like name, firstname, user image, phone numbers, etc.
 It also provides user controls to call or chat with this friend.
 
 Please use showFriendDetailForUserid: from UIViewController+SCCustomViewController.h to present this controller programmatically.
 
 */
@interface SCFriendDetailController : SCDataTableViewController

/** @name Outlets */
/** UIView containing the controls for Add Phone Number. */
@property(nonatomic, strong) IBOutlet UIView            *addPhoneNumberHeader;

/** Label Add Phone Number. */
@property(nonatomic, weak) IBOutlet UILabel             *labelAddPhoneNumber;

/** Button Edit Number. */
@property(nonatomic, weak) IBOutlet UIButton           *btnEditNumber;

/** Button Add Number. */
@property(nonatomic, weak) IBOutlet UIButton           *btnAddNumber;

/** UITableViewCell subclass shows the friend details. */
@property(nonatomic, strong) UDUserInfoCell     *userInfoCell;

/** UITableViewCell subclass shows the call, video call and chat buttons. */
@property(nonatomic, strong) UDConnectionCell   *connectionCell;

/** Manages Object Id of the friend. */
@property (nonatomic, strong) NSManagedObjectID *managedObjectId;

/** MOC2CallUser object of the presented friend details. */
-(MOC2CallUser *) currentUser;

/** @name Actions */
/** Call this friends via VoIP call.
 @param sender - The initiator of the action
 */
-(IBAction)callVoice:(id)sender;

/** Call this friends via video call.
 @param sender - The initiator of the action
 */
-(IBAction)callVideo:(id)sender;

/** Opens the chat for this friends.
 @param sender - The initiator of the action
 */
-(IBAction)chat:(id)sender;

/** Sends an SMS/Text message to a friends phone number.
 
 This method uses the sender.tag information (phone number hash value) as reference to the phone number.
 
 @param sender - The initiator of the action
 */
-(IBAction)smsAction:(id)sender;


/** Adds a phone number for this friends.
 
 The profile of a friend shows on the on hand the phone number the friend has defined in his profile but on the other hand the user can also add further numbers to this friend, which will be stored as additional contact information.
 
 @param sender - The initiator of the action
 */
-(IBAction)addPhoneNumber:(id)sender;

/** Edits a phone number for this friends.
 
 The profile of a friend shows on the on hand the phone number the friend has defined in his profile but on the other handThe profile of a friend shows on the on hand the phone number the friend has defined in his profile but on the other hand the user can also add further numbers to this friend which will be stored as additional contact information. the user can also add further numbers to this friend, which will be stored as additional contact information.
 Only user added phone numbers can be edited.
 
 @param sender - The initiator of the action
 */
-(IBAction)editPhoneNumber:(id)sender;

/** @name Customize TableView Cells */

/** Customize UDPhoneCell 

 Please always call super to initially set the cells content.
 
 @param elem - MOC2CallUser
 @param indexPath - The current indexPath
 
 @return UDPhoneCell to present
 */
-(UDPhoneCell *) configurePhoneCell:(MOC2CallUser *) elem forIndexPath:(NSIndexPath *) indexPath;

/** Customize UDConnectionCell
 
 Please always call super to initially set the cells content.
 Use the connectionCell property to customize the cell.
 
 @param elem - MOC2CallUser
  */
-(void) configureConnectionCell:(MOC2CallUser *) elem;


/** Customize UDUserInfoCell
 
 Please always call super to initially set the cells content.
 Use the userInfoCell property to customize the cell.
 
 In case the userStatus outlet is set, the UDUserInfoCell will be presented with 
 the actual userStatus. The cell height will be flexible then. 
 The height will be calculated by calling heightForUserInfoCell
 
 @param elem - MOC2CallUser
 */
-(void) configureUserInfoCell:(MOC2CallUser *) elem;

/** Calculates the required height for UDUserInfoCell
 
 @return The actual height
 */
-(CGFloat) heightForUserInfoCell;

 
@end
