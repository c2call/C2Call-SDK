//
//  SCRegistrationController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 14.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import <AddressBook/AddressBook.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SCRegistrationController.h"
#import "SCWaitIndicatorController.h"
#import "SCCountrySelectionController.h"
#import "C2CallAppDelegate.h"
#import "EditCell.h"
#import "C2CallConstants.h"
#import "SCPopupMenu.h"
#import "C2TapImageView.h"
#import "SCAssetManager.h"

#import "debug.h"

@interface SCRegistrationController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

    void (^registerDoneAction)();
}

@end

@implementation SCRegistrationController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.email.textContent becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableView Delegate
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *editCell = (EditCell *) cell;
        [editCell.textContent becomeFirstResponder];
    }
}

#pragma mark Prompt
-(void) showPrompt:(NSString *) text
{
    self.navigationItem.prompt = text;
}

-(void) resetPrompt:(NSTimer *) t
{
	registrationInProgress = NO;
    self.navigationItem.prompt = nil;
}

-(void) resetPromptAndClose:(NSTimer *) t
{
	registrationInProgress = NO;
    self.navigationItem.prompt = nil;
}

#pragma mark Handle Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCCountrySelectionControllerSegue"]) {
        UIViewController *vc = segue.destinationViewController;
        SCCountrySelectionController *cd = nil;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            cd = (SCCountrySelectionController *)((UINavigationController *)vc).topViewController;
        }
        
        if ([vc isKindOfClass:[SCCountrySelectionController class]]) {
            cd = (SCCountrySelectionController *)vc;
        }

        cd.delegate = self;
        
        return;
    }
    
}

#pragma mark Actions
-(void) setRegisterDoneAction:(void (^)())_action;
{
    registerDoneAction = _action;
}

-(IBAction)setFirstResponder:(id)sender
{
    if ([sender isKindOfClass:[EditCell class]]) {
        EditCell *cell = (EditCell *) sender;
        [cell.textContent becomeFirstResponder];
    }
}

-(IBAction) registerUser:(id) sender;
{
	if (registrationInProgress)
		return;
    
    if ([self.firstName isFirstResponder])
        [self.firstName resignFirstResponder];
    
    if ([self.lastName isFirstResponder])
        [self.lastName resignFirstResponder];
    
    if ([self.phoneNumber.textContent isFirstResponder])
        [self.phoneNumber.textContent resignFirstResponder];
    
    if ([self.email.textContent isFirstResponder])
        [self.email.textContent resignFirstResponder];
    
    if ([self.password1.textContent isFirstResponder])
        [self.password1.textContent resignFirstResponder];
    
    if ([self.password2.textContent isFirstResponder])
        [self.password2.textContent resignFirstResponder];
    
    
	if (![self.password1.textContent.text isEqualToString:self.password2.textContent.text]) {
		[self showPrompt:NSLocalizedString(@"Error : Passwords are not the same!", @"Prompt")];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetPrompt:nil];
        });
		return;
	}
	
	if (!self.firstName.text || [self.firstName.text isEqualToString:@""]) {
		[self showPrompt:NSLocalizedString(@"First Name is mandatory field!", @"Prompt")];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}
    
	if (!self.lastName.text || [self.lastName.text isEqualToString:@""]) {
		[self showPrompt:NSLocalizedString(@"Last Name is mandatory field!", @"Prompt")];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}
	
	if (!self.email.textContent.text || [self.email.textContent.text isEqualToString:@""]) {
		[self showPrompt:NSLocalizedString(@"Email is mandatory field!", @"Prompt")];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}
    
    if (!countryCode || [countryCode isEqualToString:@""]) {
		[self showPrompt:NSLocalizedString(@"Country is mandatory field!", @"Prompt")];
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}
    
	if ([self.password1.textContent.text length] < 6) {
		[self showPrompt:NSLocalizedString(@"The password should have at least 6 characters!", @"Prompt")];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        
		[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetPrompt:) userInfo:nil repeats:NO];
		return;
	}

	[self performUserRegistration];
}

-(IBAction) showTerms:(id) sender;
{
}

-(IBAction)selectPhoto:(id)sender
{
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [cv addChoiceWithName:NSLocalizedString(@"Choose Photo", @"Choice Title") andSubTitle:NSLocalizedString(@"Select from Camera Roll", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_image"] andCompletion:^{
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [cv addChoiceWithName:NSLocalizedString(@"Take Photo", @"Choice Title") andSubTitle:NSLocalizedString(@"Use Camera", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_cam-24x24"] andCompletion:^{
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1);
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }];
    }
    
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
    
}

#pragma mark Table view methods

- (NSIndexPath *) nextIndexPath:(NSIndexPath *) indexPath
{
    int numOfSections = (int)[self numberOfSectionsInTableView:self.tableView];
    int nextSection = ((indexPath.section + 1) % numOfSections);
    
    if ((indexPath.row +1) == [self tableView:self.tableView numberOfRowsInSection:indexPath.section]) {
        return [NSIndexPath indexPathForRow:0 inSection:nextSection];
    } else {
        return [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	DLog(@"textFieldShouldReturn");
	return YES;
}


#pragma mark Miscellanous

-(void) scrollToIndexPath:(NSIndexPath *) indexPath
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
}


- (UIView *)findFirstResponder:(UIView *) startView
{
    if (startView.isFirstResponder) {
        return startView;
    }
    
    for (UIView *subView in startView.subviews) {
        UIView *firstResponder = [self findFirstResponder:subView];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}

-(void) selectCountry:(NSString *)name withCode:(NSString *)code
{
    countryName = name;
    countryCode = [NSString stringWithFormat:@"+%@", code];
    UIImage *img = [[SCAssetManager instance] imageForName:[NSString stringWithFormat:@"flag%@", code]];
	if (img)
		self.country.imageView.image = img;
    
    self.country.textLabel.text = name;
    self.country.detailTextLabel.text = [NSString stringWithFormat:@"(+%@)", code];
    [C2CallPhone setDefaultCountryCode:code];
}


-(void) handleRegisterResult:(int)status comment:(NSString *)statusText
{
    if (status == 14) {
        [self showPrompt:NSLocalizedString(@"Error, the user is already existing!", @"Prompt")];
    } else {
        [self showPrompt :statusText];
    }
    
    if (status == 0) {
        // Registration successful
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_REGISTERSTATUS];
        [self resetPrompt:nil];
        if (registerDoneAction) {
            registerDoneAction();
        }
    } else  {
        // Something went wrong
        NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:DEFAULT_EMAIL];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULT_REGISTERSTATUS];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetPrompt:nil];
        });
    }
    
}
@end
