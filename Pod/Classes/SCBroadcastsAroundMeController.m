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

@interface SCBroadcastCell ()

@property(nonatomic, strong) NSString   *bcastImageKey;
@property(nonatomic, strong) NSString   *userImageKey;

@end

@implementation SCBroadcastCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.broadcastid = nil;
    self.bcastImageKey = nil;
    self.userImageKey = nil;
    self.broadcastName.text = @"";
    self.onlineUsers.text = @"0";
    self.broadcastImage.image = [UIImage imageNamed:@"ico_video"];
    self.userImage.image = [UIImage imageNamed:@"btn_ico_avatar"];;
    self.userName.text = @"";
    self.userStatus.text = @"";
    
}
-(void) downloadProgress:(NSNotification *) notification
{
    if (self.bcastImageKey && [[notification name] isEqualToString:self.bcastImageKey]) {
        NSNumber *finished = [notification.userInfo objectForKey:@"finished"];
        if ([finished boolValue]) {
            self.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:self.bcastImageKey];
        }
    }
    
    if (self.userImageKey && [[notification name] isEqualToString:self.userImageKey]) {
        NSNumber *finished = [notification.userInfo objectForKey:@"finished"];
        if ([finished boolValue]) {
            self.userImage.image = [[C2CallPhone currentPhone] imageForKey:self.userImageKey];
        }
    }
    
}

-(void) configureCell:(MOC2CallBroadcast *) bcast
{
    NSLog(@"configure BCast Cell: %@ / %@ / %@", bcast.groupName, bcast.groupid, bcast.live);
    self.broadcastid = bcast.groupid;
    self.broadcastName.text = bcast.groupName;
    self.onlineUsers.text = [bcast.onlineUsers stringValue];
    
    NSString *bcastid = self.broadcastid;
    NSString *owner = [bcast.groupOwner copy];
    NSString *locationName = bcast.locationName? [bcast.locationName copy]: @"";
    
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
                self.userStatus.text = locationName;
            }
        });
        
        if (!bcastImage && bcastImageKey) {
            self.bcastImageKey = bcastImageKey;
            if ([[C2CallPhone currentPhone] hasObjectForKey:bcastImageKey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([bcastid isEqualToString:weakself.broadcastid]) {
                        weakself.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
                    }
                });
            } if ([[C2CallPhone currentPhone] downloadStatusForKey:bcastImageKey]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:bcastImageKey object:nil];
            }  else {
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
            self.userImageKey = imagekey;
            if ([[C2CallPhone currentPhone] hasObjectForKey:imagekey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([bcastid isEqualToString:weakself.broadcastid]) {
                        weakself.userImage.image = [[C2CallPhone currentPhone] imageForKey:imagekey];
                    }
                });
            } if ([[C2CallPhone currentPhone] downloadStatusForKey:imagekey]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:imagekey object:nil];
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

@interface SCBroadcastsAroundMeController () {
    BOOL refreshLoop;
}

@end

@implementation SCBroadcastsAroundMeController

-(NSFetchRequest *) fetchRequest
{
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *after = [cal dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:[NSDate date] options:0];
    
    NSFetchRequest *fetch =  [[SCDataManager instance] fetchRequestForBroadcasts:YES fromDate:after sort:NO];
    
    return fetch;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"SCBroadcastCell";
    self.emptyResultCellIdentifier = @"SCNoBroadcastsCell";
    self.tableView.estimatedRowHeight = 266.;
    self.tableView.rowHeight = 266.;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    refreshLoop = YES;
    [self refreshBroadcasts];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    refreshLoop = NO;
    
}

-(void) refreshBroadcasts
{
    [[C2CallPhone currentPhone] refreshLiveBroadcasts];
    
    __weak SCBroadcastsAroundMeController *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (refreshLoop) {
            [weakself refreshBroadcasts];
        }
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
