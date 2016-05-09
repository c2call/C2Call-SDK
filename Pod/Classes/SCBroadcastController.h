//
//  SCBroadcastController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07/05/16.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCDataTableViewController.h"

@class MOC2CallUser, MessageCell, MOC2CallEvent;

@interface SCBroadcastCellIn : UITableViewCell {
    BOOL _triggerSet;
}

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (nonatomic, strong) NSString      *eventId;

-(void) triggerFadeOut:(CGFloat) timer withCompleteHandler:(void (^)()) completion;

@end

@interface SCBroadcastCellOut : UITableViewCell {
    BOOL _triggerSet;
}

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (nonatomic, strong) NSString      *eventId;

-(void) triggerFadeOut:(CGFloat) timer withCompleteHandler:(void (^)()) completion;

@end


@interface SCBroadcastController : SCDataTableViewController

/** @name Properties */
/** BroadcastGroupId (must be a groupid of a Broadcasting Group).
 
 Shows the messages related to a broadcasting group
 
 */
@property (nonatomic, strong) NSString *broadcastGroupId;

@property(nonatomic) int                fetchLimit;
@property(nonatomic) int                fetchSize;
@property(nonatomic) NSLineBreakMode    cellLBM;


@end
