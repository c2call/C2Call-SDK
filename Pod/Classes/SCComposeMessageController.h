//
//  SCComposeMessageController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 20.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class C2TapImageView, SearchTableController;

/** Presents the standard C2Call SDK Compose Message Controller.
 
 The Compose Message Controller is a complex controller for sending an instant message, a rich media message or an SMS/Text message to a receiver.
 To select the receiver it shows the last 10 recent messaging contacts and also allows seeking for a name, 
 email address or phone number in the friend list and the iOS address book.
 
 For SMS/Text messages the number of characters counts, number of SMS and shows the price per SMS for this destination.
 
*/
@interface SCComposeMessageController : UIViewController<UITextFieldDelegate, UITextViewDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/** @name outlets */
/** Searches Table for search results. */
@property(nonatomic, weak) IBOutlet UITableView               *searchTableView;

/** UITextField to enter the search text. */
@property(nonatomic, weak) IBOutlet UITextField               *searchField;

/** UITextView to enter the message text. */
@property(nonatomic, weak) IBOutlet UITextView                *messageField;

/** Searches Table Controller. */
@property(nonatomic, strong) IBOutlet SearchTableController   *searchTableController;

/** Label Number of Characters. */
@property(nonatomic, weak) IBOutlet UILabel                   *numChars;

/** Label Number of SMS. */
@property(nonatomic, weak) IBOutlet UILabel                   *numSMS;

/** Label SMS Price Information. */
@property(nonatomic, weak) IBOutlet UILabel                   *priceInfo;

/** Label To: */
@property(nonatomic, weak) IBOutlet UILabel                   *labelTo;

/** UIView reference to message view. */
@property(nonatomic, weak) IBOutlet UIView                    *messageView;

/** UIView reference to info view. */
@property(nonatomic, weak) IBOutlet UIView                    *infoView;

/** Message Type icon. */
@property(nonatomic, weak) IBOutlet UIImageView               *icon;

/** Attachment Image. */
@property(nonatomic, weak) IBOutlet C2TapImageView            *attachmentImage;

/** Toggle Encryption Button */
@property(nonatomic, weak) IBOutlet UIButton                  *encryptMessageButton;

/** @name Properties */
/** Selected Contact from Search Results. */
@property(nonatomic, strong) NSDictionary                       *selectedContact;

/** List of recent contacts. */
@property(nonatomic, strong) NSArray                            *recentList;

/** Rich Message Key of chosen rich media item. */
@property(nonatomic, strong) NSString                           *richMessageKey;

/** Targets UserId or phone number of the receiver. */
@property(nonatomic, strong) NSString                           *targetUserid;

/** Pre-set message template. */
@property(nonatomic, strong) NSString                           *messageTemplate;

/** Pre-select the last contact when open the controller. */
@property(nonatomic, assign) BOOL                               selectLastRecent;

/** @name Actions */
/** Closes ViewController Action.
 @param sender - The initiator of the action
 */
-(IBAction) close:(id)sender;

/** Selects Rich Message Action.
 
 Default Implementation:
 
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
            numberOrUserid = [SIPUtil normalizePhoneNumber:searchField.text];
        }
        
        BOOL isSMS = YES;
        if (!numberOrUserid) {
            isSMS = NO;
            numberOrUserid = [self.selectedContact objectForKey:@"Userid"];
        }
        self.targetUserid = numberOrUserid;
        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        for (NSString *mtype in mediaTypes) {
            DLog(@"mediaType : %@", mtype);
        }
        
        SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [cv addChoiceWithName:NSLocalizedString(@"Choose Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Select from Camera Roll", @"Button") andIcon:[UIImage imageNamed:@"ico_image"] andCompletion:^{
                
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
            [cv addChoiceWithName:NSLocalizedString(@"Take Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Use Camera", @"Button") andIcon:[UIImage imageNamed:@"ico_cam-24x24"] andCompletion:^{
                
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
            [cv addChoiceWithName:NSLocalizedString(@"Submit Location", @"Choice Title") andSubTitle:NSLocalizedString(@"Submit your current location", @"Button") andIcon:[UIImage imageNamed:@"ico_geolocation-24x24"] andCompletion:^{
                [self requestLocation:^(NSString *key) {
                    self.richMessageKey = key;
                    self.attachmentImage.image = [[C2CallPhone currentPhone] thumbnailForKey:key];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
            
        }
        
        if ([[AVAudioSession sharedInstance] inputIsAvailable]) {
            [cv addChoiceWithName:NSLocalizedString(@"Submit Voice Mail", @"Choice Title") andSubTitle:NSLocalizedString(@"Record a voice message", @"Button") andIcon:[UIImage imageNamed:@"ico_mic"] andCompletion:^{
                
                [self recordVoiceMail:^(NSString *key) {
                    self.richMessageKey = key;
                    self.attachmentImage.image = [UIImage imageNamed:@"ico_voice_msg"];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }
        
        if (!isSMS) {
            [cv addChoiceWithName:NSLocalizedString(@"Share Friends", @"Choice Title") andSubTitle:NSLocalizedString(@"Share one or more friends", @"Button") andIcon:[UIImage imageNamed:@"ico_share_friend"] andCompletion:^{
                [self shareFriends:numberOrUserid];
            }];
        }
        
        if ([IOS iosVersion] >= 5.0) {
            [cv addChoiceWithName:NSLocalizedString(@"Send Contact", @"Choice Title") andSubTitle:NSLocalizedString(@"Send a contact from address book", @"Button") andIcon:[UIImage imageNamed:@"ico_apple_mail"] andCompletion:^{
                [self showPicker:nil];
            }];
        }
        
        
        [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        }];
        
        [cv showMenu];
     }

 @param sender - The initiator of the action
 */
-(IBAction) selectRichMessage:(id)sender;

/** Toggle encryption for message submit
 
 If the receiver has a public key, the message can be submitted 2048 bit encrypted.
 
 @param sender - The initiator of the action
 */
-(IBAction)toggleSecureMessageButton:(id)sender;

/** Submits Message Action.
 
 @param sender - The initiator of the action

 */
-(IBAction) submit:(id) sender;


@end
