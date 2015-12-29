//
//  SCLoginController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 15.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import "SCLoginController.h"
#import "EditCell.h"
#import "SCWaitIndicatorController.h"
#import "C2CallAppDelegate.h"
#import "C2CallPhone.h"
#import "debug.h"

@interface SCLoginController () {
    void (^loginDoneAction)();
    void (^cancelAction)();
    
    SCWaitIndicatorController   *pleaseWait;
}

@end

@implementation SCLoginController
@synthesize email, password, forgotPasswordButton;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[email.textContent becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = (int)indexPath.row;
	int section = (int)indexPath.section;
	switch (section) {
		case 0:
			if (row == 0)
				[email.textContent becomeFirstResponder];
			
			if (row == 1)
				[password.textContent becomeFirstResponder];
			break;
	}
}

#pragma mark Actions

-(void) setLoginDoneAction:(void (^)())_action;
{
    loginDoneAction = _action;
}


-(IBAction) forgotPassword:(id) sender
{
}

-(IBAction) loginUser:(id) sender;
{
    if ([password.textContent isFirstResponder]) {
        [password.textContent resignFirstResponder];
    }
    
    if ([email.textContent isFirstResponder]) {
        [email.textContent resignFirstResponder];
    }
    
	if (!password.textContent.text || [password.textContent.text isEqualToString:@""]) {
		[self showPrompt:NSLocalizedString(@"Error : Password cannot be empty!", @"Prompt")];
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}
    
	if (!email.textContent.text || [email.textContent.text isEqualToString:@""]) {
		[self showPrompt:NSLocalizedString(@"Error : Email cannot be empty!", @"Prompt")];
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}
	
    pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Login to service", @"SCLoginController WaitMessage") andWaitMessage:nil];
    [pleaseWait show:self.view];
    
    [[C2CallPhone currentPhone] loginWithUser:email.textContent.text andPassword:password.textContent.text withCompletionHandler:^(BOOL success, int resultCode, NSString *resultMessage) {
        [pleaseWait hide];
        pleaseWait = nil;
        if (success) {
            if (loginDoneAction) {
                loginDoneAction();
            }
        } else {
            [self showPrompt:NSLocalizedString(@"Login failed, invalid user name or password!", @"Prompt")];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
        }
    }];
    
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"UserLogin" object:self userInfo:nil];
    [[C2CallAppDelegate appDelegate] logEvent:@"UserLogin"];
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	DLog(@"textFieldShouldReturn");
	
	switch(theTextField.tag) {
		case 0:
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			[password.textContent becomeFirstResponder];
			break;
		case 1:
			[self loginUser:nil];
			break;
	}
	
	return YES;
}


#pragma mark Miscellanous

-(void) showPrompt:(NSString *) text
{
    self.navigationItem.prompt = text;
}

-(void) resetPrompt
{
    [self resetPrompt:nil];
}

-(void) resetPrompt:(NSTimer *) t
{
    self.navigationItem.prompt = nil;
}

@end
