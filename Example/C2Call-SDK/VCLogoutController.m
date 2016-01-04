//
//  VCLogoutController.m
//  SDK-VideoChat Sample
//
//  Created by Michael Knecht on 20.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//
#import <SocialCommunication/SocialCommunication.h>
#import "VCLogoutController.h"

@interface VCLogoutController ()

@end

@implementation VCLogoutController

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

-(IBAction)logout:(id)sender
{
    [[C2CallAppDelegate appDelegate] logoutUser];
    self.tabBarController.selectedIndex = 0;
}

@end
