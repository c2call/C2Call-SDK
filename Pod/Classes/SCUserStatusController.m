//
//  SCUserStatusController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 27.11.13.
//
//

#import "SCUserStatusController.h"
#import "SCUserProfile.h"
#import "SCEditStatusController.h"

@interface SCUserStatusController ()

@property(nonatomic, retain) NSArray        *defaultStatusItems;

@end

@implementation SCUserStatusController
@synthesize defaultStatusItems;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.defaultStatusItems = [SCUserProfile defaultUserStatusTemplates];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    
    if (section == 1)
        return [defaultStatusItems count];
    
    return 1;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Your current status is:", @"Table Header");
    }

    if (section == 1) {
        return NSLocalizedString(@"Select new status", @"Table Header");
    }

    return nil;
}

-(void) configureCell:(UITableViewCell *) cell forIndexPath:(NSIndexPath *) indexPath
{
    if (indexPath.section == 0) {
        NSString *status = [SCUserProfile currentUser].userStatus;
        if (status) {
            cell.textLabel.text = status;
        } else {
            cell.textLabel.text = NSLocalizedString(@"*** No Status ***", @"Status");
        }
    }
    
    if (indexPath.section == 1) {
        cell.textLabel.text = [defaultStatusItems objectAtIndex:indexPath.row];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SCStatusListCell";
    
    if (indexPath.section == 0)
        cellIdentifier = @"SCCurrentStatusCell";
    
    if (indexPath.section == 2)
        cellIdentifier = @"SCRemoveStatusCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    
    if (indexPath.section == 1)
        return YES;
    
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableArray *list = [self.defaultStatusItems mutableCopy];
        [list removeObjectAtIndex:indexPath.row];
        [SCUserProfile setUserStatusTemplates:list];
        self.defaultStatusItems = list;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [SCUserProfile currentUser].userStatus = [self.defaultStatusItems objectAtIndex:indexPath.row];

        self.navigationItem.prompt = NSLocalizedString(@"Updating Status...", @"Prompt");

        [[SCUserProfile currentUser] saveUserProfileWithCompletionHandler:^(BOOL success) {
            self.navigationItem.prompt = nil;
            [self.tableView reloadData];
        }];
    }

    if (indexPath.section == 2) {
        [SCUserProfile currentUser].userStatus = @"";
        self.navigationItem.prompt = NSLocalizedString(@"Updating Status...", @"Prompt");
        
        [[SCUserProfile currentUser] saveUserProfileWithCompletionHandler:^(BOOL success) {
            self.navigationItem.prompt = nil;
            [self.tableView reloadData];
        }];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCAddStatusControllerSegue"]) {
        SCEditStatusController *editStatus = (SCEditStatusController *) segue.destinationViewController;
        editStatus.saveStatusAsTemplate = YES;
    }

    if ([segue.identifier isEqualToString:@"SCEditStatusControllerSegue"]) {
        SCEditStatusController *editStatus = (SCEditStatusController *) segue.destinationViewController;
        editStatus.saveStatusAsTemplate = NO;
    }

}


@end
