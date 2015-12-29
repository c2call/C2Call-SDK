//
//  SCGroupDetailController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import "SCGroupDetailController.h"

#import "SCWaitIndicatorController.h"
#import "C2TapImageView.h"
#import "ImageUtil.h"
#import "DateUtil.h"
#import "SCGroupDetailHeaderController.h"
#import "SCUserSelectionController.h"
#import "SCGroupMemberCell.h"
#import "C2CallAppDelegate.h"
#import "C2CallConstants.h"
#import "SCGroup.h"
#import "SCUserProfile.h"
#import "SCDataManager.h"
#import "SCAssetManager.h"

#import "debug.h"

@interface SCGroupDetailController () {
    NSArray				*numberList;
    
    NSMutableSet    *encryptionStatus, *invitedUsers;
    BOOL preparingEncryption, encryptedGroup;
}

@property(nonatomic, strong) NSArray                            *members;
@property(nonatomic, weak) SCGroupDetailHeaderController        *headerController;
@property(nonatomic, strong) SCGroup                            *group;
@property(nonatomic, strong) NSString                           *groupName;

@end

@implementation SCGroupDetailController
@synthesize headerView, groupid, headerController, members, group;

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

    invitedUsers = [NSMutableSet set];
    encryptionStatus = [[NSMutableSet alloc] initWithCapacity:20];

    self.group =  [[SCGroup alloc] initWithGroupid:groupid];
    
    encryptedGroup = [[C2CallPhone currentPhone] encryptedGroup:groupid];
    headerController.toggleEncryptionButton.selected = encryptedGroup;
    headerController.toggleEncryptionButton.enabled = NO;

    encryptionStatus = [NSMutableSet setWithSet:[[C2CallPhone currentPhone] encryptionEnabledGroupMembersForGroup:groupid]];

    if ([group.groupOwner isEqualToString:[SCUserProfile currentUser].userid]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit Group", @"Button") style:UIBarButtonItemStylePlain target:self action:@selector(editGroup:)];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        headerController.toggleEncryptionButton.enabled = YES;
        
        if (![[C2CallPhone currentPhone] encryptionEnabled]) {
            headerController.toggleEncryptionButton.hidden = YES;
        }

    } else {
        if (!encryptedGroup) {
            headerController.toggleEncryptionButton.hidden = YES;
        } else {
            headerController.toggleEncryptionButton.selected = NO; // hack to display icon
        }

    }
    
    [self.headerController.toggleEncryptionButton addTarget:self action:@selector(toggleEncryption:) forControlEvents:UIControlEventTouchUpInside];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"SIPHandler:PresenceEvent" object:nil];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"GroupCallUserLeft" object:nil];
	[nc addObserver:self selector:@selector(handleNotification:) name:@"GroupCallUserJoined" object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [headerController viewWillAppear:animated];
    
    self.members = [group groupMembers];
    
    if ([group.groupOwner isEqualToString:[SCUserProfile currentUser].userid] && encryptedGroup) {
        NSString *gid = group.groupid;
        
        [[C2CallPhone currentPhone] refreshKeysForGroup:gid withCompletionHandler:^(BOOL didUpdate, NSSet *encryptedMembers) {
            if (didUpdate) {
                encryptionStatus = [NSMutableSet setWithSet:encryptedMembers];
                [self.tableView reloadData];
            }
        }];

    }

    
    [self.tableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Notifications

-(void) handleNotification:(NSNotification *) n
{
    @try {
        if ([[n name] isEqualToString:@"SIPHandler:PresenceEvent"]) {
            [headerController refreshGroupStatus];
            [self.tableView reloadData];
        }
        
        if ([[n name] isEqualToString:@"GroupCallUserLeft"]) {
            [headerController refreshGroupStatus];
            [self.tableView reloadData];
        }
        
        if ([[n name] isEqualToString:@"GroupCallUserJoined"]) {
            [headerController refreshGroupStatus];
            [self.tableView reloadData];
        }
        
    }
    @catch (NSException *exception) {
        
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [members count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)s
{
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Down't edit if it's not the owner
    if (![group.groupOwner isEqualToString:[SCUserProfile currentUser].userid]) {
        return NO;
    }
    
    if (indexPath.row >= [members count])
        return NO;
    
    NSString *userid = [members objectAtIndex:indexPath.row];
    
    if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
        return NO;
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *member = [members objectAtIndex:indexPath.row];
        [group removeMember:member];
        self.members = [group groupMembers];
        [group saveGroupWithCompletionHandler:^(BOOL success) {
            [tableView reloadData];
        }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userid = [members objectAtIndex:indexPath.row];
    NSString *gid = group.groupid;
    
    MOC2CallUser *groupuser = [[SCDataManager instance] userForUserid:gid];
    
    int grouponline = [groupuser.onlineStatus intValue];
    
    if (grouponline == OS_CALLME) {
        NSArray *active = [[C2CallPhone currentPhone] activeMembersInCallForGroup:gid];
        if ([active containsObject:userid]) {
            cell.backgroundColor = [UIColor colorWithRed:(254./255.) green:(254./255.) blue:(227. / 255.) alpha:1.0];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SCGroupMemberCell";
    
    SCGroupMemberCell *cell = (SCGroupMemberCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.inviteButton setHidden:YES];
    
    NSString *userid = [members objectAtIndex:indexPath.row];
    NSString *gid = group.groupid;
    
    MOC2CallUser *groupuser = [[SCDataManager instance] userForUserid:gid];
    int grouponline = [groupuser.onlineStatus intValue];
    int online = 0;
    
    BOOL itsMe = NO;
    
    NSString *displayName = nil;
    if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
        itsMe = YES;
        displayName = [SCUserProfile currentUser].displayname;
    } else {
        MOC2CallUser *member = [[SCDataManager instance] userForUserid:userid];
        displayName = [member.displayName copy];
        if (!member) {
            NSString *user = [members objectAtIndex:indexPath.row];
            
            NSString *lastname = [group nameForGroupMember:user];
            NSString *firstname = [group firstnameForGroupMember:user];
            NSString *email = [group emailForGroupMember:user];

            if ([lastname length] > 0 && [firstname length] > 0) {
                displayName = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
            } else if (firstname) {
                displayName = firstname;
            } else if (lastname) {
                displayName = lastname;
            } else {
                displayName = email;
            }
            
            if (![invitedUsers containsObject:user]) {
                [cell.inviteButton setHidden:NO];
                cell.inviteButton.tag = indexPath.row;
            }
        } else {
            online = [[member onlineStatus] intValue];
        }
    }
    
    if ([group.groupOwner isEqualToString:userid]) {
        cell.textLabel.textColor = DEFAULT_BLUECOLOR;
    } else {
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
    
    cell.textLabel.text = displayName;
    
    if (itsMe)
        online = OS_ONLINE;
    
    if (grouponline == OS_CALLME) {
        NSArray *active = [[C2CallPhone currentPhone] activeMembersInCallForGroup:gid];
        if ([active containsObject:userid]) {
            online = OS_GROUPCALL;
        }
    }
    
    if (online > 0) {
        cell.detailTextLabel.textColor = DEFAULT_GREENCOLOR;
        switch (online) {
			case OS_ONLINE:
				cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                cell.detailTextLabel.textColor = DEFAULT_IDLECOLOR;
				break;
			case OS_FORWARDED:
				cell.detailTextLabel.text = NSLocalizedString(@"Call forward", @"Cell Label");
                cell.detailTextLabel.textColor = DEFAULT_IDLECOLOR;
				break;
			case OS_INVISIBLE:
				cell.detailTextLabel.text = NSLocalizedString(@"offline", @"Cell Label");
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				break;
			case OS_AWAY:
				cell.detailTextLabel.text = NSLocalizedString(@"offline (away)", @"Cell Label");
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				break;
			case OS_BUSY:
				cell.detailTextLabel.text = NSLocalizedString(@"offline (busy)", @"Cell Label");
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				break;
			case OS_CALLME:
				cell.detailTextLabel.text = NSLocalizedString(@"online (call me)", @"Cell Label");
                cell.detailTextLabel.textColor = DEFAULT_IDLECOLOR;
				break;
			case OS_ONLINEVIDEO:
				cell.detailTextLabel.text = NSLocalizedString(@"online (active)", @"Cell Label");
				break;
			case OS_IPUSH:
				cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                cell.detailTextLabel.textColor = DEFAULT_IDLECOLOR;
				break;
			case OS_IPUSHCALL:
				cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                cell.detailTextLabel.textColor = DEFAULT_IDLECOLOR;
				break;
			case OS_GROUPCALL:
				cell.detailTextLabel.text = NSLocalizedString(@"in conference", @"Cell Label");
				break;
		}
        
    } else {
        cell.detailTextLabel.text = NSLocalizedString(@"offline", @"Cell Label");
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    //cell.detailTextLabel.text = [[member elementForName:@"EMail"] stringValue];
    
    UIImage *userpic = [[C2CallPhone currentPhone] userimageForUserid:userid];
	if (userpic) {
		cell.imageView.image = userpic;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
	} else {
        NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
        cell.imageView.image = [UIImage imageNamed:@"btn_ico_avatar" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
    }
    
    // Show the encryption status per member
    if (encryptedGroup) {
        cell.encryptionStatus.highlighted = [encryptionStatus containsObject:userid];
        cell.encryptionStatus.hidden = NO;
    } else {
        cell.encryptionStatus.hidden = YES;
    }

    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

#pragma mark Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCGroupDetailHeaderControllerSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[SCGroupDetailHeaderController class]]) {
            self.headerController = (SCGroupDetailHeaderController *) segue.destinationViewController;
            if (!self.group) {
                self.group = [[SCGroup alloc] initWithGroupid:groupid];
            }
            self.headerController.group = self.group;
        }
    }
}

#pragma mark Actions

-(void) updateGroup:(NSArray *) newmembers
{
    // Remove old members
    NSArray *oldmembers = [group groupMembers];
    for (NSString *m in oldmembers) {
        if ([m isEqualToString:[SCUserProfile currentUser].userid])
            continue;
        [group removeMember:m];
    }
    
    
    // Add new members
    for (NSString *user in newmembers) {
        [group addGroupMember:user];
    }
    
    [group saveGroupWithCompletionHandler:^(BOOL success) {
        members = [group groupMembers];
        [self.tableView reloadData];
    }];
}

-(IBAction) editGroup:(id)sender;
{
    SCUserSelectionController *vc = nil;
    vc =  [[C2CallAppDelegate appDelegate] instantiateViewControllerWithIdentifier:@"SCUserSelectionController"];
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:[members count]+1];
    for (NSString *m in members) {
        if ([m isEqualToString:[SCUserProfile currentUser].userid])
            continue;
        
        [users addObject:m];
    }
    
    vc.selectedUserList = users;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [vc setCancelAction:^{
        [nc dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    [vc setResultAction:^(NSArray *result) {
        [nc dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                [self updateGroup:result];
            });
        }];
    }];
    
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:^{
        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:vc action:@selector(cancel:)];
        vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:vc action:@selector(confirmSelection:)];
    }];
    
}

-(IBAction) inviteContact:(id)sender;
{
    int row = (int)[sender tag];
    if (row < [members count]) {
        NSString *member = [members objectAtIndex:row];
        NSString *email = [group emailForGroupMember:member];
        [[C2CallPhone currentPhone] findFriend:email];
        [sender setHidden:YES];
        [invitedUsers addObject:member];
    }
}

-(void) submitEncrytionMessageToMembersNonEncryptedMembers
{
    NSMutableSet *userlist = [NSMutableSet setWithCapacity:[members count]];
    
    for (NSString *m in members) {
        [userlist addObject:m];
    }
    
    for (NSString *encrytedUser in encryptionStatus) {
        [userlist removeObject:encrytedUser];
    }
    
    NSString *message = NSLocalizedString(@"The group %@ has been encrypted for secure group messaging. Please enable encryption for your account in order to read secure group messages. An update to the latest App version might be necessary for secure messaging", @"Encrytion Info Message");
    
    message = [NSString stringWithFormat:message, group.groupName];
    for (NSString *userid in userlist) {
        [[C2CallPhone currentPhone] submitMessage:message toUser:userid];
    }
}


-(IBAction) toggleEncryption:(id) sender
{
    if (preparingEncryption)
        return;
    
    NSString *gid = group.groupid;
    NSString *publicKey = [group groupdataForKey:@"C2_PUBLIC_KEY"];
    if (!publicKey) {
        preparingEncryption = YES;
        DLog(@"Creating KeyPair for Group : %@", gid);
        
        [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Generating Group Certificate", @"Wait Message") andWaitMessage:nil];
        
        BOOL res = [[C2CallPhone currentPhone] enableEncryptionForGroup:gid withCompletionHandler:^(BOOL success, NSSet *encryptedMembers) {
            if (encryptedMembers) {
                encryptionStatus = [NSMutableSet setWithSet:encryptedMembers];
            }
            
            encryptedGroup = success;
            [self.tableView reloadData];
            [[C2CallAppDelegate appDelegate] waitIndicatorStop];
            [sender setSelected:YES];
            
            [self submitEncrytionMessageToMembersNonEncryptedMembers];
            
            SCGroup *newgroup = [[SCGroup alloc] initWithGroupid:group.groupid];
            self.group = newgroup;
            preparingEncryption = NO;
        }];
        
        if (!res) {
            [[C2CallAppDelegate appDelegate] waitIndicatorStop];
            preparingEncryption = NO;
        }
    } else {
        DLog(@"Remove KeyPair for Group : %@", gid);
        preparingEncryption = YES;
        
        [[C2CallPhone currentPhone] disableEncryptionForGroup:gid withCompletionHandler:^(BOOL success) {
            [encryptionStatus removeAllObjects];
            
            encryptedGroup = NO;
            [sender setSelected:NO];
            [self.tableView reloadData];
            preparingEncryption = NO;
        }];
    }
}


@end
