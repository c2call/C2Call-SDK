//
//  SCViewController.m
//  C2Call-SDK
//
//  Created by Michael Knecht on 11/22/2015.
//  Copyright (c) 2015 Michael Knecht. All rights reserved.
//

#import "SCViewController.h"
#import <SocialCommunication/SocialCommunication.h>

@interface SCViewController ()

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)testcall:(id)sender
{
    [[C2CallPhone currentPhone] callVoIP:@"9bc2858f1194dc1c107"];
}

@end
