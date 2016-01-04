//
//  VCFriendListController.m
//  SDK-VideoChat Sample
//
//  Created by Michael Knecht on 20.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "VCFriendListController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>

@interface VCFriendListController ()

@end

@implementation VCFriendListController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)mainMenu:(id)sender
{
    SCPopupMenu *popupMenu = [SCPopupMenu popupMenu:self];
    [popupMenu addChoiceWithName:@"Add Friend" andSubTitle:@"Find a friend" andIcon:nil andCompletion:^{
        [self performSegueWithIdentifier:@"SCFindFriendControllerSegue" sender:nil];
    }];
    [popupMenu addChoiceWithName:@"Add Group" andSubTitle:@"Create a new group" andIcon:nil andCompletion:^{
        [self performSegueWithIdentifier:@"SCAddGroupControllerSegue" sender:nil];
    }];

    [popupMenu addCancelWithName:@"Cancel" andCompletion:^{
       
    }];
    
    [popupMenu showMenu];
}

// In case of creating a group, we want to see the group details, once the group creation is done
// So, we have to do some actions on the SCAddGroupControllerSegue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"SCAddGroupControllerSegue"]) {
        UIViewController *vc = segue.destinationViewController;
        SCAddGroupController *controller = nil;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *) vc;
            vc = nav.topViewController;
        }
        
        if ([vc isKindOfClass:[SCAddGroupController class]]) {
            controller = (SCAddGroupController *)vc;
        }
        
        // We want to show the group details after creating the group
        [controller setAddGroupAction:^(NSString *groupid) {
            // Remove Add Group Controller
            [self.navigationController popViewControllerAnimated:NO];
            
            // Show Group Details
            NSLog(@"Show Group for Groupid : %@", groupid);
            [self showGroupDetailForGroupid:groupid];
        }];
    }
}
@end
