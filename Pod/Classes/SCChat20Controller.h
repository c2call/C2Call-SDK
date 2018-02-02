//
//  SCChatController.h
//  SimplePhone
//
//  Created by Michael Knecht on 21.04.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "SCBoard20Controller.h"

/** Presents the standard C2Call SDK Rich Media/Text Chat Controller.
 
 The ChatController is embedding the SCBoard20Controller for the chat history and implements a chat bar to enter text messages and to submit rich media items.
 */

@class SCBoard20Controller, SCFlexibleToolbarView;

@interface SCChat20Controller : UIViewController<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ABPeoplePickerNavigationControllerDelegate, SCBoard20ControllerDelegate, UIDocumentPickerDelegate>

/** @name Outlets */
/** Label Number of SMS.
 
 Counts the number of SMS required in case on an SMS/Text message.
 */
@property(nonatomic, weak) IBOutlet UILabel                 *numSMS;

/** Labels Number of Characters.
 
 Counts the number of characters in case on an SMS/Text message.
 */
@property(nonatomic, weak) IBOutlet UILabel                 *numChars;

/** Labels SMS/Text message price information.
 
 In case of an SMS, the connected UILabel shows the current SMS costs. Else it will be hidden.
 */
@property(nonatomic, weak) IBOutlet UILabel                 *smsCosts;

/** Submit Message Button. */
@property(nonatomic, weak) IBOutlet UIButton                *submitButton;

/** Toggle Message Encryption Button. */
@property(nonatomic, weak) IBOutlet UIButton                *encryptMessageButton;

/** The Chat Bar Control. */
@property(nonatomic, weak) IBOutlet SCFlexibleToolbarView   *toolbarView;

/** Toolbar Bottom Contraint
 
 For internal use only
 */
@property(nonatomic, weak) IBOutlet NSLayoutConstraint      *toolbarBottomContraint;

/** UITextView chat message. */
@property(nonatomic, weak) IBOutlet UITextView              *chatInput;

/** @name properties */
/** References to the embedded SCBoard20Controller. */
@property(nonatomic, weak) SCBoard20Controller                *chatboard;

/** Targets userId or phone number for the chat. */
@property(nonatomic, strong) NSString                       *targetUserid;

/** Suppress Call Events in Chat History
 
 This option is set to YES by default
 */
@property (nonatomic) BOOL dontShowCallEvents;


/** Sets the focus on the chat input to start edit when the view appears. */
@property(nonatomic) BOOL                                   startEdit;

/** Corner radius for the UITextView chat input control.
 
 This is an UIAppearance Selector
 */
@property(nonatomic) CGFloat                                chatInputCornerRadius UI_APPEARANCE_SELECTOR;

/** Border color for the UITextView chat input control.
 
 This is an UIAppearance Selector.
 */
@property(nonatomic, strong) UIColor                        *chatInputBorderColor UI_APPEARANCE_SELECTOR;

/** Border width for the UITextView chat input control.
 
 This is an UIAppearance Selector.
 */
@property(nonatomic) CGFloat                                chatInputBorderWidth UI_APPEARANCE_SELECTOR;

/** Handles the typing event when the remote party is typing.
 
 This method will be called when the remote party is currently typing.
 The default implementation will show an UINavigationBar prompt message.
 
 -(void) handleTypingEvent:(NSString *) fromUserid
 {
 // Typing Event for this chat?
 if ([fromUserid isEqualToString:self.targetUserid]) {
 lastTypeEventReceived = CFAbsoluteTimeGetCurrent();
 
 // Show prompt
 self.navigationItem.prompt = NSLocalizedString(@"is typing...", "TypingEvent Title");
 double delayInSeconds = 2.5;
 
 // And remove if no further event has been receive in the past few seconds
 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
 if (CFAbsoluteTimeGetCurrent() - lastTypeEventReceived > 2.4) {
 self.navigationItem.prompt = nil;
 }
 });
 }
 }
 
 @param fromUserid - Userid of the user who is currently typing
 
 */
-(void) handleTypingEvent:(NSString *) fromUserid;

/** Handles an SMS PriceInfo Event and update UILabel smsCosts with the costs.
 */
-(void) updateSMSPriceInfo:(NSString *) priceInfo;

/** @name Actions */
/** Select Rich Message Action.
 
 Opens a PopupMenu to select a Rich Media Item for submission.
 Default Implementation:
 
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
 [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
 }];
 //[self presentModalViewController:imagePicker animated:YES];
 }];
 }
 
 if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
 if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
 [cv addChoiceWithName:NSLocalizedString(@"Take Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Use Camera", @"Button") andIcon:[UIImage imageNamed:@"ico_cam-24x24"] andCompletion:^{
 
 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
 imagePicker.delegate = self;
 imagePicker.allowsEditing = NO;
 imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
 imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, kUTTypeMovie, nil];
 imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
 [self captureMediaFromImagePicker:imagePicker andCompleteAction:^(NSString *key) {
 [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
 }];
 }];
 }
 }
 
 if ([CLLocationManager locationServicesEnabled]) {
 [cv addChoiceWithName:NSLocalizedString(@"Submit Location", @"Choice Title") andSubTitle:NSLocalizedString(@"Submit your current location", @"Button") andIcon:[UIImage imageNamed:@"ico_geolocation-24x24"] andCompletion:^{
 
 [self requestLocation:^(NSString *key) {
 DLog(@"submitLocation: %@ / %@", key, self.targetUserid);
 [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
 }];
 }];
 
 }
 
 if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
 if ([[AVAudioSession sharedInstance] inputIsAvailable]) {
 [cv addChoiceWithName:NSLocalizedString(@"Submit Voice Mail", @"Choice Title") andSubTitle:NSLocalizedString(@"Record a voice message", @"Button") andIcon:[UIImage imageNamed:@"ico_mic"] andCompletion:^{
 
 [self recordVoiceMail:^(NSString *key) {
 DLog(@"submitVoiceMail: %@ / %@", key, self.targetUserid);
 [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
 }];
 }];
 }
 }
 
 if (!isSMS) {
 [cv addChoiceWithName:NSLocalizedString(@"Share Friends", @"Choice Title") andSubTitle:NSLocalizedString(@"Share one or more friends", @"Button") andIcon:[UIImage imageNamed:@"ico_share_friend"] andCompletion:^{
 // TODO - SCChatController - ShareFriends
 //[self shareFriends:numberOrUserid];
 }];
 }
 
 if ([IOS iosVersion] >= 5.0) {
 [cv addChoiceWithName:NSLocalizedString(@"Send Contact", @"Choice Title") andSubTitle:NSLocalizedString(@"Send a contact from address book", @"Button") andIcon:[UIImage imageNamed:@"ico_apple_mail"] andCompletion:^{
 [self showPicker:nil];
 }];
 }
 
 [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Choice Title") andCompletion:^{
 }];
 
 [cv showMenu];
 
 @param sender - The initiator of the action
 */
-(IBAction)selectRichMessage:(id)sender;

/** Shows ABPeoplePickerNavigationController Action.
 
 Submits a VCARD, select from ABPeoplePickerNavigationController.
 
 @param sender - The initiator of the action
 */
-(IBAction)showPicker:(id)sender;

/** Shows UIDocumentPickerController Action.
 
 Submits a Document, selected from UIDocumentPickerController.
 
 @param sender - The initiator of the action
 */
-(IBAction)showDocumentPicker:(id)sender;

/** Hides Keyboard Action.
 
 @param sender - The initiator of the action
 */
-(IBAction)hideKeyboard:(id)sender;

/** Closes ViewController Action.
 
 @param sender - The initiator of the action
 */
-(IBAction) close:(id) sender;

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

