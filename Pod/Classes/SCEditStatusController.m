//
//  SCEditStatusController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 27.11.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import "SCEditStatusController.h"
#import "SCUserProfile.h"

@interface SCEditStatusController ()

@end

@implementation SCEditStatusController
@synthesize statusTextView, saveStatusAsTemplate;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"";
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.statusTextView.text = [SCUserProfile currentUser].userStatus;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.statusTextView becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.statusTextView isFirstResponder]) {
        [self.statusTextView resignFirstResponder];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    NSString *newtext = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([newtext length] > 120)
        return NO;

    return YES;
}

-(IBAction)close:(id)sender
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc)
        [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)save:(id)sender
{
    [SCUserProfile currentUser].userStatus = statusTextView.text;
    
    self.navigationItem.prompt = NSLocalizedString(@"Updating Status...", @"Prompt");
    
    if (saveStatusAsTemplate && [statusTextView.text length] > 0) {
        NSArray *list = [SCUserProfile defaultUserStatusTemplates];
        if (![list containsObject:statusTextView.text]) {
            NSMutableArray *mutableList = [list mutableCopy];
            [mutableList addObject:statusTextView.text];
            [SCUserProfile setUserStatusTemplates:mutableList];
        }
    }
    
    [[SCUserProfile currentUser] saveUserProfileWithCompletionHandler:^(BOOL success) {
        self.navigationItem.prompt = nil;
        [self close:nil];
    }];
}

@end
