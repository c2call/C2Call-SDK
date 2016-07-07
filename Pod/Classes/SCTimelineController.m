//
//  SCTimelineController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 06.07.16.
//
//

#import "UIViewController+SCCustomViewController.h"
#import "SCTimelineController.h"
#import "MOTimelineEvent.h"
#import "C2CallPhone.h"
#import "SCTimeline.h"
#import "debug.h"

// We need only one instance
static NSDateFormatter  *dateTime = nil;


@implementation SCTimelineBaseCell

-(void) configureCell:(MOTimelineEvent *) event
{
    self.userName.text = event.senderName;
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:event.contact];
    if (image) {
        self.userImage.image = image;
    }

    self.timeLabel.text = [dateTime stringFromDate:event.timeStamp];
    self.textLabel.text = event.text;
    self.likesLabel.text = [NSString stringWithFormat:@"(%d)", [event.like intValue]];

}

@end

@implementation SCTimelineVideoCell

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
}

@end

@implementation SCTimelineImageCell

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    NSString *imageKey = event.mediaUrl;
    UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
    
    self.eventImage.image = img;
}

@end

@implementation SCTimelineAudioCell

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
}

@end

@implementation SCTimelineMessageCell

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    
}

@end


@interface SCTimelineController () {
    BOOL            showPreviousMessageButton;
    BOOL            scrollToBottom;
    BOOL            didLoad;
    
    CFAbsoluteTime  lastContentChange;
}

@end

@implementation SCTimelineController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.estimatedRowHeight = 76;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.cellIdentifier = @"SCTimelineBaseCell";
    self.emptyResultCellIdentifier = @"SCNoTimelineEventsCell";

    if (!dateTime) {
        dateTime = [[NSDateFormatter alloc] init];
        [dateTime setDateStyle:NSDateFormatterShortStyle];
        [dateTime setTimeStyle:NSDateFormatterShortStyle];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = NO;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForTimeline:NO];
    
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchLimit:25];
    
    return fetchRequest;
}

-(void) refreshTable
{
    lastContentChange = CFAbsoluteTimeGetCurrent();
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (CFAbsoluteTimeGetCurrent() - lastContentChange > 0.15) {
            [self.tableView reloadData];
            
            if (scrollToBottom) {
                scrollToBottom = NO;
                [self scrollToBottom];
            }
        }
    });
}

-(void) scrollToBottom
{
    
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.tableView.numberOfSections > 0) {
            int section = (int)self.tableView.numberOfSections - 1;
            int row =  (int)[self.tableView numberOfRowsInSection:section] - 1;
            if (section >= 0 && row >= 0)
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    });
}

-(void) refetchResults
{
    NSFetchRequest *fetchRequest = [self.fetchedResultsController fetchRequest];
    [fetchRequest setFetchLimit:0];
    [fetchRequest setFetchOffset:0];
    
    int offset = 0;
    if (self.fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:self.fetchLimit forFetchRequest:fetchRequest];
    }
    
    [fetchRequest setFetchLimit:self.fetchLimit];
    [fetchRequest setFetchOffset:offset];
    
    showPreviousMessageButton = offset > 0;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        DLog(@"Error : %@", error);
    }
    
    //[self refreshTable];
}

-(void) resetLimits
{
    self.fetchLimit = 25;
    self.fetchSize = 25;
}

-(NSString *) reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseid = [super reuseIdentifierForIndexPath:indexPath];
    if ([reuseid isEqualToString:self.emptyResultCellIdentifier]) {
        return reuseid;
    }
    
    MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Picture]]) {
        return @"SCTimelineImageCell";
    }

    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Video]]) {
        //return @"SCTimelineVideoCell";
    }

    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Audio]]) {
        //return @"SCTimelineAudioCell";
    }

    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Location]]) {
        //return @"SCTimelineLocationCell";
    }

    return self.cellIdentifier;
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

    MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([cell isKindOfClass:[SCTimelineBaseCell class]]) {
        SCTimelineBaseCell *bcell = (SCTimelineBaseCell *)cell;
        
        [bcell configureCell:event];
    }

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
