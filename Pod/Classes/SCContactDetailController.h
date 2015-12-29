//
//  SCContactDetailController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 18.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SCAdTableViewController.h"

@class C2BlockAction;

/** UITableViewCell subclass showing the contact name and user image.
 */
@interface SCPersonHeaderCell : UITableViewCell

/** @name Properties */
/** User Image. */
@property(nonatomic, weak) IBOutlet     UIImageView     *userImage;

/** User Name. */
@property(nonatomic, weak) IBOutlet     UILabel         *userName;

@end

/** UITableViewCell subclass to show video, VoIP and message buttons.
 */
@interface SCPersonVoIPCell : UITableViewCell

/** @name Properties */
/** Video Action Block. */
@property(nonatomic, strong) C2BlockAction      *videoAction;

/** VoIP Action Block. */
@property(nonatomic, strong) C2BlockAction      *voipAction;

/** Message Action Block. */
@property(nonatomic, strong) C2BlockAction      *messageAction;

/** @name Actions */
/** VideoCall Action.
 @param sender - The initiator of the action
 */
-(IBAction)videoCall:(id)sender;

/** VoIPCall Action.
 @param sender - The initiator of the action
 */
-(IBAction)voipCall:(id)sender;

/** Chat Action.
 @param sender - The initiator of the action
 */
-(IBAction)message:(id)sender;

@end

/** Presents the standard C2Call SDK Contact Detail Controller.
 */
@interface SCContactDetailController : SCAdTableViewController<UIActionSheetDelegate>

/** @name Properties */
/** Person Record. */
@property(nonatomic, readwrite) ABRecordRef         personRecord;

/** C2Call Userid if the contact is a friend. */
@property(nonatomic, strong) NSString               *userid;

@end
