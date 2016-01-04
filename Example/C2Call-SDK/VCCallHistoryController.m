//
//  VCCallHistoryController.m
//  SDK-VideoChat Sample
//
//  Created by Michael Knecht on 20.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "VCCallHistoryController.h"

#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>

@implementation VCCallHistoryCell

@synthesize nameLabel, textLabel, timeLabel, userImage, missedEvents;

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CALayer *l = self.missedEvents.layer;
    l.cornerRadius = 5.0;
}

@end


@interface VCCallHistoryController () {
    NSCalendar  *calendar;
    CGFloat     callHistoryCellHeight;
}

@end

@implementation VCCallHistoryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"VCCallHistoryCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    callHistoryCellHeight = cell.frame.size.height;
    
    calendar = [NSCalendar currentCalendar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark fetchRequest

// Return a pre-defined fetch request for a list of MOCallHistory CoreData objects.
-(NSFetchRequest *) fetchRequest
{
    return [[SCDataManager instance] fetchRequestForCallHistory:NO];
}

#pragma mark Configure Cell

// Return the given hight for the TableViewCell
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return callHistoryCellHeight;
}

// Feed the TableViewCell with Data
-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[VCCallHistoryCell class]]) {
        VCCallHistoryCell *histcell = (VCCallHistoryCell *) cell;
        histcell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:chathist.contact];
        
        NSDate *today = [NSDate date];
        
        NSDateComponents *dateComps = [calendar components:NSDayCalendarUnit fromDate:chathist.lastTimestamp toDate:today options:0];
        
        if ([dateComps day] > 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
            histcell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:chathist.lastTimestamp]];
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            histcell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:chathist.lastTimestamp]];
        }
        
        if (chathist.lastEventId) {
            MOC2CallEvent *event = [[SCDataManager instance] eventForEventId:chathist.lastEventId];
            
            if ([event.eventType isEqualToString:@"CallIn"]) {
                histcell.textLabel.text = @"Received Call";
            }
            
            if ([event.eventType isEqualToString:@"CallOut"]) {
                histcell.textLabel.text = @"Outbound Call";
            }
        } else {
            histcell.textLabel.text = @"";
        }
        
        UIImage *img = [[C2CallPhone currentPhone] userimageForUserid:chathist.contact];
        
        if (img) {
            histcell.userImage.image = img;
        } else {
            MOC2CallUser *user = [[SCDataManager instance] userForUserid:chathist.contact];
            if ([user.userType intValue] == 2) {
                histcell.userImage.image = [UIImage imageNamed:@"btn_ico_avatar_group.png"];
            } else {
                histcell.userImage.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
            }
        }
        
        
        if ([chathist.missedEvents intValue] > 0) {
            histcell.missedEvents.hidden = NO;
            histcell.missedEvents.text = [NSString stringWithFormat:@"%@", chathist.missedEvents];
        } else {
            histcell.missedEvents.hidden = YES;
        }
    }
}

// Clicking on a History Item initiates a call
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"VCCallHistory:didSelectRowAtIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    [[C2CallPhone currentPhone] callVideo:chathist.contact];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// We want to get rid of a MOCallHistory Object
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[SCDataManager instance] removeDatabaseObject:chathist];
    }
}

// Toggle Edit Call History
-(IBAction)toggleEditing:(id)sender
{
    if (self.tableView.editing) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing:)];
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

@end
