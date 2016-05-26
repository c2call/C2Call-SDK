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
    
    if (broadcast.groupImage) {
        if ([[C2CallPhone currentPhone] hasObjectForKey:broadcast.groupImage]) {
            self.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:broadcast.groupImage];
        } else {
            self.broadcastImage.image = [UIImage imageNamed:@"ico_group"];
            
            __weak SCMyBroadcastCell *weakself = self;
            NSString *currentid = self.broadcastid;
            NSString *imagekey = [broadcast.groupImage copy];
            [[C2CallPhone currentPhone] retrieveObjectForKey:imagekey completion:^(BOOL finished) {
                if ([currentid isEqualToString:weakself.broadcastid] && finished) {
                    weakself.broadcastImage.image = [[C2CallPhone currentPhone] imageForKey:imagekey];
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
    self.tableView.estimatedRowHeight = 59;
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
    
    NSString *mediaUrl = bcast.mediaUrl;
    
    if (mediaUrl && [[C2CallPhone currentPhone] hasObjectForKey:mediaUrl]) {
        [self performSegueWithIdentifier:@"SCVideoPlayerControllerSegue" sender:cell];
    }
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
}

@end
