//
//  SCFriendDetailController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 06.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import "SCFriendDetailController.h"
#import "UIViewController+SCCustomViewController.h"
#import "SCDataManager.h"
#import "MOC2CallUser.h"
#import "MOC2CallGroup.h"
#import "MOGroupMember.h"
#import "MOCallHistory.h"
#import "UDUserInfoCell.h"
#import "UDConnectionCell.h"
#import "UDPhoneCell.h"
#import "C2TapImageView.h"
#import "MOPhoneNumber.h"
#import "C2BlockAction.h"
#import "C2BarButtonItem.h"
#import "AlertUtil.h"
#import "SCPopupMenu.h"
#import "SCChatController.h"
#import "SCAffiliateInfo.h"
#import "C2CallConstants.h"
#import "SCHorizontalLineView.h"
#import "SIPPhone.h"
#import "DateUtil.h"

#import "debug.h"

@interface SCFriendDetailController () <UITextFieldDelegate> {
    BOOL addNumber, editNumber, modified, hasFriendNumbers, hasContactNumbers, hasAllContactNumbers;
    CGRect  userStatusFrame;
    CGRect  statusDurationFrame;

}

@property(nonatomic, weak) UDPhoneCell        *firstResponderCell;

@property(nonatomic, assign) BOOL launchFromMessagePane;


@end

@implementation SCFriendDetailController
@synthesize userInfoCell, connectionCell;
@synthesize managedObjectId, addPhoneNumberHeader, firstResponderCell, launchFromMessagePane, btnEditNumber, btnAddNumber, labelAddPhoneNumber;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    DLog(@"SCFriendDetailController:dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    DLog(@"SCFriendDetailController:viewDidLoad");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"C2Call:LogoutUser" object:nil];
    
    self.labelAddPhoneNumber.text = NSLocalizedString(@"Add Phone Number", @"Label");
    
    self.userInfoCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCUserInfoCell"];
    self.connectionCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCConnectionCell"];
    
    [self restoreRightBarButton];
    
    userStatusFrame = userInfoCell.userStatus.frame;
    statusDurationFrame = userInfoCell.statusDuration.frame;
}

-(void) handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"C2Call:LogoutUser"]) {
        [self closeViewControllerWithoutAnimation:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
}

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 12.;
    }
    
    if (hasFriendNumbers) {
        if (section == 3) {
            return self.addPhoneNumberHeader.frame.size.height;
        }
    } else {
        if (section == 2) {
            return self.addPhoneNumberHeader.frame.size.height;
        }
    }
    
    return 22;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (hasFriendNumbers) {
        if (section == 3) {
            self.btnEditNumber.hidden = !hasContactNumbers;
            self.btnAddNumber.enabled = !hasAllContactNumbers;
            return self.addPhoneNumberHeader;
        }
    } else {
        if (section == 2) {
            self.btnEditNumber.hidden = !hasContactNumbers;
            self.btnAddNumber.enabled = !hasAllContactNumbers;
            return self.addPhoneNumberHeader;
        }
    }
    
    
    return nil;
}

-(CGFloat) heightForUserInfoCell
{
    if (!self.userInfoCell.userStatus) {
        return self.userInfoCell.frame.size.height;
    }
    
    MOC2CallUser *user = [self currentUser];
    
    CGRect frame = userStatusFrame;
    CGRect f2 = statusDurationFrame;
    
    if ([user.userStatus length] == 0) {
        return frame.origin.y;
    }
    
    CGFloat height = frame.origin.y;
    
    //CGSize sz = [user.userStatus sizeWithFont:userInfoCell.userStatus.font constrainedToSize:CGSizeMake(frame.size.width, 66.)];
    CGSize sz = [user.userStatus boundingRectWithSize:CGSizeMake(frame.size.width, 66.) options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:userInfoCell.userStatus.font} context:nil].size;

    height += sz.height;
    height += (f2.origin.y - (frame.origin.y + frame.size.height)) + f2.size.height + 3;
    
    return height;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self heightForUserInfoCell];
        case 1:
            return 44.;
        case 2:
            return 44.;
        case 3:
            return 44.;
        default:
            break;
    }
    
    return 44.;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        return 1;
    
    int section = 3;
    MOC2CallUser *user = [self currentUser];
    if ([user.friendNumbers count] > 0) {
        section++;
        hasFriendNumbers = YES;
    } else {
        hasFriendNumbers = NO;
    }
    
    if ([user.contactNumbers count] > 0)
        hasContactNumbers = YES;
    else
        hasContactNumbers = NO;
    
    if ([user.contactNumbers count] >= 4)
        hasAllContactNumbers = YES;
    else
        hasAllContactNumbers = NO;
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        return 0;
    
    MOC2CallUser *elem = [self currentUser];
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            if ([elem.friendNumbers count] > 0)
                return [elem.friendNumbers count];
            return [elem.contactNumbers count];
        case 3:
            return [elem.contactNumbers count];
        default:
            break;
    }
    return 0;
}

-(void) configureUserInfoCell:(MOC2CallUser *) elem
{
    userInfoCell.displayName.text = elem.displayName;
    userInfoCell.email.text = elem.email;
    
    self.userInfoCell.onlineStatus.textColor = [UIColor colorWithRed:(123./255.) green:(152./255.) blue:(42. / 255.) alpha:1.0];
    
    switch ([elem.onlineStatus intValue]) {
        case OS_OFFLINE:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"offline", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = [UIColor darkGrayColor];
            break;
        case OS_ONLINE:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"online", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = DEFAULT_IDLECOLOR;
            break;
        case OS_FORWARDED:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"Call forward", @"Cell Label");
            break;
        case OS_INVISIBLE:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"offline", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = [UIColor darkGrayColor];
            break;
        case OS_AWAY:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"offline (away)", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = [UIColor darkGrayColor];
            break;
        case OS_BUSY:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"offline (busy)", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = [UIColor darkGrayColor];
            break;
        case OS_CALLME:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"online (call me)", @"Cell Label");
            break;
        case OS_ONLINEVIDEO:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"online (active)", @"Cell Label");
            break;
        case OS_IPUSH:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"online", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = DEFAULT_IDLECOLOR;
            break;
        case OS_IPUSHCALL:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"online", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = DEFAULT_IDLECOLOR;
            break;
        default:
            self.userInfoCell.onlineStatus.text = NSLocalizedString(@"offline", @"Cell Label");
            self.userInfoCell.onlineStatus.textColor = [UIColor darkGrayColor];
    }
    
    self.userInfoCell.facebookImage.hidden = ![elem.facebook boolValue];
    self.userInfoCell.favoriteImage.hidden = ![elem.favorite boolValue];
    
    UIImage *userImage = [[C2CallPhone currentPhone] userimageForUserid:elem.userid];
    
    if (userImage) {
        self.userInfoCell.userImage.image = userImage;
        [self.userInfoCell.userImage setTapAction:^{
            [self showUserImageForUserid:elem.userid];
        }];
    }
    
    if ([elem.userStatus length] > 0) {
        CGRect frame = userStatusFrame;
//        CGSize sz = [elem.userStatus sizeWithFont:userInfoCell.userStatus.font constrainedToSize:CGSizeMake(frame.size.width, 66.)];
        CGSize sz = [elem.userStatus boundingRectWithSize:CGSizeMake(frame.size.width, 66.) options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:userInfoCell.userStatus.font} context:nil].size;

        frame.size.height = sz.height;
        userInfoCell.userStatus.frame = frame;
        userInfoCell.userStatus.text = elem.userStatus;
        userInfoCell.userStatus.hidden = NO;
        userInfoCell.lineView.hidden = NO;
        userInfoCell.lineView.lineWidth = 0.5;
        
        if (elem.userStatusDate) {
            userInfoCell.statusDuration.text = [DateUtil timeAgoForDate:elem.userStatusDate];
            userInfoCell.statusDuration.hidden = NO;
        }
    } else {
        userInfoCell.statusDuration.hidden = YES;
        userInfoCell.userStatus.hidden = YES;
        userInfoCell.lineView.hidden = YES;
    }

    return;
}

-(void) configureConnectionCell:(MOC2CallUser *) elem
{
    if (!self.connectionCell) {
        [[NSBundle mainBundle] loadNibNamed:@"UDConnectionCell" owner:self options:nil];
    }
    
    [self.connectionCell.btnCallVoice setEnabled:YES];
    [self.connectionCell.btnCallVideo setEnabled:YES];
    [self.connectionCell.btnChat setEnabled:YES];
    
    switch ([elem.onlineStatus intValue]) {
        case OS_OFFLINE:
            [self.connectionCell.btnCallVoice setEnabled:YES];
            [self.connectionCell.btnCallVideo setEnabled:NO];
            break;
        case OS_ONLINE:
            break;
        case OS_FORWARDED:
            break;
        case OS_INVISIBLE:
            [self.connectionCell.btnCallVoice setEnabled:YES];
            [self.connectionCell.btnCallVideo setEnabled:NO];
            break;
        case OS_AWAY:
            [self.connectionCell.btnCallVoice setEnabled:YES];
            [self.connectionCell.btnCallVideo setEnabled:NO];
            break;
        case OS_BUSY:
            [self.connectionCell.btnCallVoice setEnabled:YES];
            [self.connectionCell.btnCallVideo setEnabled:NO];
            break;
        case OS_CALLME:
            break;
        case OS_ONLINEVIDEO:
            break;
        case OS_IPUSH:
            [self.connectionCell.btnCallVoice setEnabled:YES];
            [self.connectionCell.btnCallVideo setEnabled:NO];
            break;
    }
    
}

-(MOPhoneNumber *) phoneNumberForElement:(MOC2CallUser *)elem atIndexPath:(NSIndexPath *) indexPath
{
    int count = 0;
    
    if (hasFriendNumbers) {
        if (indexPath.section == 2) {
            for (MOPhoneNumber *phone in elem.friendNumbers) {
                if (count == indexPath.row) {
                    return phone;
                }
                count++;
            }
        }
        
        if (indexPath.section == 3) {
            for (MOPhoneNumber *phone in elem.contactNumbers) {
                if (count == indexPath.row) {
                    return phone;
                }
                count++;
            }
        }
    } else {
        if (indexPath.section == 2) {
            for (MOPhoneNumber *phone in elem.contactNumbers) {
                if (count == indexPath.row) {
                    return phone;
                }
                count++;
            }
        }
    }
    
    
    return nil;
}

-(MOPhoneNumber *) phoneNumberForElement:(MOC2CallUser *)elem withHash:(NSInteger) hash
{
    int count = 0;
    
    for (MOPhoneNumber *phone in elem.friendNumbers) {
        if (((NSInteger)[phone hash]) == hash) {
            return phone;
        }
        count++;
    }
    
    for (MOPhoneNumber *phone in elem.contactNumbers) {
        if (((NSInteger)[phone hash]) == hash) {
            return phone;
        }
        count++;
    }
    
    return nil;
}

-(UDPhoneCell *) configurePhoneCell:(MOC2CallUser *) elem forIndexPath:(NSIndexPath *) indexPath
{
    UDPhoneCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SCPhoneCell"];
    
    MOPhoneNumber *currentNumber = [self phoneNumberForElement:elem atIndexPath:indexPath];
    
    if (addNumber || editNumber) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.number.textColor = [UIColor darkTextColor];
    if (currentNumber) {
        NSString *type = currentNumber.numberType;
        if ([type isEqualToString:@"NT_WORK"])
            cell.numberType.text = NSLocalizedString(@"Work", @"Cell Label");
        
        if ([type isEqualToString:@"NT_MOBILE"])
			cell.numberType.text = NSLocalizedString(@"Mobile", @"Cell Label");
        
        if ([type isEqualToString:@"NT_HOME"])
			cell.numberType.text = NSLocalizedString(@"Home", @"Cell Label");
        
        if ([type isEqualToString:@"NT_OTHER"])
			cell.numberType.text = NSLocalizedString(@"Other", @"Cell Label");
        
        if ([currentNumber.allowEdit boolValue]) {
            if (editNumber) {
                if (!self.firstResponderCell) {
                    self.firstResponderCell = cell;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.editNumber becomeFirstResponder];
                    });
                }
                cell.number.hidden = YES;
                cell.editNumber.text = currentNumber.phoneNumber;
                cell.editNumber.hidden = NO;
                cell.editNumber.tag = (NSInteger)[currentNumber hash];
            } else {
                cell.number.textColor = [UIColor colorWithRed:27./255. green:68./255. blue:109./255. alpha:1.0];
                cell.number.text = currentNumber.phoneNumber;
                cell.number.hidden = NO;
                cell.editNumber.hidden = YES;
                cell.editNumber.tag = (NSInteger)[currentNumber hash];
            }
            
            if (addNumber && [currentNumber.phoneNumber isEqualToString:@"+"]) {
                cell.editNumber.text = nil;
                self.firstResponderCell = cell;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.editNumber becomeFirstResponder];
                });
                addNumber = NO;
                cell.number.hidden = YES;
                cell.editNumber.hidden = NO;
                cell.editNumber.tag = (NSInteger)[currentNumber hash];
            }
        } else {
            cell.number.text = currentNumber.phoneNumber;
            cell.number.hidden = NO;
            cell.editNumber.hidden = YES;
            
        }
        cell.smsButton.tag = (NSInteger)[currentNumber hash];
		cell.selected = NO;
        [cell queryPriceForNumber:currentNumber.phoneNumber];
    }
    
    return cell;
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallUser *elem = [self currentUser];
    if ([cell isKindOfClass:[UDUserInfoCell class]]) {
        [self configureUserInfoCell:elem];
    }
    if ([cell isKindOfClass:[UDConnectionCell class]]) {
        [self configureConnectionCell:elem];
    }
    
    if ([cell isKindOfClass:[UDPhoneCell class]]) {
        [self configurePhoneCell:elem forIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallUser *elem = [self currentUser];
    
    DLog(@"cellForRowAtIndexPath : %ld/%ld", (long)indexPath.section, (long)indexPath.row);
    switch (indexPath.section) {
        case 0:
            [self configureUserInfoCell:elem];
            return userInfoCell;
        case 1:
            [self configureConnectionCell:elem];
            return connectionCell;
        case 2:
            return [self configurePhoneCell:elem forIndexPath:indexPath];
        case 3:
            return [self configurePhoneCell:elem forIndexPath:indexPath];
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[UDPhoneCell class]]) {
        UDPhoneCell *cc = (UDPhoneCell *) cell;
        if (!cc.editNumber.hidden) {
            cell.backgroundColor = [UIColor colorWithRed:(254./255.) green:(254./255.) blue:(227. / 255.) alpha:1.0];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    if ([cell isKindOfClass:[UDConnectionCell class]]) {
        cell.backgroundView = nil;
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallUser *elem = [self currentUser];
    
    if (elem) {
        MOPhoneNumber *phone = [self phoneNumberForElement:elem atIndexPath:indexPath];
        return [phone.allowEdit boolValue];
    }
    
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        MOC2CallUser *elem = [self currentUser];
        
        if (elem) {
            MOPhoneNumber *phone = [self phoneNumberForElement:elem atIndexPath:indexPath];
            [[SCDataManager instance] removeDatabaseObject:phone];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });

        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.section == 2 || indexPath.section == 3) {
        if (editNumber || addNumber)
            return;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        MOC2CallUser *user = [self currentUser];
        if (user) {
            MOPhoneNumber *phone = [self phoneNumberForElement:user atIndexPath:indexPath];
            if ([phone.phoneNumber length] > 4) {
                if ([[SCAffiliateInfo instance].affiliateApp.appUse containsObject:@"USE_PSTN"]) {
                    [[C2CallPhone currentPhone] callNumber:phone.phoneNumber];
                } else if ([[SCAffiliateInfo instance].affiliateApp.appUse containsObject:@"USE_SMS"]) {
                    DLog(@"chatController with phoneNumber : %@", phone.phoneNumber);
                    [self showChatForUserid:phone.phoneNumber];
                }
            }
        }
    }
}

#pragma mark FetchResultController

-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized) {
        return nil;
    }
    
    self.useDidChangeContentOnly = YES;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForUserWithObjectId:self.managedObjectId];
    return fetchRequest;
}

-(void) initFetchedResultsController
{
    [super initFetchedResultsController];
    
    MOC2CallUser *user = [self currentUser];
    DLog(@"Found user : %@", user.displayName);
    
    // Visit the UserDetails will reset the missed calls counter
    if ([[SCDataManager instance] missedCallsForContact:user.userid] > 0) {
        [[SCDataManager instance] resetMissedCallsForContact:user.userid];
    }
}

-(MOC2CallUser *) currentUser
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        return nil;
    
    return [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    [self.tableView reloadData];
}

-(void) restoreRightBarButton
{
    [self popRightBarButtonItem];
}

#pragma mark actions

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
            return YES;
    }
    return NO;
    
}

-(IBAction)callVoice:(id)sender;
{
	if (![SIPPhone currentPhone].isOnline) {
		return;
	}
	
    MOC2CallUser *user = [self currentUser];
    
	if (!user.userid) {
		return;
	}
	
    if ([[C2CallPhone currentPhone] isGroupUser:user.userid]) {
        [[SIPPhone currentPhone] callVoIP:user.userid groupCall:YES];
    } else {
        [[SIPPhone currentPhone] callVoIP:user.userid groupCall:NO];
    }
}

-(IBAction)callVideo:(id)sender;
{
	if (![SIPPhone currentPhone].isOnline) {
		return;
	}
	
    MOC2CallUser *user = [self currentUser];
    
	if (!user.userid) {
		return;
	}
    
    if ([[C2CallPhone currentPhone] isGroupUser:user.userid]) {
        [[SIPPhone currentPhone] callVideo:user.userid groupCall:YES];
    } else {
        [[SIPPhone currentPhone] callVideo:user.userid groupCall:NO];
    }
}

-(IBAction)chat:(id)sender;
{
    MOC2CallUser *user = [self currentUser];
    
	if (!user.userid) {
		return;
	}

    
    if (self.navigationController) {
        NSArray *vclist = [self.navigationController viewControllers];
        int idx = (int)([vclist count] - 2);
        if (idx >= 0 && [[vclist objectAtIndex:idx] isKindOfClass:[SCChatController class]]) {
            
            SCChatController *cc = (SCChatController *) [vclist objectAtIndex:idx];
            if ([cc.targetUserid isEqualToString:user.userid]) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
    }

    
    [self showChatForUserid:user.userid];    
}

-(IBAction) smsAction:(id)sender
{
    MOC2CallUser *user = [self currentUser];
	if (!user) {
		return;
	}
    
    MOPhoneNumber *phone = [self phoneNumberForElement:user withHash:[sender tag]];
    if (!phone) {
        return;
    }
    
    DLog(@"chatController with phoneNumber : %@", phone.phoneNumber);
    [self showChatForUserid:phone.phoneNumber];
}


-(IBAction)addPhoneNumber:(id)sender
{
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    BOOL hasHome = NO, hasWork = NO, hasMobile = NO, hasOther = NO;
    editNumber = NO;
    
    MOC2CallUser *user = [self currentUser];
    if (!user)
        return;
    
    for (MOPhoneNumber *phone in user.contactNumbers) {
        if ([phone.numberType isEqualToString:@"NT_HOME"])
            hasHome = YES;
        
        if ([phone.numberType isEqualToString:@"NT_WORK"])
            hasWork = YES;
        
        if ([phone.numberType isEqualToString:@"NT_MOBILE"])
            hasMobile = YES;
        
        if ([phone.numberType isEqualToString:@"NT_OTHER"])
            hasOther = YES;
        
    }
    
    if (!hasHome) {
        [cv addChoiceWithName:NSLocalizedString(@"Home", @"ChoiceTitle") andSubTitle:nil andIcon:nil andCompletion:^{
            addNumber = YES;
            self.firstResponderCell = nil;
            [[SCDataManager instance]setNumber:nil ofType:@"NT_HOME" forContact:user.email];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    if (!hasWork) {
        [cv addChoiceWithName:NSLocalizedString(@"Work", @"ChoiceTitle") andSubTitle:nil andIcon:nil andCompletion:^{
            addNumber = YES;
            self.firstResponderCell = nil;
            [[SCDataManager instance]setNumber:nil ofType:@"NT_WORK" forContact:user.email];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    if (!hasMobile) {
        [cv addChoiceWithName:NSLocalizedString(@"Mobile", @"ChoiceTitle") andSubTitle:nil andIcon:nil andCompletion:^{
            addNumber = YES;
            self.firstResponderCell = nil;
            [[SCDataManager instance]setNumber:nil ofType:@"NT_MOBILE" forContact:user.email];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    if (!hasOther) {
        [cv addChoiceWithName:NSLocalizedString(@"Other", @"ChoiceTitle") andSubTitle:nil andIcon:nil andCompletion:^{
            addNumber = YES;
            self.firstResponderCell = nil;
            [[SCDataManager instance]setNumber:nil ofType:@"NT_OTHER" forContact:user.email];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        addNumber = NO;
    }];
    
    [cv showMenu];
}

-(IBAction)editPhoneNumber:(id)sender
{
    if (editNumber) {
        if ([self.firstResponderCell.editNumber isFirstResponder]) {
            [self.firstResponderCell.editNumber resignFirstResponder];
        }
        self.firstResponderCell = nil;
        [self restoreRightBarButton];
        
        editNumber = NO;
    } else {
        MOC2CallUser *user = [self currentUser];
        if ([user.contactNumbers count] == 0) {
            // Nothing to edit
            return;
        }
        self.firstResponderCell = nil;
        editNumber = YES;
    }
    [self.tableView reloadData];
}

-(void) createGroupWithUser
{
}

#pragma mark UITextFieldDelegate
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    modified = YES;
    return YES;
}

-(BOOL) textFieldShouldClear:(UITextField *)textField
{
    modified = YES;
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(__weak UITextField *)textField
{
    modified = NO;
    
    __weak SCFriendDetailController *weakself = self;
    UIBarButtonItem *item = [[C2BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone andAction:^(id sender) {
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        } else {
            [self updateContactPhone:textField];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself restoreRightBarButton];
            editNumber = NO;
            [weakself.tableView reloadData];
        });
    }];
    [self pushRightBarButtonItem:item];
    
    return YES;
}

-(void) updateContactPhone:(UITextField *)textField
{
    
    NSString *number = textField.text;
    if ([number length] > 3) {
        number = [SIPPhone normalizeNumber:textField.text];
        textField.text = number;
    }
    
    MOC2CallUser *user = [self currentUser];
    if (!user)
        return;
    
    MOPhoneNumber *phone = nil;
    for (MOPhoneNumber *p in user.contactNumbers) {
        if ([p hash] == textField.tag) {
            phone = p;
            break;
        }
    }
    
    if ([number length] == 0) {
        [[SCDataManager instance] removeDatabaseObject:phone];
    } else {
        [[SCDataManager instance] setNumber:number ofType:phone.numberType forContact:user.email];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    addNumber = NO;
    if (modified) {
        [self updateContactPhone:textField];
    } else {
        [self updateContactPhone:textField];
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
