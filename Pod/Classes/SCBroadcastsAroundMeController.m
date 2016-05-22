//
//  SCBroadcastsAroundMeController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 21/05/16.
//
//

#import "SCBroadcastsAroundMeController.h"
#import "MOC2CallBroadcast.h"
#import "SCDataManager.h"
#import "SCBroadcastChatController.h"

@implementation SCBroadcastCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.broadcastid = nil;
}

-(void) configureCell:(MOC2CallBroadcast *) bcast
{
    self.broadcastid = bcast.groupid;
    self.broadcastName.text = bcast.groupName;
    self.onlineUsers.text = [bcast.onlineUsers stringValue];
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:bcast.groupOwner];
    if (image) {
        self.userImage.image = image;
    }
        
    __weak SCBroadcastCell *weakself = self;
    NSString *bcastid = self.broadcastid;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *userInfo =[[C2CallPhone currentPhone] getUserInfoForUserid:bcast.groupOwner];
        NSString *imagekey = userInfo[@"ImageSmall"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MOC2CallUser *c2user = [[SCDataManager instance] userForUserid:bcast.groupOwner];
            if ([bcastid isEqualToString:weakself.broadcastid]) {
                
                NSString *displayName = @"";
                NSString *firstname = userInfo[@"Firstname"];
                NSString *name = userInfo[@"Lastname"];
                
                if (c2user.displayName) {
                    displayName = c2user.displayName;
                } else if ([firstname length] > 0 &&  [name length] > 0) {
                    displayName = [NSString stringWithFormat:@"%@ %@", firstname, name];
                } else if (firstname) {
                    displayName = firstname;
                } else if (name) {
                    displayName = name;
                }
                self.userName.text = displayName;
                self.userStatus.text = [c2user.online boolValue]? @"online" : @"";
            }
        });
     
        if (!image) {
            if ([[C2CallPhone currentPhone] hasObjectForKey:imagekey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([bcastid isEqualToString:weakself.broadcastid]) {
                        weakself.userImage.image = [[C2CallPhone currentPhone] imageForKey:imagekey];
                    }
                });
            } else {
                [[C2CallPhone currentPhone] retrieveObjectForKey:imagekey completion:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([bcastid isEqualToString:weakself.broadcastid]) {
                            weakself.userImage.image = [[C2CallPhone currentPhone] imageForKey:imagekey];
                        }
                    });
                }];
            }
        }
    });
    
    
}

@end

@implementation SCBroadcastsAroundMeController

-(NSFetchRequest *) fetchRequest
{
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = NO;
    
    NSFetchRequest *fetch =  [[SCDataManager instance] fetchRequestForBroadcasts:NO fromDate:nil sort:NO];
    
    return fetch;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"SCBroadcastCell";
    self.tableView.estimatedRowHeight = 266;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self refreshBroadcasts];
}

-(void) refreshBroadcasts
{
    [[C2CallPhone currentPhone] refreshLiveBroadcasts];

    __weak SCBroadcastsAroundMeController *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself refreshBroadcasts];
    });
}

-(void) configureCell:(SCBroadcastCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallBroadcast *bcast = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureCell:bcast];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastChatController class]] && [sender isKindOfClass:[SCBroadcastCell class]]) {
        SCBroadcastChatController *bchat = (SCBroadcastChatController *) segue.destinationViewController;
        SCBroadcastCell *cell = (SCBroadcastCell *) sender;
        
        NSString *bid = cell.broadcastid;
        bchat.broadcastGroupId = bid;
    }
}

@end
