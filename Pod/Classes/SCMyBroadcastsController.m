//
//  SCMyBroadcastsController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 21/05/16.
//
//

#import "SCMyBroadcastsController.h"
#import "MOC2CallBroadcast.h"

static NSDateFormatter *dateTime = nil;

@implementation SCMyBroadcastCell

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

@end
