//
//  SCDataTableViewController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//


#import <CoreData/CoreData.h>

#import "SCDataTableViewController.h"
#import "UIViewController+AdSpace.h"
#import "UIViewController+SCCustomViewController.h"
#import "SCDataManager.h"

#import "debug.h"

@interface SCDataTableViewController ()

@end

@implementation SCDataTableViewController
@synthesize cellIdentifier, sectionNameKeyPath, fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Handle Notifcations

-(void) handleInitDataEvent:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"C2CallDataManager:initData"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initFetchedResultsController];
            [self.tableView reloadData];
        });
    }
}

-(NSFetchRequest *) fetchRequest
{
    return nil;
}

-(void) initFetchedResultsController
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    if (!fetchRequest)
        return;
    
    @try {
        NSFetchedResultsController *aFetchedResultsController = [[SCDataManager instance] fetchedResultsControllerWithFetchRequest:fetchRequest sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
        
        if (!aFetchedResultsController)
            return;
        
        if (self.fetchedResultsController) {
            self.fetchedResultsController.delegate = nil;
            self.fetchedResultsController = nil;
        }
        self.fetchedResultsController = aFetchedResultsController;
        
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    @catch (NSException *exception) {
        DLog(@"Exeption : %@", exception);
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitDataEvent:) name:@"C2CallDataManager:initData" object:nil];

    [self initFetchedResultsController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Segue Handling

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 1;
    }
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (!self.fetchedResultsController || [[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 0;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    DLog(@"x : %d / %d", section, [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
    
}

-(void) configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *) indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = self.cellIdentifier?self.cellIdentifier : @"Cell";
    
    UITableViewCell *cell = nil;
    if ([self.tableView isEqual:tv]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRowAtIndexPath : %d / %d", indexPath.section, indexPath.row);
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
{
    if (self.useDidChangeContentOnly)
        return;

    DLog(@"SCDataTable:didChangeObject : %@ / %d / %d", ([NSThread isMainThread]?@"mainThread" : @"not the mainThread"), indexPath.row, type);
    UITableView *tableView = self.tableView;
    
    @try {
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                        atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
        
    }
    @catch (NSException *exception) {
        DLog(@"Error : didChangeObject : %@", exception);
        [tableView reloadData];
    }
}

/* Notifies the delegate of added or removed sections.  Enables NSFetchedResultsController change tracking.
 
 controller - controller instance that noticed the change on its sections
 sectionInfo - changed section
 index - index of changed section
 type - indicates if the change was an insert or delete
 
 Changes on section info are reported before changes on fetchedObjects.
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
{
    if (self.useDidChangeContentOnly)
        return;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
            
    }
}

/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    if (self.useDidChangeContentOnly)
        return;

    DLog(@"SCDataTable:controllerWillChangeContent : %@", ([NSThread isMainThread]?@"mainThread" : @"not the mainThread"));

    [self.tableView beginUpdates];
}

/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    if (self.useDidChangeContentOnly)
        return;

    DLog(@"SCDataTable:controllerDidChangeContent : %@", ([NSThread isMainThread]?@"mainThread" : @"not the mainThread"));
    [self.tableView endUpdates];
}

/* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
 If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
 Only needed if a section index is used.
 */
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return nil;
}


@end
