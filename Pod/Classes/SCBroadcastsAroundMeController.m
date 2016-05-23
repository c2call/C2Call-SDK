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
    self.broadcastName.text = @"";
    self.onlineUsers.text = @"0";
    self.broadcastImage.image = [UIImage imageNamed:@"ico_video"];
    self.userImage.image = [UIImage imageNamed:@"btn_ico_avatar"];;
    self.userName.text = @"";
    self.userStatus.text = @"";

}

-(void) configureCell:(MOC2CallBroadcast *) bcast
{
    self.broadcastid = bcast.groupid;
    self.broadcastName.text = bcast.groupName;
    self.onlineUsers.text = [bcast.onlineUsers stringValue];
    
    NSString *bcastid = self.broadcastid;
    NSString *owner = [bcast.groupOwner copy];
    
    UIImage *bcastImage = [[C2CallPhone currentPhone] userimageForUserid:self.broadcastid];
    if (bcastImage) {
        self.broadcastImage.image = bcastImage;
    }
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:owner];
    if (image) {
        self.userImage.image = image;
    }
    
    __weak SCBroadcastCell *weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *userInfo =[[C2CallPhone currentPhone] getUserInfoForUserid:owner];
        NSString *imagekey = userInfo[@"ImageLarge"];
        NSString *bcastImageKey = [[C2CallPhone currentPhone] userimageKeyForUserid:bcastid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MOC2CallUser *c2user = [[SCDataManager instance] userForUserid:owner];
            if ([bcastid isEqualToString:weakself.broadcastid]) {
                
                NSString *displayName = @"";
                NSString *firstname = userInfo[@"Firstname"];
                NSString *name = userInfo[@"Lastname"];
                
                if ([c2user.displayName length] > 0) {
                    displayName = c2user.displayName;
                } else if ([firstname length] > 0 &&  [name length] > 0) {
                    displayName = [NSString stringWithFormat:@"%@ %@", firstname, name];
                } else if ([firstname length] > 0) {
                    displayName = firstname;
                } else if ([name length] > 0) {
                    displayName = name;
                }
                self.userName.text = displayName;
                self.userStatus.text = [c2user.online boolValue]? @"online" : @"";
            }
        });

        if (!bcastImage && bcastImageKey) {
            if ([[C2CallPhone currentPhone] hasObjectForKey:bcastImageKey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([bcastid isEqualToString:weakself.broadcastid]) {
                        weakself.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
                    }
                });
            } else {
                [[C2CallPhone currentPhone] retrieveObjectForKey:bcastImageKey completion:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([bcastid isEqualToString:weakself.broadcastid]) {
                            weakself.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
                        }
                    });
                }];
            }
        }

        if (!image && imagekey) {
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
    self.tableView.estimatedRowHeight = 266.;
    self.tableView.rowHeight = 266.;
    
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
