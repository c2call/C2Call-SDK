//
//  SCUserProfileController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 11.05.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+SCCustomViewController.h"
#import "SCUserProfileController.h"
#import "SCUserProfile.h"
#import "SCPopupMenu.h"
#import "SCWaitIndicatorController.h"
#import "SCBrowserViewController.h"
#import "SIPPhone.h"
#import "ImageUtil.h"
#import "SCAssetManager.h"

#import "debug.h"

@interface SCUserProfileController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL    refreshOnAppear;
}

@end

@implementation SCUserProfileController
@synthesize firstname, lastname, email, didnumber, callerid, phoneWork, phoneOther, phoneMobile, phoneHome;
@synthesize userImageButton, credit;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationEvent:) name:@"DataUpdateEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationEvent:) name:[NSString stringWithFormat:@"userimage://%@.jpg", [SCUserProfile currentUser].userid] object:nil];

    [self refreshUserProfile];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[SCUserProfile currentUser] refreshUserCredits];
    
    if (refreshOnAppear) {
        [[SCUserProfile currentUser] refreshUserProfile];
        refreshOnAppear = NO;
    }
}

-(void) refreshUserProfile
{
    self.firstname.text = [SCUserProfile currentUser].firstname;
    self.lastname.text = [SCUserProfile currentUser].lastname;
    if ([[SCUserProfile currentUser].credit length] > 0) {
        self.credit.text = [SCUserProfile currentUser].credit;
    }
    
    self.email.text = [SCUserProfile currentUser].email;
    
    NSString *did = [SCUserProfile currentUser].didnumber;
    if ([did length] > 0) {
        self.didnumber.text = did;
    }
    self.callerid.text = [SCUserProfile currentUser].callerid;
    
    if ([[SCUserProfile currentUser].phoneHome length] == 0 || [[SCUserProfile currentUser].phoneHome isEqualToString:@"null"]) {
        self.phoneHome.text = @"";
    } else {
        self.phoneHome.text = [SCUserProfile currentUser].phoneHome;
    }

    if ([[SCUserProfile currentUser].phoneMobile length] == 0 || [[SCUserProfile currentUser].phoneMobile isEqualToString:@"null"]) {
        self.phoneMobile.text = @"";
    } else {
        self.phoneMobile.text = [SCUserProfile currentUser].phoneMobile;
    }

    if ([[SCUserProfile currentUser].phoneOther length] == 0 || [[SCUserProfile currentUser].phoneOther isEqualToString:@"null"]) {
        self.phoneOther.text = @"";
    } else {
        self.phoneOther.text = [SCUserProfile currentUser].phoneOther;
    }

    if ([[SCUserProfile currentUser].phoneWork length] == 0 || [[SCUserProfile currentUser].phoneWork isEqualToString:@"null"]) {
        self.phoneWork.text = @"";
    } else {
        self.phoneWork.text = [SCUserProfile currentUser].phoneWork;
    }

    
    UIImage *userImage = [SCUserProfile currentUser].userImage;
    if (userImage) {
        [self.userImageButton setImage:userImage forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:@"SCPhoneCellWork"]) {
        [self.phoneWork becomeFirstResponder];
    }
    if ([cell.reuseIdentifier isEqualToString:@"SCPhoneCellHome"]) {
        [self.phoneHome becomeFirstResponder];
    }
    if ([cell.reuseIdentifier isEqualToString:@"SCPhoneCellMobile"]) {
        [self.phoneMobile becomeFirstResponder];
    }
    if ([cell.reuseIdentifier isEqualToString:@"SCPhoneCellOther"]) {
        [self.phoneOther becomeFirstResponder];
    }
}

#pragma mark Notifications

-(void) handleNotificationEvent:(NSNotification *) notification
{
	@try {
        DLog(@"handleNotificationEvent : %@", [notification name]);
        
        if ([[notification name] isEqualToString:@"DataUpdateEvent"] && [[notification userInfo] objectForKey:@"User"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshUserProfile];
            });
        }
        
        if ([[notification name] isEqualToString:@"DataUpdateEvent"] && [[notification userInfo] objectForKey:@"UserCredits"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshUserProfile];
            });
        }

        
        if ([[notification name] isEqualToString:[NSString stringWithFormat:@"userimage://%@.jpg", [SCUserProfile currentUser].userid]]) {
            NSNumber *finished = [[notification userInfo] objectForKey:@"finished"];
            if (finished) {
                
                UIImage *userImage = [SCUserProfile currentUser].userImage;
                if (userImage) {
                    [self.userImageButton setImage:userImage forState:UIControlStateNormal];
                }
            }
        }
        
	}
	@catch (NSException * e) {
		DLog(@"SCUserProfileController : %@", e);
	}
	
}

#pragma mark Segue Handling

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCBrowserViewControllerSegue"]) {
        UIViewController *vc = segue.destinationViewController;
        SCBrowserViewController *cd = nil;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            cd = (SCBrowserViewController *)((UINavigationController *)vc).topViewController;
        }
        
        if ([vc isKindOfClass:[SCBrowserViewController class]]) {
            cd = (SCBrowserViewController *)vc;
        }
        
        NSDictionary *dict = nil;
        if ([sender isKindOfClass:[NSDictionary class]]) {
            dict = sender;
        }
        
        cd.requestUrl = [[C2CallPhone currentPhone] urlForC2CallNumber];;
        refreshOnAppear = YES;
        return;
    }
    
}


#pragma mark Actions

-(IBAction)textFieldDidEndEditing:(id)sender
{
    if ([sender isFirstResponder]) {
        [sender resignFirstResponder];
    }
    
    if ([sender isEqual:self.firstname]) {
        [SCUserProfile currentUser].firstname = [sender text];
    }
    if ([sender isEqual:self.lastname]) {
        [SCUserProfile currentUser].lastname = [sender text];
    }
    if ([sender isEqual:self.phoneHome]) {
        NSString *number = [sender text];
        if ([number length] == 0) {
            [SCUserProfile currentUser].phoneHome = nil;
        } else {
            number = [SIPPhone normalizeNumber:number];
            [SCUserProfile currentUser].phoneHome = number;
            [sender setText:number];
        }
    }
    if ([sender isEqual:self.phoneMobile]) {
        NSString *number = [sender text];
        if ([number length] == 0) {
            [SCUserProfile currentUser].phoneMobile = nil;
        } else {
            number = [SIPPhone normalizeNumber:number];
            [SCUserProfile currentUser].phoneMobile = number;
            [sender setText:number];
        }
    }
    if ([sender isEqual:self.phoneOther]) {
        NSString *number = [sender text];
        if ([number length] == 0) {
            [SCUserProfile currentUser].phoneOther = nil;
        } else {
            number = [SIPPhone normalizeNumber:number];
            [SCUserProfile currentUser].phoneOther = number;
            [sender setText:number];
        }
    }
    if ([sender isEqual:self.phoneWork]) {
        NSString *number = [sender text];
        if ([number length] == 0) {
            [SCUserProfile currentUser].phoneWork = nil;
        } else {
            number = [SIPPhone normalizeNumber:number];
            [SCUserProfile currentUser].phoneWork = number;
            [sender setText:number];
        }
    }
}

-(IBAction)saveUserProfile:(id)sender
{
    UIView *firstResponder = [self findFirstResponder:self.view];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        [self textFieldDidEndEditing:firstResponder];
    }
    
    [[SCUserProfile currentUser] saveUserProfile];
}

#pragma mark Photo Selection

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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Get the selected image.
    
    SCWaitIndicatorController *pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Exporting Image...", @"Title") andWaitMessage:nil];
    [pleaseWait show:[[UIApplication sharedApplication] keyWindow]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
            
            int quality = picker.videoQuality;
            UIImage *image = [ImageUtil fixImage:originalImage withQuality:quality];
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUpMirrored];
            }
            
            
            image = [ImageUtil thumbnailFromImage:image withSize:320.];
            
            [self.userImageButton setImage:image forState:UIControlStateNormal];
            [[SCUserProfile currentUser] setUserImage:image withCompletionHandler:^(BOOL finished) {
                [pleaseWait hide];
            }];
        }
    });
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
