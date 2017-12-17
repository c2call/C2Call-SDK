//
//  SCMyBroadcastsController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 21/05/16.
//
//

#import "SCMyBroadcastsController.h"
#import "MOC2CallBroadcast.h"
#import "SCVideoPlayerController.h"
#import "SCBroadcastPlaybackController.h"
#import "SCBroadcast.h"

static NSDateFormatter *dateTime = nil;

@implementation SCMyBroadcastCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.broadcastid = nil;
    self.broadcast = nil;
    self.broadcastName.text = @"";
    self.broadcastDetail.text = @"";
    self.broadcastImage.image = nil;
}


-(void) configureCell:(MOC2CallBroadcast *) broadcast
{
    self.broadcastid = [broadcast.groupid copy];
    self.broadcastName.text = broadcast.groupName;
    
    if (!dateTime) {
        dateTime = [[NSDateFormatter alloc] init];
        [dateTime setDateStyle:NSDateFormatterShortStyle];
        [dateTime setTimeStyle:NSDateFormatterShortStyle];
    }
    
    if ([broadcast.members count] > 0 && broadcast.startDate) {
        self.broadcastDetail.text = [NSString stringWithFormat:@"%@ Members (%@)", @([broadcast.members count]), [dateTime stringFromDate:broadcast.startDate]];
    } else if (broadcast.startDate) {
        self.broadcastDetail.text = [dateTime stringFromDate:broadcast.startDate];
    } else {
        self.broadcastDetail.text = @"";
    }
    
    NSString *bcastImageKey = [[C2CallPhone currentPhone] userimageKeyForUserid:self.broadcastid];
    if (bcastImageKey) {
        if ([[C2CallPhone currentPhone] hasObjectForKey:bcastImageKey]) {
            self.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
        } else {
            self.broadcastImage.image = [UIImage imageNamed:@"ico_group"];
            
            __weak SCMyBroadcastCell *weakself = self;
            NSString *currentid = self.broadcastid;
            [[C2CallPhone currentPhone] retrieveObjectForKey:bcastImageKey completion:^(BOOL finished) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([currentid isEqualToString:weakself.broadcastid]) {
                            weakself.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
                        }
                    });
                }
            }];
        }
    } else {
        self.broadcastImage.image = [UIImage imageNamed:@"ico_group"];
    }
}

@end

@implementation SCMyBroadcastsController

-(NSFetchRequest *) fetchRequest
{
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = NO;
    
    NSFetchRequest *fetch =  [[SCDataManager instance] fetchRequestForMyBroadcasts:NO];
    
    return fetch;
}

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.cellIdentifier = @"SCMyBroadcastCell";
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void) configureCell:(SCMyBroadcastCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallBroadcast *bcast = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureCell:bcast];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCMyBroadcastCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    SCBroadcast *bcast = cell.broadcast;
    if (!bcast) {
        bcast = [[SCBroadcast alloc] initWithBroadcastGroupid:cell.broadcastid retrieveFromServer:NO];
        cell.broadcast = bcast;
    }
    
    //if (bcast.mediaUrl && [[C2CallPhone currentPhone] hasObjectForKey:bcast.mediaUrl]) {
    [self performSegueWithIdentifier:@"SCBroadcastPlaybackControllerSegue" sender:cell];
    //}
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCVideoPlayerController class]] && [sender isKindOfClass:[SCMyBroadcastCell class]]) {
        SCVideoPlayerController *vpc = (SCVideoPlayerController *) segue.destinationViewController;
        SCMyBroadcastCell *cell = (SCMyBroadcastCell *) sender;
        
        if ([[C2CallPhone currentPhone] hasObjectForKey:cell.broadcast.mediaUrl]) {
            vpc.mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:cell.broadcast.mediaUrl];
        }
    }

    if ([segue.destinationViewController isKindOfClass:[SCBroadcastPlaybackController class]] && [sender isKindOfClass:[SCMyBroadcastCell class]]) {
        SCBroadcastPlaybackController *vpc = (SCBroadcastPlaybackController *) segue.destinationViewController;
        SCMyBroadcastCell *cell = (SCMyBroadcastCell *) sender;
        
        if (cell.broadcastid) {
            SCBroadcast *bcast = [[SCBroadcast alloc] initWithBroadcastGroupid:cell.broadcastid retrieveFromServer:NO];
            vpc.broadcast = bcast;
        }
    }

    
}

@end
