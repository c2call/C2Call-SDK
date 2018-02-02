//
//  SCChatController.m
//  SimplePhone
//
//  Created by Michael Knecht on 21.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UIViewController+SCCustomViewController.h"

#import "C2CallAppDelegate.h"
#import "SCChat20Controller.h"
#import "SCBoard20Controller.h"
#import "SCFlexibleToolbarView.h"
#import "SCPopupMenu.h"

#import "AlertUtil.h"
#import "C2CallPhone.h"
#import "SIPPhone.h"
#import "SCUserProfile.h"
#import "SCDataManager.h"

#import "MOC2CallUser.h"

#import "IOS.h"
#import "SCWaitIndicatorController.h"
#import "C2TapImageView.h"
#import "SCAssetManager.h"


#import "debug.h"

@interface SCChat20Controller () {
    
    NSTimeInterval      lastTypeEvent, lastTypeEventReceived;
    
    //CGFloat             resizeOffset, minToolbarHeight;
    CGFloat             currentKeyboardSize;
    
    BOOL                isGroupChat, isSMS, isKeyboard, hasMaxToolbarSize, hasTabBar, keyboardAnimation, didAppear;
}

@end

@implementation SCChat20Controller
@synthesize chatboard, numChars, numSMS, smsCosts, targetUserid, toolbarView, chatInput, submitButton;
@synthesize chatInputBorderColor, chatInputBorderWidth, chatInputCornerRadius, startEdit, dontShowCallEvents, toolbarBottomContraint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chatInputBorderWidth = 1.;
        self.chatInputCornerRadius = 5.;
        self.chatInputBorderColor = [UIColor grayColor];
        self.dontShowCallEvents = YES;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.chatInputBorderWidth = 1.;
        self.chatInputCornerRadius = 5.;
        self.chatInputBorderColor = [UIColor grayColor];
        self.dontShowCallEvents = YES;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"SCChat20Controller:dealloc()");
    
    [self.chatboard dispose];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL) isPhoneNumber:(NSString *) uid
{
    if ([uid hasPrefix:@"+"] && [uid rangeOfString:@"@"].location == NSNotFound) {
        return YES;
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SCBoard20Controller class]]) {
            self.chatboard = (SCBoard20Controller *) vc;
            self.chatboard.dontShowCallEvents = self.dontShowCallEvents;
        }
    }
    
    [self addCloseButtonIfNeeded];
    
    if (self.chatInputBorderWidth > 0.) {
        CALayer *l = self.chatInput.layer;
        l.borderWidth = self.chatInputBorderWidth;
        l.cornerRadius = self.chatInputCornerRadius;
        l.borderColor = [self.chatInputBorderColor CGColor];
    }
    
    if ([self.chatInput respondsToSelector:@selector(textContainerInset)]) {
    }
    
    if ([self.chatInput respondsToSelector:@selector(textContainer)]) {
        self.chatInput.textContainer.heightTracksTextView = YES;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillChangeFrameNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidChangeFrameNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"SIPHandler:TypingEvent" object:nil];
    
    NSString *name = [[C2CallPhone currentPhone] nameForUserid:self.targetUserid];
    DLog(@"Name : %@ / %@", name, self.targetUserid);
    
    self.title = name;
    
    isGroupChat = NO;
    if ([self isPhoneNumber:self.targetUserid]) {
        isSMS = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"PriceInfoEvent" object:nil];
        [[C2CallPhone currentPhone] queryPriceForNumber:self.targetUserid isSMS:YES];
        self.smsCosts.hidden = NO;
    } else {
        isSMS = NO;
        self.smsCosts.hidden = YES;
        if ([SCDataManager instance].isDataInitialized) {
            MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
            isGroupChat = [user.userType intValue] == 2;
        }
    }
    
    [self refreshSecureMessageButton];
    if ([IOS iosVersion] >= 7.) {
        CGFloat inset =[self encryptButtonInset];
        UIEdgeInsets edges = self.chatInput.textContainerInset;
        edges.right += inset;
        self.chatInput.textContainerInset = edges;
    } else {
        
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    hasTabBar = !self.tabBarController.tabBar.isHidden;
    
    if ([self.chatInput.text length] == 0) {
        [self initialToolbarSize];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    didAppear = YES;
    if (startEdit) {
        startEdit = NO;
        [self.chatInput becomeFirstResponder];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    didAppear = NO;
    if ([self.chatInput isFirstResponder]) {
        [self.chatInput resignFirstResponder];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    DLog(@"willRotateToInterfaceOrientation : %ld", (long)interfaceOrientation);
    
    CGRect frame1 = chatInput.frame;
    
    if (frame1.size.width == 0)
        return;
    
    CGSize maximumLabelSize = [self maximumLabelSize:self.chatInput];
    /*
     if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
     maximumLabelSize = [@"\n \n \n \n " boundingRectWithSize:CGSizeMake(frame1.size.width - 16, 999.) options:NSStringDrawingUsesLineFragmentOrigin
     attributes:@{NSFontAttributeName:chatInput.font} context:nil].size;
     maximumLabelSize.width = ceilf(maximumLabelSize.width);
     maximumLabelSize.height = ceilf(maximumLabelSize.height);
     
     //maximumLabelSize = [@"\n \n \n \n " sizeWithFont:chatInput.font constrainedToSize:CGSizeMake(frame1.size.width - 16, 999.)];
     maximumLabelSize.width = frame1.size.width - 16;
     //maximumLabelSize = CGSizeMake(frame1.size.width - 16,64);
     } else {
     maximumLabelSize = [@"\n \n \n \n \n \n \n " boundingRectWithSize:CGSizeMake(frame1.size.width - 16, 999.) options:NSStringDrawingUsesLineFragmentOrigin
     attributes:@{NSFontAttributeName:chatInput.font} context:nil].size;
     maximumLabelSize.width = ceilf(maximumLabelSize.width);
     maximumLabelSize.height = ceilf(maximumLabelSize.height);
     
     //maximumLabelSize = [@"\n \n \n \n \n \n \n " sizeWithFont:chatInput.font constrainedToSize:CGSizeMake(frame1.size.width - 16, 999.)];
     maximumLabelSize.width = frame1.size.width - 16;
     //maximumLabelSize = CGSizeMake(frame1.size.width - 16,128);
     }
     */
    
    NSString *text = chatInput.text;
    if ([text hasSuffix:@"\n"]) {
        text = [NSString stringWithFormat:@"%@ ", text];
    }
    [self resizeToolbar:text textView:chatInput maxLabelSize:maximumLabelSize];
    
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextView Delegate

-(CGFloat) encryptButtonInset
{
    if (!self.encryptMessageButton || self.encryptMessageButton.hidden)
        return 0.;
    
    CGRect ef = self.encryptMessageButton.frame;
    CGRect f = self.chatInput.frame;
    
    CGFloat w1 = f.origin.x + f.size.width;
    w1 = w1 - ef.origin.x;
    
    if (w1 <= 0.)
        return 0;
    
    w1 += 4;
    return w1 - 8;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    return didAppear;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    @try {
        if (!isGroupChat && !isSMS) {
            if (CFAbsoluteTimeGetCurrent() - lastTypeEvent > 2.0) {
                lastTypeEvent = CFAbsoluteTimeGetCurrent();
                [[SIPPhone currentPhone] submitTypingEventToUser:self.targetUserid];
            }
        }
        
        NSString *newtext = nil;
        
        if ([text isEqualToString:@"\n"]) {
            newtext = [textView.text stringByReplacingCharactersInRange:range withString:text];
        } else {
            newtext = [textView.text stringByReplacingCharactersInRange:range withString:text];
        }
        
        if ([newtext hasSuffix:@"\n"]) {
            newtext = [NSString stringWithFormat:@"%@ ", newtext];
        }
        
        
        if ([newtext length] > 1500) {
            return NO;
        }
        
        if (isSMS) {
            [self updateSMSCount:newtext];
        }
        
        if ([newtext length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:newtext forKey:[NSString stringWithFormat:@"text-%@", self.targetUserid]];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"text-%@", self.targetUserid]];
        }
        
        CGSize maximumLabelSize = [self maximumLabelSize:textView];
        
        [self resizeToolbar:newtext textView:textView maxLabelSize:maximumLabelSize];
    }
    @catch (NSException *exception) {
    }
    
    return YES;
}

-(CGSize) maximumLabelSize:(UITextView *)textView
{
    CGRect frame1 = textView.frame;
    CGSize maximumLabelSize;
    
    CGFloat inset = 16;
    if ([IOS iosVersion] >= 7.) {
        UIEdgeInsets edges = self.chatInput.textContainerInset;
        inset = edges.left + edges.right;
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        maximumLabelSize = [@"\n \n \n \n " boundingRectWithSize:CGSizeMake(frame1.size.width - inset, 999.) options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:textView.font} context:nil].size;
        maximumLabelSize.width = ceilf(maximumLabelSize.width);
        maximumLabelSize.height = ceilf(maximumLabelSize.height);
        
        //maximumLabelSize = [@"\n \n \n \n " sizeWithFont:textView.font constrainedToSize:CGSizeMake(frame1.size.width - inset, 999.)];
        maximumLabelSize.width = frame1.size.width - inset;
        //maximumLabelSize = CGSizeMake(frame1.size.width - 16,64);
    } else {
        maximumLabelSize = [@"\n \n \n \n \n \n \n " boundingRectWithSize:CGSizeMake(frame1.size.width - inset, 999.) options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:textView.font} context:nil].size;
        maximumLabelSize.width = ceilf(maximumLabelSize.width);
        maximumLabelSize.height = ceilf(maximumLabelSize.height);
        
        //maximumLabelSize = [@"\n \n \n \n \n \n \n " sizeWithFont:textView.font constrainedToSize:CGSizeMake(frame1.size.width - inset, 999.)];
        maximumLabelSize.width = frame1.size.width - inset;
        //maximumLabelSize = CGSizeMake(frame1.size.width - 16,128);
    }
    
    return maximumLabelSize;
    
}

-(void) initialToolbarSize
{
    CGSize maxsz = [self maximumLabelSize:self.chatInput];
    [self resizeToolbar:@" " textView:self.chatInput maxLabelSize:maxsz];
}

-(void) textViewDidChange:(UITextView *)textView
{
    if ([textView respondsToSelector:@selector(textContainer)]) {
        //textView.textContainer.size = textView.frame.size;
    }
    
    if(![textView.text hasSuffix:@"\n"] && hasMaxToolbarSize && [IOS iosVersion] >= 7.) {
        int pos = (int)textView.selectedRange.location;
        int len = (int)textView.text.length;
        NSString *temp = [NSString stringWithFormat:@"%@\n", textView.text];
        textView.text = temp;
        NSRange selected = textView.selectedRange;
        if(pos == len) {
            selected.location -= 1;
            textView.selectedRange = selected;
        } else {
            selected.location = pos;
            textView.selectedRange = selected;
        }
    }
    
    NSRange range = textView.selectedRange;
    DLog(@"scrollRangeToVisible: %lu/%lu", (unsigned long)range.location, (unsigned long)range.length);
    [textView scrollRangeToVisible:range];
    
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
    
    int anz = (currentLength / smsLength) + 1;
    numChars.text = [NSString stringWithFormat:@"%d/%d", currentLength, smsLength];
    numSMS.text = [NSString stringWithFormat:@"%d SMS", anz];
    
}

-(void) resizeToolbar:(NSString *) newtext textView:(UITextView *)textView maxLabelSize:(CGSize) maximumLabelSize
{
    CGSize expectedTextSize = [newtext boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:textView.font} context:nil].size;
    expectedTextSize.width = ceilf(expectedTextSize.width);
    expectedTextSize.height = ceilf(expectedTextSize.height);
    
    //CGSize expectedTextSize = [newtext sizeWithFont:textView.font
    //                              constrainedToSize:maximumLabelSize];
    
    CGFloat sz = expectedTextSize.height;
    sz += 16;
    if ([newtext hasSuffix:@"\n"]) {
        //  sz += 16;
    }
    
    
    if (sz < maximumLabelSize.height) {
        textView.scrollEnabled = NO;
    } else {
        textView.scrollEnabled = YES;
    }
    
    
    int maxSZ = maximumLabelSize.height; // + resizeOffset;
    if (sz >= maxSZ) {
        sz = maxSZ;
        hasMaxToolbarSize = YES;
    } else {
        hasMaxToolbarSize = NO;
    }
    
    
    BOOL wasScrolling = textView.scrollEnabled;
    textView.scrollEnabled = NO;
    
    
    if (isSMS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect nf = numChars.frame;
            CGRect sf = submitButton.frame;
            if ((nf.origin.y + nf.size.height + 3) < sf.origin.y) {
                [numChars setHidden:NO];
            } else {
                [numChars setHidden:YES];
            }
            
            CGRect nsf = numSMS.frame;
            if ((nsf.origin.y + nsf.size.height + 3) < sf.origin.y) {
                [numSMS setHidden:NO];
            } else {
                [numSMS setHidden:YES];
            }
        });
    } else {
        [numChars setHidden:YES];
        [numSMS setHidden:YES];
    }
    
    textView.scrollEnabled = wasScrolling;
}

-(void) resetTextInput
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatInput.text = @" ";
        
        //[self.toolbarView resizeToolbar:minToolbarHeight];
        [self initialToolbarSize];
        [numChars setHidden:YES];
        [numSMS setHidden:YES];
        
        self.chatInput.scrollEnabled = NO;
        [self.chatInput.superview setNeedsLayout];
        [self.chatInput.superview layoutIfNeeded];
        self.chatInput.text = nil;
    });
}

#pragma mark Notification Handling

-(CGFloat) keyboardSize:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect appFrame = [UIApplication sharedApplication].keyWindow.frame;
    CGFloat w = appFrame.size.width;
    if (w > appFrame.size.height)
        w = appFrame.size.height;
    
    //BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = keyboardFrame.size.height;//isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    if (height == w) {
        height = keyboardFrame.size.width;
    }
    
    return height;
}

-(void) handleNotification:(NSNotification *) notification
{
    hasTabBar = !self.tabBarController.tabBar.isHidden;
    
    if ([[notification name] isEqualToString:@"UIKeyboardWillShowNotification"]) {
        CGFloat keyboardSize = [self keyboardSize:notification];
        
        
        CGRect frame = self.toolbarView.frame;
        
        CGFloat kbNewHeight = keyboardSize;
        CGFloat tabbarHeight = self.tabBarController.tabBar.bounds.size.height;
        
        if (self.tabBarController.tabBar.hidden) {
            tabbarHeight = 0.;
        }
        
        
        kbNewHeight -= tabbarHeight;
        
        CGFloat blgLength = self.bottomLayoutGuide.length;
        kbNewHeight -= blgLength;
        
        DLog(@"UIKeyboardWillShowNotification: %@ / %@ / %@", @(kbNewHeight), @(tabbarHeight), @(blgLength));
        
        self.toolbarBottomContraint.constant = kbNewHeight;
        [UIView animateWithDuration:0.3 animations:^{
            [self.toolbarView.superview layoutIfNeeded];
        }];

    }

    if ([[notification name] isEqualToString:@"UIKeyboardWillChangeFrameNotification"]) {
        /*
        CGFloat keyboardSize = [self keyboardSize:notification];
        
        
        CGRect frame = self.toolbarView.frame;
        
        CGFloat kbNewHeight = keyboardSize;
        CGFloat tabbarHeight = self.tabBarController.tabBar.bounds.size.height;
        
        kbNewHeight -= tabbarHeight;
        
        self.toolbarBottomContraint.constant = kbNewHeight;
        [UIView animateWithDuration:0.3 animations:^{
            [self.toolbarView.superview layoutIfNeeded];
        }];
        */
    }

    if ([[notification name] isEqualToString:@"UIKeyboardDidChangeFrameNotification"]) {
        NSLog(@"UIKeyboardDidChangeFrameNotification");
    }
    
    
    if ([[notification name] isEqualToString:@"UIKeyboardWillHideNotification"]) {
        isKeyboard = NO;
        
        
        self.toolbarBottomContraint.constant = 0;
        [UIView animateWithDuration:0.25 animations:^{
            [self.toolbarView.superview layoutIfNeeded];
        }];

    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardDidShowNotification"]) {
        if (isKeyboard)
            return;
        
        isKeyboard = YES;
    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardDidHideNotification"]) {
        currentKeyboardSize = 0;
    }
    
    if ([[notification name] isEqualToString:@"SIPHandler:TypingEvent"] && [[notification object] isEqualToString:self.targetUserid]) {
        [self handleTypingEvent:self.targetUserid];
    }
    
    if ([[notification name] isEqualToString:@"PriceInfoEvent"] && [[[notification userInfo] objectForKey:@"Number"] isEqualToString:self.targetUserid] && [[[notification userInfo] objectForKey:@"sms"] boolValue]) {
        DLog(@"Price : %@", [[notification userInfo] objectForKey:@"PriceString"]);
        NSString *smsPriceInfo = [[notification userInfo] objectForKey:@"PriceString"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSMSPriceInfo:smsPriceInfo];
        });
    }
    
}

-(void) updateSMSPriceInfo:(NSString *) priceInfo
{
    self.smsCosts.text = priceInfo;
}

-(void) handleTypingEvent:(NSString *) fromUserid
{
    if ([fromUserid isEqualToString:self.targetUserid]) {
        lastTypeEventReceived = CFAbsoluteTimeGetCurrent();
        self.navigationItem.prompt = NSLocalizedString(@"is typing...", "TypingEvent Title");
        double delayInSeconds = 2.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (CFAbsoluteTimeGetCurrent() - lastTypeEventReceived > 2.4) {
                self.navigationItem.prompt = nil;
            }
        });
    }
}

#pragma mark Segue Handling

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"SCBoard20ControllerSegue"] || [segue.destinationViewController isKindOfClass:[SCBoard20Controller class]]) {
        UIViewController *vc = segue.destinationViewController;
        SCBoard20Controller *smc = nil;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            smc = (SCBoard20Controller *)((UINavigationController *)vc).topViewController;
        }
        
        if ([vc isKindOfClass:[SCBoard20Controller class]]) {
            smc = (SCBoard20Controller *)vc;
        }
        smc.targetUserid = targetUserid;
        smc.dontShowCallEvents = self.dontShowCallEvents;
        smc.delegate = self;
        
        if ([[C2CallPhone currentPhone] isGroupUser:targetUserid]) {
            smc.useNameHeader = YES;
            smc.useSenderImage = YES;
        }
    }
}


#pragma mark Rich Message

-(IBAction)selectRichMessage:(id)sender
{
    if ([self.chatInput isFirstResponder]) {
        [self.chatInput resignFirstResponder];
    }
    
    
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [cv addChoiceWithName:NSLocalizedString(@"Choose Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Select from Camera Roll", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_image"] andCompletion:^{
            
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
            [cv addChoiceWithName:NSLocalizedString(@"Take Photo or Video", @"Choice Title") andSubTitle:NSLocalizedString(@"Use Camera", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_cam-24x24"] andCompletion:^{
                
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
    
        [cv addChoiceWithName:NSLocalizedString(@"Submit Document", @"Choice Title") andSubTitle:NSLocalizedString(@"Send a Document", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_geolocation-24x24"] andCompletion:^{
            [self showDocumentPicker:nil];
            
        }];

    
    if ([CLLocationManager locationServicesEnabled]) {
        [cv addChoiceWithName:NSLocalizedString(@"Submit Location", @"Choice Title") andSubTitle:NSLocalizedString(@"Submit your current location", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_geolocation-24x24"] andCompletion:^{
            
            [self requestLocation:^(NSString *key) {
                DLog(@"submitLocation: %@ / %@", key, self.targetUserid);
                [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
            }];
        }];
        
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([AVAudioSession sharedInstance].inputAvailable) {
            [cv addChoiceWithName:NSLocalizedString(@"Submit Voice Mail", @"Choice Title") andSubTitle:NSLocalizedString(@"Record a voice message", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_mic"] andCompletion:^{
                
                [self recordVoiceMail:^(NSString *key) {
                    DLog(@"submitVoiceMail: %@ / %@", key, self.targetUserid);
                    [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
                }];
            }];
        }
    }
    
    /*
     if (!isSMS) {
     [cv addChoiceWithName:NSLocalizedString(@"Share Friends", @"Choice Title") andSubTitle:NSLocalizedString(@"Share one or more friends", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_share_friend"] andCompletion:^{
     // TODO - SCChatController - ShareFriends
     //[self shareFriends:numberOrUserid];
     }];
     }
     */
    
    if ([IOS iosVersion] >= 5.0) {
        [cv addChoiceWithName:NSLocalizedString(@"Send Contact", @"Choice Title") andSubTitle:NSLocalizedString(@"Send a contact from address book", @"Button") andIcon:[[SCAssetManager instance] imageForName:@"ico_apple_mail"] andCompletion:^{
            [self showPicker:nil];
        }];
    }
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Choice Title") andCompletion:^{
    }];
    
    [cv showMenu];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Get the selected image.
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        
        DLog(@"mediaUrl : %@", [mediaUrl absoluteString]);
        
        @autoreleasepool {
            SCWaitIndicatorController *pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Exporting Video...", @"Title") andWaitMessage:nil];
            pleaseWait.autoHide = NO;
            [pleaseWait show:[[UIApplication sharedApplication] keyWindow]];
            
            [[C2CallPhone currentPhone] submitVideo:mediaUrl withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
                [pleaseWait hide];
                [picker dismissViewControllerAnimated:YES completion:NULL];
                
            }];
        }
    } else {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        SCWaitIndicatorController *pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Exporting Image...", @"Title") andWaitMessage:nil];
        [pleaseWait show:[[UIApplication sharedApplication] keyWindow]];
        
        [[C2CallPhone currentPhone] submitImage:originalImage withQuality:UIImagePickerControllerQualityTypeMedium andMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
            [pleaseWait hide];
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark SCBoard20ControllerDelegate

-(void) presentReplyToForEventId:(NSString *)eventId
{
}

-(IBAction) clearReplyTo:(id)sender
{
}


#pragma mark people picker

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    if ([IOS iosVersion] < 9.0) {
        [[C2CallPhone currentPhone] submitVCard:person withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
            
        }];
    }
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    if ([IOS iosVersion] >= 9.0) {
        [[C2CallPhone currentPhone] submitVCard:person withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
            
        }];
    }
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

#pragma mark Actions

-(IBAction)toggleSecureMessageButton:(id)sender
{
    self.encryptMessageButton.selected = !self.encryptMessageButton.selected;
}

-(void) refreshSecureMessageButton
{
    NSString *targetContact = self.targetUserid;
    if (isSMS) {
        self.encryptMessageButton.hidden = YES;
        self.encryptMessageButton.selected = NO;
        self.encryptMessageButton.enabled = NO;
        return;
    }
    
    //if ([[C2CallPhone currentPhone] canEncryptMessageForTarget:targetContact]) {
    //    self.encryptMessageButton.selected = [C2CallPhone currentPhone].preferMessageEncryption;
    //    self.encryptMessageButton.hidden = NO;
    //    self.encryptMessageButton.enabled = YES;
    //} else {
        self.encryptMessageButton.selected = NO;
        self.encryptMessageButton.hidden = YES;
        self.encryptMessageButton.enabled = NO;
    //}
}

- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark UIDocumentPickerViewController Delegate

-(IBAction)showDocumentPicker:(id)sender
{
    NSArray *types = @[(NSString*)kUTTypeImage,(NSString*)kUTTypeSpreadsheet,(NSString*)kUTTypePresentation,(NSString*)kUTTypePDF,(NSString*)kUTTypeRTF,(NSString*)kUTTypePlainText,(NSString*)kUTTypeText];
    
    
    UIDocumentPickerViewController *dpvc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    
    dpvc.delegate = self;
    
    [self presentViewController:dpvc animated:YES completion:^{
        
    }];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    __block NSInteger count = [urls count];

    if (count == 1) {
        [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:@"Sending File..." andWaitMessage:nil];
    } else {
        [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:@"Sending Files..." andWaitMessage:nil];
    }
    
    for (NSURL *url in urls) {
        [[C2CallPhone currentPhone] submitFile:url withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error) {
           
            count--;

            if (count <= 0) {
                [[C2CallAppDelegate appDelegate] waitIndicatorStop];
                
                [controller dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }

        }];
    }
    
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:@"Sending File..." andWaitMessage:nil];

    [[C2CallPhone currentPhone] submitFile:url withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString * _Nullable richMediaKey, NSError * _Nullable error) {
        
        [[C2CallAppDelegate appDelegate] waitIndicatorStop];
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }];

}


-(IBAction) submit:(id) sender;
{
    NSString *text = [chatInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (isSMS) {
        [[SCUserProfile currentUser] refreshUserCredits];
    }
    
    if (!text || [text length] == 0) {
        [AlertUtil showPleaseEnterText];
        return;
    }
    
    [self resetTextInput];
    [[SIPPhone currentPhone] submitMessage:text toUser:self.targetUserid preferEncryption:self.encryptMessageButton.selected];
}

-(IBAction)hideKeyboard:(id)sender
{
    if ([self.chatInput isFirstResponder]) {
        [self.chatInput resignFirstResponder];
    }
}

-(IBAction) close:(id) sender
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc)
        [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

