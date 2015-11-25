//
//  SCPersonController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 18.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <AddressBookUI/AddressBookUI.h>
@class DDXMLElement;

/** Subclass of ABPersonViewController with C2Call specific functionality 
 
 The SCPersonController shows a VCARD contact received via Rich Media Message.
 
 Please use showContact: from UIViewController+SCCustomViewController.h to present this controller programmatically.

 */
@interface SCPersonController : ABPersonViewController<UIActionSheetDelegate>


/** @name Properties */
/** VCARD as String. */
@property(nonatomic, strong) NSString *vcard;

/** Rich Media Key for VCARD. */
@property(nonatomic, strong) NSString *vcardKey;

/** Flag - Show Toolbar. */
@property(nonatomic, assign) BOOL showToolbar;

/** @name Other Methods */
/** Opens SCChatController for the given phone number.
 
 @param number - Phone number in international format
 */
-(void) openMessageForNumber:(NSString *) number;

/** Forwards Contact Action.
 */
-(void) forwardContact;

/** @name Actions */
/** Shows the Content Action PopupMenu.
 
 Default Implementation:
 
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Save Contact", @"MenuItem") andSubTitle:NSLocalizedString(@"Save to Contacts", @"Button") andIcon:[UIImage imageNamed:@"ico_save_in_contacts"] andCompletion:^{
        
        CFErrorRef error = NULL;
        ABAddressBookAddRecord(self.addressBook, self.displayedPerson, &error);
        
        if (error == NULL) {
            ABAddressBookSave(self.addressBook, &error);
            [AlertUtil showContactSaved];
        } else {
            [AlertUtil showContactSavedError];
        }
        
    }];
    
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"MenuItem") andSubTitle:NSLocalizedString(@"Forward to another user", @"Button") andIcon:[UIImage imageNamed:@"ico_forward"] andCompletion:^{
        [self forwardContact];
    }];
 
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        
    }];
    
    [cv showMenu];
 
 @param sender - The initiator of the action
 */
-(IBAction)contentAction:(id)sender;

@end
