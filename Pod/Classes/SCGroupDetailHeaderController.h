//
//  SCGroupDetailHeaderController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
@class SCGroup, C2TapImageView;

/** Group Detail Header Controller embeeded in SCGroupDetailController.
 */
@interface SCGroupDetailHeaderController : UIViewController

/** @name Outlets */
/** Label Group Name. */
@property(nonatomic, weak) IBOutlet UILabel             *groupName;

/** Label Group Owner. */
@property(nonatomic, weak) IBOutlet UILabel             *groupOwner;

/** Label Group Status (Online Status). */
@property(nonatomic, weak) IBOutlet UILabel             *groupStatus;

/** Editable Group Name. */
@property(nonatomic, weak) IBOutlet UITextField         *tfGroupName;

/** Edits Group Name Button. */
@property(nonatomic, weak) IBOutlet UIButton            *editGroupName;

/** Group Image Button. */
@property(nonatomic, weak) IBOutlet C2TapImageView      *imageButton;

/** Toggle Encryption Button. */
@property(nonatomic, weak) IBOutlet UIButton            *toggleEncryptionButton;


/** Group Representation as XML Object (for internal use). */
@property(nonatomic, strong) SCGroup       *group;


/** @name Actions */
/** Select a photo for the group.
 
 Only for the group owner
 
 @param sender - The initiator of the action
 */
-(IBAction) selectPhoto:(id)sender;

/** Start editing the group name

Only for the group owner

@param sender - The initiator of the action
*/
-(IBAction) editGroupName:(id)sender;

/** End editing the group name.

Only for the group owner

@param sender - The initiator of the action
*/
-(IBAction) endEditGroupName:(id)sender;

/** Open the Chat for the Group

@param sender - The initiator of the action
*/
-(IBAction) message:(id)sender;

/** Call the Group for a Video Conference
 
 @param sender - The initiator of the action
 */
-(IBAction) callVideo:(id)sender;

/** Call the Group for a Voice Conference
 
 @param sender - The initiator of the action
 */
-(IBAction) call:(id)sender;

/** @name other Methods */
/** Refreshes the group status. 
 
 Will be called by GroupDetail Controller.
 
 */

-(void) refreshGroupStatus;


@end
