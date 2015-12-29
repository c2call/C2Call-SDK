//
//  SCAddressBookCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 15.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** UITableViewCell subclass for SCAddressBookController.
 */
@interface SCAddressBookCell : UITableViewCell

/** @name Outlets */
/** Name Label. */
@property(nonatomic, weak) IBOutlet  UILabel          *labelName;

/** Video Icon. */
@property(nonatomic, weak) IBOutlet  UIImageView      *videoIcon;

/** C2Call UserId in case the address book contact email address matches a connected friend. */
@property(nonatomic, strong) NSString                   *userid;

@end
