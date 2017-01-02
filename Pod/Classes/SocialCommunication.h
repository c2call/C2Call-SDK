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
//#import "DDXML.h"

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

// Broadcasts
#import "SCBroadcast.h"
#import "SCBroadcastController.h"
#import "SCMyBroadcastsController.h"
#import "SCBroadcastChatController.h"
#import "SCBroadcastVideoController.h"
#import "SCBroadcastRecordingController.h"
#import "SCBroadcastStartController.h"
#import "SCBroadcastStatusController.h"
#import "SCBroadcastInfoController.h"
#import "SCBroadcastsAroundMeController.h"
#import "SCBroadcastPlaybackController.h"

// Timeline
#import "SCTimeline.h"
#import "SCTimelineController.h"
#import "SCTimelineMasterController.h"


// other Headers
#import "AarkiBannerView.h"
#import "AdListProtocol.h"
#import "AdWhirlHandler.h"
#import "AlertUtil.h"
#import "AudioCellIn.h"
#import "AudioCellInStream.h"
#import "AudioCellOut.h"
#import "AudioCellOutStream.h"
#import "C2ActionButton.h"
#import "C2BarButtonItem.h"
#import "C2TapImageView.h"
#import "C2WaitMessage.h"
#import "CallCellIn.h"
#import "CallCellInStream.h"
#import "CallCellOut.h"
#import "CallCellOutStream.h"
#import "ContactCellIn.h"
#import "ContactCellInStream.h"
#import "ContactCellOut.h"
#import "ContactCellOutStream.h"
#import "Crypto.h"
#import "CustomEventsBannerView.h"
#import "DateUtil.h"
#import "debug.h"
#import "EAGLView.h"
#import "EAGLViewController.h"
#import "EditCell.h"
#import "FCLocation.h"
#import "FileCellIn.h"
#import "FileCellInStream.h"
#import "FileCellOut.h"
#import "FileCellOutStream.h"
#import "FlurryAdList.h"
#import "FlurryAppCircleBannerView.h"
#import "FlurryClipsBannerView.h"
#import "FlurryDownloadBannerView.h"
#import "FlurryReengageBannerView.h"
#import "FriendCellIn.h"
#import "FriendCellInStream.h"
#import "FriendCellOut.h"
#import "FriendCellOutStream.h"
#import "ImageCellIn.h"
#import "ImageCellInStream.h"
#import "ImageCellOut.h"
#import "ImageCellOutStream.h"
#import "ImageUtil.h"
#import "IOS.h"
#import "LocationCellIn.h"
#import "LocationCellInStream.h"
#import "LocationCellOut.h"
#import "LocationCellOutStream.h"
#import "MdotMAdList.h"
#import "MessageCell.h"
#import "MessageCellIn.h"
#import "MessageCellInStream.h"
#import "MessageCellOut.h"
#import "MessageCellOutStream.h"
#import "MODidNumber.h"
#import "MOUserData.h"
#import "NSBundle+SDKBundle.h"
#import "R1AdList.h"
#import "RadiumOneBannerView.h"
#import "RingtoneHandler.h"
#import "SCAdViewContainer.h"
#import "SCAffiliateInfo.h"
#import "SCAssetManager.h"
#import "SCDIDManager.h"
#import "SCHangoutBubbleViewIn.h"
#import "SCHangoutBubbleViewOut.h"
#import "SCHorizontalLineView.h"
#import "SCKeypadController.h"
#import "SCPreventAPIWarnings.h"
#import "SCPushHandler.h"
#import "SCQRCertExportController.h"
#import "SCQRCertImportController.h"
#import "ScreenControls.h"
#import "SearchTableController.h"
#import "SIPPhoneConstants.h"
#import "SIPUtil.h"
#import "SponsorPayAdList.h"
#import "SponsorPayBannerView.h"
#import "TrialpayAdList.h"
#import "TrialpayBannerView.h"
#import "UDConnectionCell.h"
#import "UDPhoneCell.h"
#import "UDUserInfoCell.h"
#import "UIViewController+AdSpace.h"
#import "UIViewController+SCCustomViewController.h"
#import "VideoCellIn.h"
#import "VideoCellInStream.h"
#import "VideoCellOut.h"
#import "VideoCellOutStream.h"
#import "W3IAdList.h"

#endif
