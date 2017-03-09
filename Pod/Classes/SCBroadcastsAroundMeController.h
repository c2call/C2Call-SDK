//
//  SCBroadcastsAroundMeController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 21/05/16.
//
//

#import <SocialCommunication/SocialCommunication.h>

@interface SCBroadcastCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *broadcastImage;
@property (weak, nonatomic) IBOutlet UILabel *broadcastName;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;
@property (weak, nonatomic) IBOutlet UILabel *onlineUsers;

@property (nonatomic, strong) NSString *broadcastid;

-(void) configureCell:(MOC2CallBroadcast *) bcast;
-(void) downloadProgress:(NSNotification *) notification;

@end

@interface SCBroadcastsAroundMeController : SCDataTableViewController


-(void) refreshBroadcasts;
-(void) configureCell:(SCBroadcastCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
