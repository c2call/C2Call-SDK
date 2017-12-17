//
//  SCFriendListController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 05.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

#import "SCFriendListController.h"
#import "SCDataManager.h"
#import "UIViewController+SCCustomViewController.h"
#import "SCFriendListCell.h"
#import "SCGroupDetailController.h"
#import "SCFriendDetailController.h"
#import "C2CallAppDelegate.h"
#import "C2CallPhone.h"
#import "SIPPhone.h"
#import "C2CallConstants.h"
#import "MOC2CallUser.h"
#import "MOPhoneNumber.h"
#import "AlertUtil.h"
#import "C2TapImageView.h"
#import "SCPopupMenu.h"
#import "SCAssetManager.h"


#import "debug.h"


@interface SCFriendListController ()
{
    CFAbsoluteTime      lastContentChange, lastSearch;
    
    UIImage             *friendImage, *groupImage, *callLinkImage, *testCallImage;
    UIColor             *regularCellBackground;

    int                 colorCounter;
    BOOL                activeFilterChoice, hasGroupCell, hasCallLinkCell, hasTestCallCell;
}

@property (strong, nonatomic) NSFetchedResultsController    *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;

@property(nonatomic, strong) NSManagedObjectID              *selectedUser;
@property (nonatomic, strong) NSPredicate                    *activeFilter, *textFilter, *usertypeFilter;
@property (nonatomic, strong) NSString                       *filterText;
@property (nonatomic, strong) NSArray                        *filterList;
@property (nonatomic, strong) NSDate                         *compareDate;
@property (nonatomic, strong) MOC2CallUser                   *selectedFriend;

@end

@implementation SCFriendListController
@synthesize highlightedCellBackground, fetchedResultsController, managedObjectContext, activeFilter, textFilter, usertypeFilter;
@synthesize filterList, compareDate, selectedUser, filterText, activeFilterInfo, selectedFriend, friendDetailAction;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.highlightedCellBackground = [UIColor colorWithRed:(254./255.) green:(254./255.) blue:(227. / 255.) alpha:1.0];
    }
    return self;
}

- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"selectedUser"];
    }
    @catch (NSException *exception) {
        
    }
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.highlightedCellBackground = [UIColor colorWithRed:(254./255.) green:(254./255.) blue:(227. / 255.) alpha:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DLog(@"SCFriendListController:viewDidLoad");
    
    // Get predefined avatar images
    SCFriendListCell *cell = (SCFriendListCell *) [self.tableView dequeueReusableCellWithIdentifier:@"SCFriendListCell"];
    friendImage = cell.userImage.image;
    cell = (SCFriendListCell *) [self.tableView dequeueReusableCellWithIdentifier:@"SCGroupCell"];
    if (cell) {
        hasGroupCell = YES;
        groupImage = cell.userImage.image;
    }
    cell = (SCFriendListCell *) [self.tableView dequeueReusableCellWithIdentifier:@"SCCallLinkCell"];
    if (cell) {
        hasCallLinkCell = YES;
        callLinkImage = cell.userImage.image;
    }
    cell = (SCFriendListCell *) [self.tableView dequeueReusableCellWithIdentifier:@"SCTestCallCell"];
    if (cell) {
        hasTestCallCell = YES;
        testCallImage = cell.userImage.image;
    }
    
    // compareDate 1 week
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeekOfYear:-2];
    self.compareDate = [cal dateByAddingComponents:offsetComponents toDate:today options:0];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"C2CallDataManager:initData" object:nil];
    [nc addObserver:self selector:@selector(handleNotification:) name:@"DataUpdateEvent" object:nil];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"UserImageUpdate" object:nil];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"GroupCallUserLeft" object:nil];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"GroupCallUserJoined" object:nil];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"C2Call:LogoutUser" object:nil];
    
    NSMutableDictionary *all = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"All", @"Filter"), @"name", @"allFilter", @"filter", nil];
    NSMutableDictionary *online = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Online", @"Filter"), @"name", @"onlineFilter", @"filter", nil];
    NSMutableDictionary *recent = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Recent", @"Filter"), @"name", @"recentFilter", @"filter", nil];
    NSMutableDictionary *favorites = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Favorites", @"Filter"), @"name", @"favoriteFilter", @"filter", nil];
    NSMutableDictionary *groups = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Groups", @"Filter"), @"name", @"groupsFilter", @"filter", nil];
    NSMutableDictionary *friends = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Friends", @"Filter"), @"name", @"friendsFilter", @"filter", nil];
    NSMutableDictionary *onlineFriends = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Online Friends", @"Filter"), @"name", @"onlineFriendsFilter", @"filter", nil];
    
    self.filterList = [NSArray arrayWithObjects:all, online, recent, favorites, groups, friends, onlineFriends, nil];
    
    int active = [[[NSUserDefaults standardUserDefaults] objectForKey:@"activeFilter"] intValue];
    if (active >= [self.filterList count])
        active = 0;
    
    [[self.filterList objectAtIndex:active] setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
    
    [self refreshActiveFilter];
    if (self.activeFilter || self.textFilter)
        [self refetchResults];
    
    [self refreshFilterInfo];
    
    [self addObserver:self forKeyPath:@"selectedUser" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableView];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
-(void) viewWillDisappear:(BOOL) animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CoreData

-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized) {
        return nil;
    }

    self.sectionNameKeyPath = @"indexAttribute";
    self.useDidChangeContentOnly = YES;
    
    BOOL sortByFirstName = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_SORTBYFIRSTNAME];

    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForFriendlist:sortByFirstName];

    self.usertypeFilter = [fetchRequest predicate];
    
    return fetchRequest;
}

-(void) initFetchedResultsController
{
    [super initFetchedResultsController];
    
    // Do a couple of initialzations
    [self refreshActiveFilter];
    if (self.activeFilter || self.textFilter)
        [self refetchResults];
    
    [self refreshFilterInfo];
    
    [self reloadTableView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLog(@"controllerDidChangeContent");
    
    lastContentChange = CFAbsoluteTimeGetCurrent();
    double delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (CFAbsoluteTimeGetCurrent() - lastContentChange > 0.5) {
            colorCounter = 0;
            [self reloadTableView];
        }
    });
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

-(void) reloadTableView
{
    if (!self.searchDisplayController.active) {
        [self.tableView reloadData];
    } else {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}
#pragma clang diagnostic pop

-(void) refetchResults
{
    colorCounter = 0;
    [self.fetchedResultsController performFetch:nil];
    [self refreshFilterInfo];
    [self reloadTableView];
}

#pragma mark Observer & Notifications

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedUser"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            if ([oldValue isKindOfClass:[NSNull class]])
                oldValue = nil;
            
            id newValue = [change objectForKey:NSKeyValueChangeNewKey];
            if ([newValue isKindOfClass:[NSNull class]])
                newValue = nil;
            
            MOC2CallUser *foundElement = nil;
            NSMutableArray *indexPathList = [NSMutableArray arrayWithCapacity:2];
            
            if (oldValue  && ![oldValue isEqual:newValue]) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"objectID == %@", oldValue];
                NSArray *result = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:p];
                if ([result count] > 0) {
                    foundElement = [result objectAtIndex:0];
                    
                    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:foundElement];
                    if (indexPath) {
                        [indexPathList addObject:indexPath];
                    }
                }
            }
            
            if (newValue && ![newValue isEqual:oldValue]) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"objectID == %@", newValue];
                NSArray *result = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:p];
                if ([result count] > 0) {
                    foundElement = [result objectAtIndex:0];
                    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:foundElement];
                    if (indexPath) {
                        [indexPathList addObject:indexPath];
                    }
                }
            }
            if ([indexPathList count] > 0) {
                @try {
                    [self.tableView reloadRowsAtIndexPaths:indexPathList withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                @catch (NSException *exception) {
                    XLog(@"Exception : reload : %@", exception);
                    [self reloadTableView];
                }
            }
        });
        
    }
}

-(void) handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"C2Call:LogoutUser"]) {
        self.fetchedResultsController.delegate = nil;
        self.fetchedResultsController = nil;
        [self removeAllFilter:nil];
        [self refreshFilterInfo];
        [self reloadTableView];
    }
    
    if ([[notification name] isEqualToString:@"UserImageUpdate"]) {
        [self reloadTableView];
    }
    
    if ([[notification name] isEqualToString:@"GroupCallUserLeft"]) {
        [self reloadTableView];
    }
    
    if ([[notification name] isEqualToString:@"GroupCallUserJoined"]) {
        [self reloadTableView];
    }
    
    if ([[notification name] isEqualToString:@"DataUpdateEvent"] && [[notification userInfo] objectForKey:@"RelationEvents"]) {
        [self reloadTableView];
    }
    
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 1;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return nil;
    }
	
	return [self.fetchedResultsController sectionIndexTitles];
}
*/

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return nil;
    }
    
    NSArray *sections = [self.fetchedResultsController sections];
    
    id<NSFetchedResultsSectionInfo> sec = nil;
    
    NSMutableArray *indexlist = [NSMutableArray arrayWithCapacity:[sections count] + 1];
    for (sec in sections) {
        NSString *name = [sec name];
        NSString *idx = [sec indexTitle];
        if ([idx length] > 0) {
            [indexlist addObject:idx];
        } else if ([name length] > 0) {
            [indexlist addObject:[name substringToIndex:1]];
        }
    }
    //NSArray *indexList = [self.fetchedResultsController sectionIndexTitles];
    return indexlist;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return nil;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return  [sectionInfo name];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static CGFloat friendCellHeight = 0;
    static CGFloat noRecordsCellHeight = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SCFriendListCell"];
        friendCellHeight = cell.frame.size.height;
        cell = [tableView dequeueReusableCellWithIdentifier:@"SCNoRecordsCell"];
        noRecordsCellHeight = cell.frame.size.height;
    });

    if ([SCDataManager instance].isDataInitialized && [[self.fetchedResultsController fetchedObjects] count] == 0) {
        return noRecordsCellHeight;
    }
    
    return friendCellHeight;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        if ([cell isKindOfClass:[SCFriendListCell class]]) {
            SCFriendListCell *ccell = (SCFriendListCell *) cell;
            if (ccell.highlightBackground) {
                if (!regularCellBackground && cell.backgroundColor && ![cell.backgroundColor isEqual:self.highlightedCellBackground]) {
                    DLog(@"Regular CellBackground : %@", cell.backgroundColor);
                    regularCellBackground = cell.backgroundColor;
                }
                cell.backgroundColor = self.highlightedCellBackground;
            } else {
                if ([cell.backgroundColor isEqual:self.highlightedCellBackground]) {
                    DLog(@"Setting Regular CellBackground : %@", regularCellBackground);
                    cell.backgroundColor = regularCellBackground;
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
}

-(void) configureCell:(SCFriendListCell *) cell forElement:(MOC2CallUser *) elem atIndexPath:(NSIndexPath *) indexPath
{
    [cell reset];
    
    NSUInteger idx = [self.fetchedResultsController.fetchedObjects indexOfObject:elem];
    if (idx != NSNotFound)
        cell.tag = idx;
    
    BOOL isGroupCall =[elem.userType intValue] == 2;
    
    BOOL isTestCall = NO;
	if (elem.userid && [elem.userid isEqualToString:@"9bc2858f1194dc1c107"]) {
		isTestCall = YES;
	}
    BOOL callLink = NO;
	if ([elem.email hasPrefix:@"link"] && [elem.email rangeOfString:@"@@"].location == NSNotFound) {
		callLink = YES;
	}
    
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    cell.userid = elem.userid;
    cell.highlightBackground = NO;

    cell.labelName.text = elem.displayName;
    switch ([elem.onlineStatus intValue]) {
        case OS_OFFLINE:
            cell.labelDetail.text = NSLocalizedString(@"offline", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_offline" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = [UIColor darkGrayColor];
            break;
        case OS_ONLINE:
            cell.labelDetail.text = NSLocalizedString(@"online", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_idle" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = DEFAULT_IDLECOLOR;
            break;
        case OS_FORWARDED:
            cell.labelDetail.text = NSLocalizedString(@"Call forward", @"Cell Label");
            break;
        case OS_INVISIBLE:
            cell.labelDetail.text = NSLocalizedString(@"offline", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_offline" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = [UIColor darkGrayColor];
            break;
        case OS_AWAY:
            cell.labelDetail.text = NSLocalizedString(@"offline (away)", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_offline" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = [UIColor darkGrayColor];
            break;
        case OS_BUSY:
            cell.labelDetail.text = NSLocalizedString(@"offline (busy)", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_offline" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = [UIColor darkGrayColor];
            break;
        case OS_CALLME:
            if (isGroupCall) {
                NSArray *active = [[C2CallPhone currentPhone] activeMembersInCallForGroup:elem.userid];
                BOOL video = [[C2CallPhone currentPhone] activeVideoCallForGroup:elem.userid];
                
                NSUInteger count = [active count];
                if (count > 0) {
                    if (count == 1) {
                        if (video) {
                            cell.labelDetail.text = [NSString stringWithFormat:NSLocalizedString(@"video conference (%d user)", @"Cell Label Einzahl"), count];
                        } else {
                            cell.labelDetail.text = [NSString stringWithFormat:NSLocalizedString(@"active conference (%d user)", @"Cell Label Einzahl"), count];
                        }
                    } else {
                        if (video) {
                            cell.labelDetail.text = [NSString stringWithFormat:NSLocalizedString(@"video conference (%d user)", @"Cell Label Mehrzahl"), count];
                        } else {
                            cell.labelDetail.text = [NSString stringWithFormat:NSLocalizedString(@"active conference (%d user)", @"Cell Label Mehrzahl"), count];
                        }
                        
                    }
                } else {
                    if (video) {
                        cell.labelDetail.text = NSLocalizedString(@"video conference", @"Cell Label");
                    } else {
                        cell.labelDetail.text = NSLocalizedString(@"active conference", @"Cell Label");
                    }
                }
                
                cell.highlightBackground = YES;
            } else {
                cell.labelDetail.text = NSLocalizedString(@"online (call me)", @"Cell Label");
            }
            break;
        case OS_ONLINEVIDEO:
            cell.labelDetail.text = NSLocalizedString(@"online (active)", @"Cell Label");
            cell.videoStatusIcon.hidden = NO;
            break;
        case OS_IPUSH:
            cell.labelDetail.text = NSLocalizedString(@"online", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_idle" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = DEFAULT_IDLECOLOR;
            break;
        case OS_IPUSHCALL:
            cell.labelDetail.text = NSLocalizedString(@"online", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_idle" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = DEFAULT_IDLECOLOR;
            break;
        default:
            cell.labelDetail.text = NSLocalizedString(@"offline", @"Cell Label");
            cell.onlineStatusIcon.image = [UIImage imageNamed:@"btn_ico_offline" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            cell.labelDetail.textColor = [UIColor darkGrayColor];
            
            
    }
    
    if ([elem.userStatus length] > 0) {
        cell.labelDetail.text = elem.userStatus;
    }
    
    cell.facebookIcon.hidden = ![elem.facebook boolValue];
    cell.favoriteImage.hidden = ![elem.favorite boolValue];
    
    [cell.detailDisclose removeTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];

    if (elem.userid) {
        // It's a friend
        if (isTestCall) {
            cell.detailDisclose.hidden = YES;
        } else
            if (isGroupCall) {
                UIImage *userimage = [[C2CallPhone currentPhone] userimageForUserid:elem.userid];
                if (userimage) {
                    cell.userImage.image = userimage;
                } else {
                    cell.userImage.image = hasGroupCell?groupImage:[UIImage imageNamed:@"btn_ico_avatar_group" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
                }
                [cell.detailDisclose  addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
                cell.detailDisclose.tag = indexPath.section * 1000 + indexPath.row;
                cell.accessoryView.tag = indexPath.section * 1000 + indexPath.row;
            } else
                if (callLink) {
                    cell.detailDisclose.hidden = YES;
                    cell.userImage.image = hasCallLinkCell?callLinkImage:[UIImage imageNamed:@"iphone_call_me_link" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
                    if (![elem.confirmed boolValue]) {
                        cell.labelDetail.text = NSLocalizedString(@"disabled", @"Cell Label");
                    }
                } else {
                    UIImage *userimage = [[C2CallPhone currentPhone] userimageForUserid:elem.userid];
                    if (userimage)
                        cell.userImage.image = userimage;
                    else
                        cell.userImage.image = friendImage;
                    
                    [cell.detailDisclose  addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
                    cell.detailDisclose.tag = indexPath.section * 1000 + indexPath.row;
                    cell.accessoryView.tag = indexPath.section * 1000 + indexPath.row;
                }
        
        //        if ([missedCalls containsObject:elem.userid]) {
        if ([[SCDataManager instance] missedCallsForContact:elem.userid] > 0) {
            cell.labelName.textColor = [UIColor redColor];
        } else {
            cell.labelName.textColor = [UIColor colorWithRed:0x11/255. green:0x1e/255. blue:0x36/255. alpha:1.0];
        }
        
        if ([self.compareDate compare:elem.recentIndicationDate] == NSOrderedAscending) {
            cell.labelDetail.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_new_contact" inBundle:frameWorkBundle compatibleWithTraitCollection:nil]];
            cell.labelDetail.leftViewMode = UITextFieldViewModeAlways;
        }
        
    } else {
        // It's a contact
        cell.userImage.image = [UIImage imageNamed:@"btn_ico_adressbook_contact" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        [cell.detailDisclose  addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
        cell.detailDisclose.tag = indexPath.section * 1000 + indexPath.row;
        cell.accessoryView.tag = indexPath.section * 1000 + indexPath.row;
    }
    
    if (self.selectedUser && [elem.objectID isEqual:self.selectedUser]) {
        cell.selected = YES;
        cell.detailDisclose.selected = YES;
    } else {
        cell.selected = NO;
        cell.detailDisclose.selected = NO;
    }
    
}

-(BOOL) isOfflineStatus:(int) status
{
    switch (status) {
        case OS_OFFLINE:
            return YES;
        case OS_ONLINE:
            return NO;
        case OS_FORWARDED:
            return NO;
        case OS_INVISIBLE:
            return YES;
        case OS_AWAY:
            return YES;
        case OS_BUSY:
            return YES;
        case OS_CALLME:
            return NO;
        case OS_ONLINEVIDEO:
            return NO;
        case OS_IPUSH:
            return NO;
        case OS_IPUSHCALL:
            return YES;
        case OS_GROUPCALL:
            return YES;
    }
    return NO;
    
}


-(NSString *) cellIdentifierForElement:(MOC2CallUser *) elem atIndexPath:(NSIndexPath *) indexPath
{
    BOOL isGroupCall =[elem.userType intValue] == 2;
    
	if (elem.userid && [elem.userid isEqualToString:@"9bc2858f1194dc1c107"]) {
        return @"SCTestCallCell";
	}

	if ([elem.email hasPrefix:@"link"] && [elem.email rangeOfString:@"@@"].location == NSNotFound) {
        return @"SCCallLinkCell";
	}

    if (isGroupCall) {
        return @"SCGroupCell";
    }
    
    if (self.selectedUser && [self.selectedUser isEqual:elem.objectID] && elem.userid && ![self isOfflineStatus:[elem.onlineStatus intValue]]) {
        return @"SCFriendListCell";
    }
    
    return @"SCFriendListCell";
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallUser *elem = nil;
    @try {
        elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        return;
    }

    [self configureCell:(SCFriendListCell *)cell forElement:elem atIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SCNoRecordsCell"];
        /*
        if (self.activeFilter || self.textFilter) {
            cell.textLabel.text = NSLocalizedString(@"Search result is empty.\nTouch to remove search filter!", @"CellText");
        } else {
            cell.textLabel.text = nil;//NSLocalizedString(@"No FriendCaller contacts found.", @"CellText");
        }
        */
        return cell;
    }

    MOC2CallUser *elem = nil;
    @try {
        elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    @catch (NSException *exception) {
    }

    NSString *cellIndentifier = [self cellIdentifierForElement:elem atIndexPath:indexPath];
    
    SCFriendListCell *cell = (SCFriendListCell *) [self.tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = (SCFriendListCell *) [self.tableView dequeueReusableCellWithIdentifier:@"SCFriendListCell"];
    }
    
    // Configure the cell...
    if (elem) {
        [self configureCell:cell forElement:elem atIndexPath:indexPath];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return NO;
    }
    
    @try {
        MOC2CallUser *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (elem.userid) {
            // It's a friend
            if (elem.userid && [elem.userid isEqualToString:@"9bc2858f1194dc1c107"]) {
                return NO;
            }
            if ([elem.email hasPrefix:@"link"] && [elem.email rangeOfString:@"@@"].location == NSNotFound) {
                return NO;
            }
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	DLog(@"Commit Editing for : %ld, %ld", (long)indexPath.section, (long)indexPath.row);
	@try {
        MOC2CallUser *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (elem) {
            [[SCDataManager instance] removeDatabaseObject:elem];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Exception : %@", exception);
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tv cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"SCNoRecordsCell"]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.searchDisplayController setActive:NO animated:YES];
#pragma GCC diagnostic pop
        
        [self removeAllFilter:self];
        return;
    }
    
    MOC2CallUser *elem = nil;
    @try {
        elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSString *userid = elem.userid;
        BOOL isTestCall = NO;
        if (userid && [userid isEqualToString:@"9bc2858f1194dc1c107"]) {
            isTestCall = YES;
        }
        
        if (isTestCall) {
            [self callTestCall:self];
            return;
        }
        
        // Handle CallMe Link
        if ([elem.email hasPrefix:@"link"] && [elem.email rangeOfString:@"@@"].location == NSNotFound) {
        }

        switch (friendDetailAction) {
            case SCFriendDetailAction_FriendDetail:
                [self showFriendDetail:elem];
                break;
            case SCFriendDetailAction_Chat:
                [self showChatForUserid:elem.userid];
                break;
                
            default:
                [self showFriendDetail:elem];
                break;
        }
    }
    @catch (NSException *exception) {
        DLog(@"didSelectRowAtIndexPath(%ld / %ld) : %@", (long)indexPath.section, (long)indexPath.row, exception);
#ifdef __C2DEBUG
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
#endif
        DLog(@"didSelectRowAtIndexPath : %ld / %lu", (long)indexPath.section, (unsigned long)[sectionInfo numberOfObjects]);
        
        return;
    }
    
}

#pragma mark Filter Handling

-(void) refreshFilterInfo
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected = YES"];
    NSArray *selected = [self.filterList filteredArrayUsingPredicate:predicate];
    
    NSString *activeFilterName = nil;
    if ([selected count] > 0) {
        NSString *filter = [[selected objectAtIndex:0] objectForKey:@"filter"];
        if ([filter isEqualToString:@"onlineFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
        if ([filter isEqualToString:@"recentFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
        if ([filter isEqualToString:@"favoriteFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
        if ([filter isEqualToString:@"groupsFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
        if ([filter isEqualToString:@"friendsFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
        if ([filter isEqualToString:@"onlineFriendsFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
    }
    
    if ([filterText length] == 0)
        filterText = nil;
    
    if (!activeFilterName && !filterText) {
        self.activeFilterInfo = nil;
    } else {
        
        if (activeFilterName && filterText) {
            self.activeFilterInfo = [NSString stringWithFormat:@"%@ : %@, '%@'", NSLocalizedString(@"Filter", @"Filter"), activeFilterName, filterText];
        } else if (activeFilterName) {
            self.activeFilterInfo = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Filter", @"Filter"), activeFilterName];
        } else {
            self.activeFilterInfo = [NSString stringWithFormat:@"%@ : '%@'", NSLocalizedString(@"Filter", @"Filter"), filterText];
        }
    }
}

-(void) setFriendFilter:(SCFriendListFilterType)filter
{
    NSMutableDictionary *dict = nil;
    NSString *filterkey = @"allFilter";
    switch (filter) {
        case SCFriendFilter_FAVORITE:
            filterkey =@"favoriteFilter";
            break;
        case SCFriendFilter_GROUPS:
            filterkey =@"groupsFilter";
            break;
        case SCFriendFilter_ONLINE:
            filterkey =@"onlineFilter";
            break;
        case SCFriendFilter_RECENT:
            filterkey =@"recentFilter";
            break;
        case SCFriendFilter_FRIENDS:
            filterkey =@"friendsFilter";
            break;
        case SCFriendFilter_ONLINEFRIENDS:
            filterkey =@"onlineFriendsFilter";
            break;
        default:
            break;
    }
    
    DLog(@"setFriendFilter : %@", filterkey);
    
    for (NSMutableDictionary *f in self.filterList) {
        [f setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        if ([[f objectForKey:@"filter"] isEqualToString:filterkey]) {
            DLog(@"Found Filter : %@", f);
            
            dict = f;
        }
    }
    [dict setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshActiveFilter];
        [self refetchResults];
    });

}

-(void) refreshActiveFilter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected = YES"];
    NSArray *selected = [self.filterList filteredArrayUsingPredicate:predicate];
    
    int filterType = 0;
    if ([selected count] > 0) {
        NSString *filter = [[selected objectAtIndex:0] objectForKey:@"filter"];
        if ([filter isEqualToString:@"allFilter"]) {
            filterType = 0;
        }
        if ([filter isEqualToString:@"onlineFilter"]) {
            filterType = 1;
        }
        if ([filter isEqualToString:@"recentFilter"]) {
            filterType = 2;
        }
        if ([filter isEqualToString:@"favoriteFilter"]) {
            filterType = 3;
        }
        if ([filter isEqualToString:@"groupsFilter"]) {
            filterType = 4;
        }
        if ([filter isEqualToString:@"friendsFilter"]) {
            filterType = 5;
        }
        if ([filter isEqualToString:@"onlineFriendsFilter"]) {
            filterType = 6;
        }
    }
    switch (filterType) {
        case 0:
            self.activeFilter = nil;
            break;
        case 1:
            self.activeFilter = [NSPredicate predicateWithFormat:@"online = YES"];
            break;
        case 2:
            self.activeFilter = [NSPredicate predicateWithFormat:@"lastActivity >= %@ or recentIndicationDate >= %@", compareDate, compareDate];
            break;
        case 3:
            self.activeFilter = [NSPredicate predicateWithFormat:@"favorite = YES"];
            break;
        case 4:
            self.activeFilter = [NSPredicate predicateWithFormat:@"userType == 2"];
            break;
        case 5:
            self.activeFilter = [NSPredicate predicateWithFormat:@"userType == 0"];
            break;
        case 6:
            self.activeFilter = [NSPredicate predicateWithFormat:@"userType == 0 and online = YES"];
            break;
            
        default:
            break;
    }
    
    if (self.activeFilter) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:filterType] forKey:@"activeFilter"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activeFilter"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:4];
    if (self.usertypeFilter)
        [predicates addObject:self.usertypeFilter];
    
    if (self.activeFilter) {
        [predicates addObject:self.activeFilter];
    }
    
    if (self.textFilter) {
        [predicates addObject:self.textFilter];
    }
    
    if ([predicates count] > 0) {
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [fetch setPredicate:predicate];
    } else {
        [fetch setPredicate:nil];
    }
}

-(void) removeTextFilter
{
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:4];
    if (self.usertypeFilter)
        [predicates addObject:self.usertypeFilter];
    
    if (self.activeFilter)
        [predicates addObject:self.activeFilter];
    
    self.textFilter = nil;
    self.filterText = nil;

    if ([predicates count] > 0) {
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [fetch setPredicate:predicate];
    } else {
        [fetch setPredicate:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"textFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setTextFilterForText:(NSString *) text
{
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:4];
    if (self.usertypeFilter)
        [predicates addObject:self.usertypeFilter];
    
    if (self.activeFilter)
        [predicates addObject:self.activeFilter];
    
    self.textFilter = [NSPredicate predicateWithFormat:@"displayName contains[cd] %@ OR email contains[cd] %@", text, text];
    [predicates addObject:self.textFilter];
    
    if ([predicates count] > 0) {
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [fetch setPredicate:predicate];
    } else {
        [fetch setPredicate:nil];
    }
    
    if (text) {
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"textFilter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark Segue Handling

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
}

#pragma mark Actions

-(void) scrollTop
{
    @try {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    @catch (NSException *exception) {
        
    }
}

-(IBAction)showDetail:(id)sender
{
    int tag = (int)[sender tag];
    int section = tag / 1000;
	int row = tag - (section * 1000);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    MOC2CallUser *elem = nil;
    @try {
        elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        switch (friendDetailAction) {
            case SCFriendDetailAction_FriendDetail:
                [self showFriendDetail:elem];
                break;
            case SCFriendDetailAction_Chat:
                [self showChatForUserid:elem.userid];
                break;
                
            default:
                [self showFriendDetail:elem];
                break;
        }
    }
    @catch (NSException *exception) {
        DLog(@"didSelectRowAtIndexPath(%ld / %ld) : %@", (long)indexPath.section, (long)indexPath.row, exception);
#ifdef __C2DEBUG
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
#endif
        DLog(@"didSelectRowAtIndexPath : %ld / %lu", (long)indexPath.section, (unsigned long)[sectionInfo numberOfObjects]);
        
        return;
    }
    
}

-(void)showFriendDetail:(MOC2CallUser *)elem
{
    self.selectedFriend = elem;
    if ([elem.userType intValue] == 2) {
        [self showGroupDetailForGroupid:elem.userid];
    } else {
        [self showFriendDetailForUserid:elem.userid];
    }
}

-(IBAction)filterMenu:(id)sender
{
    SCPopupMenu *popup = [SCPopupMenu popupMenu:self];
    
    [popup addChoiceWithName:NSLocalizedString(@"Remove Filter", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self removeAllFilter:nil];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Online", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_ONLINE];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Groups", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_GROUPS];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Friends", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_FRIENDS];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Favorites", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_FAVORITE];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Recent", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setFriendFilter:SCFriendFilter_RECENT];
    }];

    [popup addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [popup showMenu];    
}

-(IBAction)removeAllFilter:(id)sender
{
    for (NSMutableDictionary *f in self.filterList) {
        [f setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
    }
    NSMutableDictionary *all = [self.filterList objectAtIndex:0];
    [all setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
    
    self.activeFilter = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activeFilter"];
    [self removeTextFilter];
    
    [self refetchResults];
}

-(IBAction) callTestCall:(id) sender;
{
	if (![SIPPhone currentPhone].isOnline) {
		return;
	}
	
	
	[[SIPPhone currentPhone] callVoIP:@"9bc2858f1194dc1c107"];
}

#pragma mark UISearchDisplayController Delegate Methods

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString length] > 0) {
        [self setTextFilterForText:searchString];
    } else {
        [self removeTextFilter];
    }
    [self refetchResults];

    // Return NO, as the search will be done in the background
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self setTextFilterForText:[self.searchDisplayController.searchBar text]];
    [self refetchResults];

    // Return NO, as the search will be done in the background
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    DLog(@"searchDisplayControllerDidBeginSearch");
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    DLog(@"searchDisplayControllerDidEndSearch");
    [self removeTextFilter];
    [self refetchResults];

    
    return;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)_tableView
{
}
#pragma GCC diagnostic pop

@end
