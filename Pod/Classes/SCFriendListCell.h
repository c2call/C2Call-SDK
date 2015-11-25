//
//  SCFriendListCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 05.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** Standard C2Call SDK FriendList Cell.
 */
@interface SCFriendListCell : UITableViewCell

/** Opens Friend Details.
 */
@property(nonatomic, weak) IBOutlet UIButton        *detailDisclose;

/** Calls Friend.
 */
@property(nonatomic, weak) IBOutlet UIButton        *callButton;

/** VideoCall Friend.
 */
@property(nonatomic, weak) IBOutlet UIButton        *videoCallButton;

/** Friend / Group Name.
 */
@property(nonatomic, weak) IBOutlet UILabel         *labelName;

/** Online Status.
 */
@property(nonatomic, weak) IBOutlet UITextField     *labelDetail;

/** For later use.
 */
@property(nonatomic, weak) IBOutlet UIImageView		*facebookIcon;

/** User Image.
 */
@property(nonatomic, weak) IBOutlet UIImageView		*userImage;

/** Online Status Icon.
 */
@property(nonatomic, weak) IBOutlet UIImageView		*onlineStatusIcon;

/** Video Status Icon.
 */
@property(nonatomic, weak) IBOutlet UIImageView		*videoStatusIcon;

/** Favorit Status Image.
 */
@property(nonatomic, weak) IBOutlet UIImageView		*favoriteImage;

/** UserId of the Friend / Group.
 */
@property(nonatomic, strong) NSString               *userid;

/** Is Background Highlighted.
 */
@property(nonatomic) BOOL                           highlightBackground;

/** Resets all values  (Re-use cell). */
-(void) reset;

@end
