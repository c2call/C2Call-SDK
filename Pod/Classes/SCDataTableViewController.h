//
//  SCDataTableViewController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SCAdTableViewController.h"
/** SCDataTableViewController is an abstract base class for TableViews presenting C2Call SDK CoreData Elements.
 
 This abstract base class currently supports the following CoreData Entities:
 
    - MOC2CallUser
    - MOC2CallEvent
    - MOChatHistory
    - MOCallHistory
 
 The character of this UITableViewController subclass is abstract, as the developer needs to subclass this controller and has to overwrite the following methods:
 
    fetchRequest:
    configureCell:atIndexPath
 
 The developer also must set the cellIdentifier with the identifier of his custom UITableViewCell.
 
 Code Sample from WhazzUpp WUFavoritesViewController:
 
     #import <SocialCommunication/SocialCommunication.h>
     
     @interface WUFavoritesCell : UITableViewCell
     
     @property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *statusLabel, *onlineLabel;
     
     @end
     
     @interface WUFavoritesViewController : SCDataTableViewController
     
     -(IBAction)toggleEditing:(id)sender;
     
     @end
 
     @implementation WUFavoritesViewController
     ...skip...
     - (void)viewDidLoad
     {
         [super viewDidLoad];
         self.cellIdentifier = @"WUFavoritesCell";
            
         UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
         favoritesCellHeight = cell.frame.size.height;
     }

     -(NSFetchRequest *) fetchRequest
     {
        return [[SCDataManager instance] fetchRequestForFriendlist:YES];
     }
     
     -(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
     {
        MOC2CallUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
     
        if ([cell isKindOfClass:[WUFavoritesCell class]]) {
            WUFavoritesCell *favocell = (WUFavoritesCell *) cell;
            favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:user.userid];
            favocell.statusLabel.text = @"Hi there, I'm using WhazzUpp!";
        }
     }
     ...skip...
    @end
 
 */
@interface SCDataTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

/** @name Abstract Methods */
/** Abstract method fetchRequest.
    
This abstract method must be overwritten in a SCDataTableViewController subclass.
Please return one of the pre-defined fetchRequest from SCDataManager here:
    
    - fetchRequestForChatHistory
    - fetchRequestForCallHistory
    - fetchRequestForEventHistory
    - fetchRequestForFriendlist
 
 @return The fetchRequest
 */
-(NSFetchRequest *) fetchRequest;

/** NSFetchedResultsController Initialization
 */
-(void) initFetchedResultsController;

/** Configure your UITableViewCell subclass.
 
 This abstract method must be overwritten in a SCDataTableViewController subclass.
 
 SampleCode:
     -(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
     {
        MOC2CallUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
     
        if ([cell isKindOfClass:[WUFavoritesCell class]]) {
            WUFavoritesCell *favocell = (WUFavoritesCell *) cell;
            favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:user.userid];
            favocell.statusLabel.text = @"Hi there, I'm using WhazzUpp!";
        }
     }
 
 Depending on the fetchRequest the "[self.fetchedResultsController objectAtIndexPath:indexPath]" provides the following NSManagedObject subclasses:
 
    - MOC2CallUser
    - MOC2CallEvent
    - MOChatHistory
    - MOCallHistory
 
 */
-(void) configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *) indexPath;

/** @name Properties */
/** Sets the cellIdentifier for UITableView dequeueReusableCellWithIdentifier:
 
 */
@property(nonatomic, strong) NSString       *cellIdentifier;

/** A key path on result objects that returns the section name. Pass nil to indicate that the controller should generate a single section.
 The section name is used to pre-compute the section information.
 If this key path is not the same as that specified by the first sort descriptor in fetchRequest, they must generate the same relative orderings. For example, the first sort descriptor in fetchRequest might specify the key for a persistent property; sectionNameKeyPath might specify a key for a transient property derived from the persistent property.
 */
@property(nonatomic, strong) NSString       *sectionNameKeyPath;

/** Don't do row updates, just notify content changes
 */
@property(nonatomic) BOOL                   useDidChangeContentOnly;

/** NSFetchedResultsController will be created automatically on ViewController initialization.
 */
@property(nonatomic, strong) NSFetchedResultsController     *fetchedResultsController;

@end
