//
//  SCGroupDetailHeaderController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 04.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "SCGroupDetailHeaderController.h"
#import "UIViewController+SCCustomViewController.h"
#import "SCChatController.h"
#import "SCWaitIndicatorController.h"
#import "C2TapImageView.h"
#import "ImageUtil.h"
#import "DateUtil.h"
#import "SCGroup.h"
#import "SCUserProfile.h"
#import "C2CallPhone.h"
#import "SCDataManager.h"
#import "SCAssetManager.h"


#import "debug.h"

@interface SCGroupDetailHeaderController ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>


@end

@implementation SCGroupDetailHeaderController
@synthesize groupName, groupOwner, groupStatus, tfGroupName, editGroupName, imageButton;
@synthesize group;

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
    
    UIImage *userImage = [[C2CallPhone currentPhone] userimageForUserid:group.groupid];
    if (userImage) {
        self.imageButton.image = userImage;
    }
    
    if ([group.groupOwner isEqualToString:[SCUserProfile currentUser].userid]) {
        
        __weak SCGroupDetailHeaderController *blockself = self;
        [self.imageButton setTapAction:^{
            [blockself selectPhoto:self.imageButton];
        }];
    } else {
        if (!userImage) {
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            self.imageButton.image = [UIImage imageNamed:@"btn_ico_avatar_group" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        }
    }
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DLog(@"SCGroupDetailHeaderController:viewWillAppear");
    
    groupName.text = group.groupName;
    groupOwner.text = nil;

    DLog(@"SCGroupDetailHeaderController: Group : %@", groupName.text);

    
    if (![group.groupOwner isEqualToString:[SCUserProfile currentUser].userid]) {
        [editGroupName setHidden:YES];
    }
    
    [self refreshGroupStatus];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) refreshGroupStatus
{
    NSString *groupid = group.groupid;
    
    MOC2CallUser *groupuser = [[SCDataManager instance] userForUserid:groupid];
    int grouponline = [[groupuser onlineStatus] intValue];
    
    if (grouponline == OS_CALLME) {
        NSArray *active = [[C2CallPhone currentPhone] activeMembersInCallForGroup:groupid];
        BOOL video = [[C2CallPhone currentPhone] activeVideoCallForGroup:groupid];
        
        int count = (int)[active count];
        if (count > 0) {
            if (count == 1) {
                if (video) {
                    self.groupStatus.text = [NSString stringWithFormat:NSLocalizedString(@"video conference (%d user)", @"GroupStatus Einzahl"), count];
                } else {
                    self.groupStatus.text = [NSString stringWithFormat:NSLocalizedString(@"active conference (%d user)", @"GroupStatus Einzahl"), count];
                }
            } else {
                if (video) {
                    self.groupStatus.text = [NSString stringWithFormat:NSLocalizedString(@"video conference (%d user)", @"GroupStatus Mehrzahl"), count];
                } else {
                    self.groupStatus.text = [NSString stringWithFormat:NSLocalizedString(@"active conference (%d user)", @"GroupStatus Mehrzahl"), count];
                }
            }
        } else {
            if (video) {
                self.groupStatus.text = NSLocalizedString(@"video conference", @"GroupStatus");
            } else {
                self.groupStatus.text = NSLocalizedString(@"active conference", @"GroupStatus");
            }
        }
    } else {
        self.groupStatus.text = nil;
    }
}

#pragma mark Actions
-(IBAction) call:(id)sender;
{
    if (group.groupid) {
        [[C2CallPhone currentPhone] callVoIP:group.groupid];
    }
}

-(IBAction) callVideo:(id)sender;
{
    if (group.groupid) {
        [[C2CallPhone currentPhone] callVideo:group.groupid groupCall:YES];
    }
}

-(IBAction) message:(id)sender;
{
    if (self.navigationController) {
        NSArray *vclist = [self.navigationController viewControllers];
        int idx = (int)([vclist count] - 2);
        if (idx >= 0 && [[vclist objectAtIndex:idx] isKindOfClass:[SCChatController class]]) {
            
            SCChatController *cc = (SCChatController *) [vclist objectAtIndex:idx];
            if ([cc.targetUserid isEqualToString:group.groupid]) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
    }
    
    NSString *groupid = group.groupid;
    [self showGroupChatForUserid:groupid];
}

-(IBAction) editGroup:(id)sender;
{
    // TODO - GroupDetail Edit Group
}

-(IBAction)endEditGroupName:(id)sender
{
    editGroupName.selected = NO;
    [tfGroupName resignFirstResponder];
    
    [groupName setHidden:NO];
    [tfGroupName setHidden:YES];
    
    groupName.text = tfGroupName.text;
    
    group.groupName = groupName.text;
    
    [group saveGroup];
}

-(IBAction)editGroupName:(id)sender
{
    if (editGroupName.selected) {
        [self endEditGroupName:sender];
    } else {
        editGroupName.selected = YES;
        
        [groupName setHidden:YES];
        [tfGroupName setHidden:NO];
        tfGroupName.text = groupName.text;
        [tfGroupName becomeFirstResponder];
    }
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    return YES;
}


#pragma mark Photo Selection
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:NSLocalizedString(@"Select from Camera Roll", @"Choice Title")]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    
    if ([btnTitle isEqualToString:NSLocalizedString(@"Use Camera", @"Choice Title")]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1);
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

-(IBAction)selectPhoto:(id)sender
{
    NSString *actionSheetTitle = NSLocalizedString(@"Select Photo", @"GroupDetail ActionSheet Title");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Button") destructiveButtonTitle:nil otherButtonTitles:nil];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Select from Camera Roll", @"Choice Title")];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Use Camera", @"Choice Title")];
    }
    
    [actionSheet showInView:self.parentViewController.view];
}

- (UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient
{
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetHeight(imgRef);
    CGFloat             height = CGImageGetWidth(imgRef);
    CGAffineTransform   transform = CGAffineTransformIdentity;
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
    CGFloat             boundHeight;
    
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((orient == UIImageOrientationDown) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationUp)){
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage*)fixImage:(UIImage*)img withQuality:(int) quality
{
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    CGFloat scale = 1.;
    switch (quality) {
        case UIImagePickerControllerQualityTypeLow:
            // 320*240
            if (width > height) {
                scale = 320./width;
            } else {
                scale = 320./height;
            }
            break;
        case UIImagePickerControllerQualityTypeMedium:
            // 640x480
            if (width > height) {
                scale = 640./width;
            } else {
                scale = 640./height;
            }
            break;
        case UIImagePickerControllerQualityTypeHigh:
            // 320*240
            scale = 1.;
            break;
    }
    width *= scale;
    height *= scale;
    CGRect              bounds = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(bounds.size);
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [img drawInRect:bounds];
    //CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Get the selected image.
    
    SCWaitIndicatorController *pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Exporting Image...", @"Title") andWaitMessage:nil];
    [pleaseWait show:[[UIApplication sharedApplication] keyWindow]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *picname = group.groupid;
        DLog(@"picname : %@", picname);
        picname = [NSString stringWithFormat:@"%@.jpg", picname];
        
        @autoreleasepool {
            UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
            
            int quality = picker.videoQuality;
            UIImage *image = [self fixImage:originalImage withQuality:quality];
            
            image = [ImageUtil thumbnailFromImage:image withSize:120.];
            
            SCGroupDetailHeaderController *weakself = self;
            
            [group setGroupImage:image withCompletionHandler:^(BOOL finished) {
                [pleaseWait hide];
                weakself.imageButton.image = image;
            }];
        }
    });
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
}

@end
