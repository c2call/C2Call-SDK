//
//  SCLaunchScreenController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 15.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import "SCLaunchScreenController.h"
#import "SCRegistrationController.h"
#import "SCLoginController.h"
#import "C2CallAppDelegate.h"

@interface SCLaunchScreenController ()

@end

@implementation SCLaunchScreenController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCRegistrationControllerSegue"]) {
        UIViewController *vc = segue.destinationViewController;
        SCRegistrationController *cd = nil;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            cd = (SCRegistrationController *)((UINavigationController *)vc).topViewController;
        }
        
        if ([vc isKindOfClass:[SCRegistrationController class]]) {
            cd = (SCRegistrationController *)vc;
        }
        
        __weak UIViewController *weakcv = cd;
        [cd setRegisterDoneAction:^{
            [weakcv dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:NO completion:NULL];
            }];
        }];
        return;
    }

    if ([segue.identifier isEqualToString:@"SCLoginControllerSegue"]) {
        UIViewController *vc = segue.destinationViewController;
        SCLoginController *cd = nil;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            cd = (SCLoginController *)((UINavigationController *)vc).topViewController;
        }
        
        if ([vc isKindOfClass:[SCLoginController class]]) {
            cd = (SCLoginController *)vc;
        }
        
        __weak UIViewController *weakcv = cd;
        [cd setLoginDoneAction:^{
            [weakcv dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:NO completion:NULL];
            }];
        }];
        return;
    }

}


-(IBAction)closeViewControllerSegueAction:(UIStoryboardSegue *)segue;
{
    
}

-(IBAction)loginUsingFacebook:(id)sender
{
    [[C2CallAppDelegate appDelegate] startUsingFacebookLogin];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
