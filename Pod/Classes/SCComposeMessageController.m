//
//  SCComposeMessageController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 20.02.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>

#import "SCComposeMessageController.h"
#import "UIViewController+SCCustomViewController.h"
#import "C2CallPhone.h"
#import "SearchTableController.h"
#import "AlertUtil.h"
#import "IOS.h"
#import "DateUtil.h"
#import "SCWaitIndicatorController.h"
#import "C2TapImageView.h"
#import "FCLocation.h"
#import "SCPopupMenu.h"
#import "SCLocationSubmitController.h"
#import "SCAudioRecorderController.h"
#import "SCDataManager.h"
#import "SCUserProfile.h"
#import "C2CallAppDelegate.h"
#import "SIPUtil.h"
#import "SCAssetManager.h"

#import "debug.h"

@interface SCComposeMessageController ()<UITextFieldDelegate, UITextViewDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    int                 imageQuality;
    BOOL                isKeyboard, showMessageView;
}

// Not used yet
@property(nonatomic, weak) IBOutlet UIButton                  *btnShareFacebook, *btnShareTwitter;
@property(nonatomic, weak) IBOutlet UIView                    *shareView;
@property(nonatomic, weak) IBOutlet UILabel                   *lableShareOn;

@property(nonatomic, assign) BOOL                             shareOnFacebook, shareOnTwitter;

@end

@implementation SCComposeMessageController

@synthesize searchTableView, searchField, searchTableController, numSMS, numChars, priceInfo, messageView;
@synthesize richMessageKey, selectedContact, targetUserid, attachmentImage, selectLastRecent, shareView, shareOnTwitter, shareOnFacebook;
@synthesize btnShareTwitter, btnShareFacebook, messageTemplate;

@synthesize messageField, infoView, icon, labelTo, recentList, lableShareOn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    DLog(@"SCComposeMessageController:didReceiveMemoryWarning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void) refreshRichMessage
{
    UIImage *image = nil;
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    if ([self.richMessageKey hasPrefix:@"friend://"]) {
        NSURL *friendUrl = [NSURL URLWithString:self.richMessageKey];
        NSString *userid = [friendUrl host];
        DLog(@"Userid : %@", userid);
        
        image = [[C2CallPhone currentPhone] userimageForUserid:userid];
        if (!image) {
            if ([[C2CallPhone currentPhone] isGroupUser:userid]) {
                image = [UIImage imageNamed:@"btn_ico_avatar_group" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            } else {
                image = [UIImage imageNamed:@"btn_ico_avatar" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            }
        }
    } else {
        image = [[C2CallPhone currentPhone] thumbnailForKey:self.richMessageKey];
    }
    
    if (image) {
        self.attachmentImage.image = image;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (!self.recentList) {
        self.recentList = [[SCDataManager instance] recentContacts];
    }
    
    self.searchTableController.recentList = self.recentList;
    
    self.btnShareFacebook.enabled = [[SCUserProfile currentUser] useFacebook];
    self.btnShareTwitter.enabled = NO;
    
    if (!self.richMessageKey && !self.messageTemplate) {
        self.messageField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"text-newmessage"];
    }
    
    if (self.messageTemplate) {
        self.messageField.text = messageTemplate;
        self.messageTemplate = nil;
    }
    
    if (self.richMessageKey) {
        [self refreshRichMessage];
    }
    
    
    [self.searchTableController initAddressbook];
    [self.searchTableController initRecentList];
}

- (void) viewDidUnload
{
    DLog(@"NewMessageController:viewDidUnload");
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    self.searchTableView = nil;
    self.searchField.delegate = nil;
    self.searchField = nil;
    self.messageField = nil;
    self.searchTableController = nil;
    self.numChars = nil;
    self.numSMS = nil;
    self.priceInfo = nil;
    self.labelTo = nil;
    self.infoView = nil;
    self.icon = nil;
    self.attachmentImage = nil;
    self.lableShareOn = nil;
    self.shareView = nil;
    
}

-(BOOL) facebookMedia:(NSString *) key
{
    if ([key hasPrefix:@"image://"]) {
        return YES;
    }
    
    if ([key hasPrefix:@"video://"]) {
        return YES;
    }
    
    if ([key hasPrefix:@"loc://"]) {
        return YES;
    }
    
    return NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillHideNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"SearchTableController:NewMessage" object:nil];
    self.messageField.delegate = self;
    [self.attachmentImage setTapAction:^(){
        // We only use this to forward attachements on HD
        [self selectRichMessage:nil];
    }];
    
    if (showMessageView) {
        [self.messageField becomeFirstResponder];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(submit:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Button") style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];

    }
    
    if ([self.richMessageKey length] > 0) {
        if (![self facebookMedia:self.richMessageKey]) {
            btnShareFacebook.selected = NO;
            shareOnFacebook = NO;
        }
    }
    
    if (selectLastRecent) {
        self.selectLastRecent = NO;
        if ([self.searchTableController.resultSet count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchTableController:NewMessage" object:self userInfo:[self.searchTableController.resultSet objectAtIndex:0]];
        }
    }
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent;
{
    self.navigationItem.title = NSLocalizedString(@"New Message", @"Title");
    if (showMessageView) {
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(submit:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Button") style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[C2CallAppDelegate appDelegate] logEvent:@"NewMessageOpened"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([searchField isFirstResponder]) {
        [searchField resignFirstResponder];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.messageField.delegate = nil;
    [self.attachmentImage setTapAction:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL) isValidNumber:(NSString *) number
{
    return [[SIPPhone currentPhone] isValidNumber:number];
}

-(void) toggleMessageView:(BOOL) showView
{
    if (showView && !showMessageView) {
        [self refreshSecureMessageButton];

        showMessageView = YES;
        [messageView setHidden:NO];
        [searchTableView setHidden:YES];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(submit:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Button") style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];

    }
    
    if (!showView && showMessageView){
        self.selectedContact = nil;
        self.icon.image = nil;
        showMessageView = NO;
        [messageView setHidden:YES];
        [searchTableView setHidden:NO];
        self.navigationItem.rightBarButtonItem = nil;
        [self.searchField becomeFirstResponder];
    }
}

-(IBAction)toggleShareOnFacebook:(UIButton *)sender
{
    if (!sender.selected) {
        if ([self.richMessageKey length] > 0) {
            if (![self facebookMedia:self.richMessageKey]) {
                return;
            }
        }
    }
    
    shareOnFacebook = !sender.selected;
    sender.selected = shareOnFacebook;
}

-(IBAction)toggleShareOnTwitter:(UIButton *)sender
{
    shareOnTwitter = !sender.selected;
    sender.selected = shareOnTwitter;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to
{
    @try {
        NSString *newtext = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        BOOL res = [searchTableController setFilter:newtext];
        
        if ([newtext length] > 0 && !res) {
            self.icon.image = nil;
            self.infoView.hidden = YES;
            self.shareView.hidden = YES;
            
            [self toggleMessageView:YES];
        } else {
            [self toggleMessageView:NO];
        }
        
    }
    @catch (NSException *exception) {
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField;
{
    [searchTableController setFilter:nil];
    [self toggleMessageView:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (!textField.text || [textField.text isEqualToString:@""]) {
        return NO;
    }
    
    BOOL res = [self isValidNumber:textField.text];
    if (res) {
        [self toggleMessageView:YES];
        NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
        self.icon.image = [UIImage imageNamed:@"ico_sms-24x24" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        
        [messageField becomeFirstResponder];
    }
    
    return res;
}

- (CGSize)keyboardSize:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    NSValue *beginValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGSize keyboardSize;
    CGSize sz = [beginValue CGRectValue].size;
    if (sz.width / sz.height < 1.) {
        keyboardSize.width = sz.height;
        keyboardSize.height = sz.width;
    } else {
        keyboardSize = sz;
    }
    
    return keyboardSize;
}

-(void) handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"UIKeyboardDidShowNotification"]) {
        DLog(@"UIKeyboardDidShowNotification");
        if (isKeyboard)
            return;
        
        CGSize keyboardSize = [self keyboardSize:notification];
        //			CGRect	rect;
        //			[[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&rect];
        
        CGRect frame = searchTableView.frame;
        DLog(@"Frame : %f / %f ", frame.size.width, frame.size.height);
        DLog(@"Keyboard : %f / %f ", keyboardSize.width, keyboardSize.height);
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
            frame.size.height -= (keyboardSize.height - 49.); // 49 is TabBar height
        } else {
            frame.size.height -= (keyboardSize.height - 49.);
        }

        searchTableView.frame = frame;
        DLog(@"Frame(new) : %f / %f ", frame.size.width, frame.size.height);
        isKeyboard = YES;
    }
    
    
    if ([[notification name] isEqualToString:@"UIKeyboardWillHideNotification"]) {
        DLog(@"UIKeyboardWillHideNotification");
        if (!isKeyboard)
            return;
        
        CGSize keyboardSize = [self keyboardSize:notification];
        CGRect frame = searchTableView.frame;
        
        DLog(@"Frame : %f / %f ", frame.size.width, frame.size.height);
        DLog(@"Keyboard : %f / %f ", keyboardSize.width, keyboardSize.height);
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
            frame.size.height += (keyboardSize.height - 49.);
        } else {
            frame.size.height += (keyboardSize.height - 49.);
        }

        searchTableView.frame = frame;
        DLog(@"Frame(new) : %f / %f ", frame.size.width, frame.size.height);
        isKeyboard = NO;
    }
    
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    if ([[notification name] isEqualToString:@"SearchTableController:NewMessage"]) {
        self.selectedContact = [notification userInfo];
        [self toggleMessageView:YES];
        self.searchField.text = [self.selectedContact objectForKey:@"Name"];
        if ([[[notification userInfo] objectForKey:@"Type"] isEqualToString:@"SMS"]) {
            self.icon.image = [UIImage imageNamed:@"ico_sms" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        } else {
            self.icon.image = [UIImage imageNamed:@"ico_friendcaller-color" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        }
        [self.messageField becomeFirstResponder];
    }
    
    if ([[notification name] isEqualToString:@"PriceInfoEvent"] && [[[notification userInfo] objectForKey:@"sms"] boolValue]) {
        DLog(@"Price : %@", [[notification userInfo] objectForKey:@"PriceString"]);
        self.priceInfo.text = [NSString stringWithFormat:@"%@/SMS", [[notification userInfo] objectForKey:@"PriceString"]];
    }
    
}

-(void) shareFacebookMessage:(NSString *) message withKey:(NSString *) key
{
    [[C2CallPhone currentPhone] shareMessageOnFacebook:message usingAttachment:key];
}

-(void) shareTwitterMessage:(NSString *) message withKey:(NSString *) key
{
    
}

-(void) shareMessage:(NSString *) message withKey:(NSString *) key
{
    if (self.shareOnFacebook) {
        [self shareFacebookMessage:message withKey:key];
    }
    
    if (self.shareOnTwitter) {
        [self shareTwitterMessage:message withKey:key];
    }
}

-(IBAction)close:(id)sender
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:NO];
    if (!vc)
        [self dismissViewControllerAnimated:YES completion:NULL];
}

-(NSString *) currentContact
{
    NSString *numberOrUserid = nil;
    if (self.selectedContact) {
        numberOrUserid = [self.selectedContact objectForKey:@"Number"];
    } else {
        numberOrUserid = [SIPPhone normalizeNumber:searchField.text];
    }
    
    BOOL isSMS = YES;
    if (!numberOrUserid) {
        isSMS = NO;
        numberOrUserid = [self.selectedContact objectForKey:@"Userid"];
    }
    return numberOrUserid;
}

-(IBAction) submit:(id) sender
{
    if (!self.selectedContact && ![self isValidNumber:searchField.text]) {
        [AlertUtil showInvalidNumberOrContact];
        return;
    }
    
	NSString *text = [messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([text length] == 0 && [self.richMessageKey length] == 0) {
		[AlertUtil showPleaseEnterText];
		return;
	}
    
    if ([self.messageField isFirstResponder]) {
        [self.messageField resignFirstResponder];
    }
    
    NSString *numberOrUserid = nil;
    if (self.selectedContact) {
        numberOrUserid = [self.selectedContact objectForKey:@"Number"];
    } else {
        numberOrUserid = [SIPPhone normalizeNumber:searchField.text];
    }
    
    BOOL isSMS = YES;
    if (!numberOrUserid) {
        isSMS = NO;
        numberOrUserid = [self.selectedContact objectForKey:@"Userid"];
    }
    
    [[C2CallPhone currentPhone] submitRichMessage:self.richMessageKey message:messageField.text toTarget:numberOrUserid preferEncrytion:self.encryptMessageButton.selected];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"text-newmessage"];
    
    [self close:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SCUserProfile currentUser] refreshUserCredits];
    });
}

-(void) updateSMSCount:(NSString *) text
{
    int currentLength = 0;
    int smsLength = 160;
    if ([text canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
        currentLength = (int)[text length];
    } else {
        // Binary SMS have 2 Bytes (8-Bit UTF16 Encoding)
        smsLength = 70;
        currentLength = (int)[text length];
    }
    
    if (self.richMessageKey) {
        currentLength += 50;
    }
    
    int anz = (currentLength / smsLength) + 1;
    numChars.text = [NSString stringWithFormat:@"%d/%d", currentLength, smsLength];
    numSMS.text = [NSString stringWithFormat:@"%d SMS", anz];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    @try {
        NSString *newtext = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if ([newtext length] > 1500) {
            return NO;
        }
        
        if ([newtext length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:newtext forKey:@"text-newmessage"];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"text-newmessage"];
        }
        
        [self updateSMSCount:newtext];
    }
    @catch (NSException *exception) {
    }
    
    return YES;
}

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL isSMS = NO;
    if (self.selectedContact) {
        if ([[self.selectedContact objectForKey:@"Type"] isEqualToString:@"SMS"]) {
            isSMS = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"PriceInfoEvent" object:nil];
            [[C2CallPhone currentPhone] queryPriceForNumber:[self.selectedContact objectForKey:@"Number"] isSMS:YES];
        }
    } else {
        if ([self isValidNumber:searchField.text]) {
            isSMS = YES;
            NSString *number = [SIPPhone normalizeNumber:searchField.text];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"PriceInfoEvent" object:nil];
            [[C2CallPhone currentPhone] queryPriceForNumber:number isSMS:YES];
        }
    }
    
    if (!isSMS) {
        self.infoView.hidden = YES;
        self.shareView.hidden = NO;
    } else {
        [self updateSMSCount:textView.text];
        self.infoView.hidden = NO;
        self.shareView.hidden = YES;
    }
    return YES;
}

-(void) refreshSecureMessageButton
{
    NSString *targetContact = [self currentContact];
    if ([SIPUtil isPhoneNumber:targetContact]) {
        self.encryptMessageButton.hidden = YES;
        self.encryptMessageButton.selected = NO;
        return;
    }
    
    BOOL pk = [[C2CallPhone currentPhone] canEncryptMessageForTarget:targetContact];
    if (pk) {
        self.encryptMessageButton.selected = [C2CallPhone currentPhone].preferMessageEncryption;
        self.encryptMessageButton.hidden = NO;
        self.encryptMessageButton.enabled = YES;
    } else {
        self.encryptMessageButton.selected = NO;
        self.encryptMessageButton.hidden = YES;
        self.encryptMessageButton.enabled = NO;
    }
}

-(IBAction)toggleSecureMessageButton:(id)sender
{
    self.encryptMessageButton.selected = !self.encryptMessageButton.selected;
}

#pragma mark Rich Message

-(void) shareFriends:(NSString *) targetUserid
{
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
}

-(IBAction)selectRichMessage:(id)sender
{
    if (!self.selectedContact && ![self isValidNumber:searchField.text]) {
        [AlertUtil showInvalidNumberOrContact];
        return;
    }
    
    if ([messageField isFirstResponder])
        [messageField resignFirstResponder];
    
    
    NSString *numberOrUserid = nil;
    if (self.selectedContact) {
        numberOrUserid = [self.selectedContact objectForKey:@"Number"];
    } else {
        numberOrUserid = [SIPPhone normalizeNumber:searchField.text];
    }
    
    BOOL isSMS = YES;
    if (!numberOrUserid) {
        isSMS = NO;
        numberOrUserid = [self.selectedContact objectForKey:@"Userid"];
    }
    self.targetUserid = numberOrUserid;
    
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [cv addChoiceWithName:NSLocalizedString(@"Choose Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Select from Camera Roll", @"Button") andIcon:[UIImage imageNamed:@"ico_image" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^{
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, kUTTypeMovie, nil];
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
            
            [self captureMediaFromImagePicker:imagePicker andCompleteAction:^(NSString *key) {
                self.richMessageKey = key;
                self.attachmentImage.image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            }];
        }];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [cv addChoiceWithName:NSLocalizedString(@"Take Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Use Camera", @"Button") andIcon:[UIImage imageNamed:@"ico_cam-24x24" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^{
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, kUTTypeMovie, nil];
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
            [self captureMediaFromImagePicker:imagePicker andCompleteAction:^(NSString *key) {
                self.richMessageKey = key;
                self.attachmentImage.image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            }];
        }];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [cv addChoiceWithName:NSLocalizedString(@"Submit Location", @"Choice Title") andSubTitle:NSLocalizedString(@"Submit your current location", @"Button") andIcon:[UIImage imageNamed:@"ico_geolocation-24x24" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^{
            [self requestLocation:^(NSString *key) {
                self.richMessageKey = key;
                self.attachmentImage.image = [[C2CallPhone currentPhone] thumbnailForKey:key];
            }];
        }];
        
    }
    
    if ([AVAudioSession sharedInstance].inputAvailable) {
        [cv addChoiceWithName:NSLocalizedString(@"Submit Voice Mail", @"Choice Title") andSubTitle:NSLocalizedString(@"Record a voice message", @"Button") andIcon:[UIImage imageNamed:@"ico_mic" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^{
            
            [self recordVoiceMail:^(NSString *key) {
                self.richMessageKey = key;
                self.attachmentImage.image = [UIImage imageNamed:@"ico_voice_msg" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            }];
        }];
    }
    
    if ([IOS iosVersion] >= 5.0) {
        [cv addChoiceWithName:NSLocalizedString(@"Send Contact", @"Choice Title") andSubTitle:NSLocalizedString(@"Send a contact from address book", @"Button") andIcon:[UIImage imageNamed:@"ico_apple_mail" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^{
            [self showPicker:nil];
        }];
    }
    
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
    
}

#pragma mark people picker

- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
    NSArray *people = [NSArray arrayWithObject:(__bridge id)(person)];
    CFArrayRef peopleRef = (__bridge CFArrayRef) people;
    CFDataRef vcardRef = ABPersonCreateVCardRepresentationWithPeople(peopleRef);
    
    NSData *vcardData = (__bridge NSData *) vcardRef;
    
    NSString *key = [NSString stringWithFormat:@"%@-%lld", [SCUserProfile currentUser].userid, [DateUtil currentTimeMilliseconds]];
    DLog(@"vcard name : %@", key);
    
    NSString *compositName =  (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
    
    if ([compositName length] > 0) {
        key = [NSString stringWithFormat:@"vcard://vcard%@.vcf?name=%@", [SIPUtil md5:key], [compositName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        key = [NSString stringWithFormat:@"vcard://vcard%@.vcf", [SIPUtil md5:key]];
    }
    
    
    NSString *path = [[C2CallPhone currentPhone] pathForKey:key];
    [vcardData writeToFile:path atomically:NO];
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    self.richMessageKey = key;
    self.attachmentImage.image = [UIImage imageNamed:@"btn_ico_adressbook_contact" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
    
    if (vcardRef)
        CFRelease(vcardRef);
    
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:^() {
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

@end
