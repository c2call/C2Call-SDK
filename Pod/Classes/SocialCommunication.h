//
//  SocialCommunication.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.02.13.
//
//

#ifndef C2CallPhone_SocialCommunication_h
#define C2CallPhone_SocialCommunication_h

#import <UIKit/UIKit.h>

#import "C2CallAppDelegate.h"

#import "C2CallPhone.h"
#import "SIPPhone.h"

// Base Classes
#import "SCUserProfile.h"
#import "SCMediaManager.h"
#import "SCFriendList.h"
#import "SCGroup.h"

// Custom Controls
#import "SCFlexibleToolbarView.h"
#import "SCDialButton.h"
#import "SCTextField.h"
#import "SCBubbleViewIn.h"
#import "SCBubbleViewOut.h"

// C2Call SDK View Controller Components
//
// User Profile
#import "SCUserProfileController.h"
#import "SCUserStatusController.h"
#import "SCEditStatusController.h"

// Verify Number
#import "SCVerifyNumberController.h"
#import "SCNumberPINController.h"

// Login / Register
#import "SCRegistrationController.h"
#import "SCCountrySelectionController.h"
#import "SCLoginController.h"
#import "SCLaunchScreenController.h"

// Rich Media
#import "SCPhotoViewerController.h"
#import "SCVideoPlayerController.h"
#import "SCAudioPlayerController.h"
#import "SCLocationViewerController.h"
#import "SCBrowserViewController.h"
#import "SCLocationSubmitController.h"
#import "SCAudioRecorderController.h"

// Popup Menu
#import "SCPopupMenu.h"
#import "SCPopupTableController.h"

// Helper Controller
#import "SCWaitIndicatorController.h"
#import "SCPromptController.h"

// Friends / Friendlist
#import "SCFriendListController.h"
#import "SCFriendListCell.h"
#import "SCFriendDetailController.h"
#import "SCFindFriendController.h"
#import "SCUserImageController.h"

// Groups
#import "SCAddGroupController.h"
#import "SCGroupNameCell.h"
#import "SCGroupAddMembersCell.h"
#import "SCUserSelectionController.h"
#import "SCGroupMemberCell.h"
#import "SCGroupDetailController.h"
#import "SCGroupDetailHeaderController.h"

// Board
#import "SCChatController.h"
#import "SCBoardController.h"
#import "SCComposeMessageController.h"

// Addressbook
#import "SCAddressBookController.h"
#import "SCAddressBookCell.h"
#import "SCPersonController.h"
#import "SCContactDetailController.h"

// Offerwall
#import "SCOfferwallController.h"
#import "SCAdListCell.h"

// Dial Pad
#import "SCDialPadController.h"

// Call Handling
#import "SCCallStatusController.h"
#import "SCInboundCallController.h"
#import "SCVideoCallController.h"
#import "SCGroupVideoCallController.h"

// In-App Purchase
#import "SCPurchaseController.h"
#import "SCStoreObserver.h"

// Password Handling
#import "SCPasswordMailController.h"

// XML Handling
#import "DDXML.h"

// Database Managed Objects
#import "MOC2CallUser.h"
#import "MOCallHistory.h"
#import "MOChatHistory.h"
#import "MOC2CallGroup.h"
#import "MOGroupMember.h"
#import "MOPhoneNumber.h"
#import "MOAddress.h"
#import "MOC2CallEvent.h"
#import "MOOpenId.h"

// Data Management
#import "SCDataManager.h"
#import "SCDataTableViewController.h"


#endif
