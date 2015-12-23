#import <UIKit/UIKit.h>

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
#import "C2BlockAction.h"
#import "C2CallAppDelegate.h"
#import "C2CallConstants.h"
#import "C2CallHandler.h"
#import "C2CallPhone.h"
#import "C2ExpandViewController.h"
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
#import "CustomEventsBannerView.h"
#import "DateUtil.h"
#import "DDXML.h"
#import "DDXMLDocument.h"
#import "DDXMLElement.h"
#import "DDXMLElementAdditions.h"
#import "DDXMLNode.h"
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
#import "FlurryEventProtocol.h"
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
#import "MOAddress.h"
#import "MOC2CallEvent.h"
#import "MOC2CallGroup.h"
#import "MOC2CallUser.h"
#import "MOCallHistory.h"
#import "MOChatHistory.h"
#import "MODidNumber.h"
#import "MOGroupMember.h"
#import "MOOpenId.h"
#import "MOPhoneNumber.h"
#import "MOUserData.h"
#import "NSBundle+SDKBundle.h"
#import "R1AdList.h"
#import "RadiumOneBannerView.h"
#import "RingtoneHandler.h"
#import "RTPVideoHandler.h"
#import "SCAbstractRegistrationController.h"
#import "SCAddGroupController.h"
#import "SCAddressBookCell.h"
#import "SCAddressBookController.h"
#import "SCAdListCell.h"
#import "SCAdTableViewController.h"
#import "SCAdViewContainer.h"
#import "SCAffiliateInfo.h"
#import "SCAssetManager.h"
#import "SCAudioPlayerController.h"
#import "SCAudioRecorderController.h"
#import "SCBoardController.h"
#import "SCBrowserViewController.h"
#import "SCBubbleViewIn.h"
#import "SCBubbleViewOut.h"
#import "SCCallStatusController.h"
#import "SCChatController.h"
#import "SCComposeMessageController.h"
#import "SCContactDetailController.h"
#import "SCCountrySelectionController.h"
#import "SCDataManager.h"
#import "SCDataTableViewController.h"
#import "SCDialButton.h"
#import "SCDialPadController.h"
#import "SCDIDManager.h"
#import "SCEditStatusController.h"
#import "SCFindFriendController.h"
#import "SCFlexibleToolbarView.h"
#import "SCFriendDetailController.h"
#import "SCFriendList.h"
#import "SCFriendListCell.h"
#import "SCFriendListController.h"
#import "SCGroup.h"
#import "SCGroupAddMembersCell.h"
#import "SCGroupDetailController.h"
#import "SCGroupDetailHeaderController.h"
#import "SCGroupMemberCell.h"
#import "SCGroupNameCell.h"
#import "SCGroupVideoCallController.h"
#import "SCHangoutBubbleViewIn.h"
#import "SCHangoutBubbleViewOut.h"
#import "SCHorizontalLineView.h"
#import "SCInboundCallController.h"
#import "SCKeypadController.h"
#import "SCLaunchScreenController.h"
#import "SCLocationSubmitController.h"
#import "SCLocationViewerController.h"
#import "SCLoginController.h"
#import "SCMediaManager.h"
#import "SCNumberPINController.h"
#import "SCOfferwallController.h"
#import "SCPasswordMailController.h"
#import "SCPersonController.h"
#import "SCPhotoViewerController.h"
#import "SCPopupMenu.h"
#import "SCPopupTableController.h"
#import "SCPreventAPIWarnings.h"
#import "SCPromptController.h"
#import "SCPurchaseController.h"
#import "SCPushHandler.h"
#import "SCQRCertExportController.h"
#import "SCQRCertImportController.h"
#import "ScreenControls.h"
#import "SCRegistrationController.h"
#import "SCStoreObserver.h"
#import "SCTextField.h"
#import "SCUserImageController.h"
#import "SCUserProfile.h"
#import "SCUserProfileController.h"
#import "SCUserSelectionController.h"
#import "SCUserStatusController.h"
#import "SCVerifyNumberController.h"
#import "SCVideoCallController.h"
#import "SCVideoPlayerController.h"
#import "SCWaitIndicatorController.h"
#import "SearchTableController.h"
#import "SIPConstants.h"
#import "SIPPhone.h"
#import "SIPPhoneConstants.h"
#import "SIPUtil.h"
#import "SocialCommunication.h"
#import "SponsorPayAdList.h"
#import "SponsorPayBannerView.h"
#import "TrialpayAdList.h"
#import "TrialpayBannerView.h"
#import "UDConnectionCell.h"
#import "UDPhoneCell.h"
#import "UDUserInfoCell.h"
#import "UIViewController+AdSpace.h"
#import "UIViewController+SCCustomViewController.h"
#import "UserInfoProtocol.h"
#import "VideoCellIn.h"
#import "VideoCellInStream.h"
#import "VideoCellOut.h"
#import "VideoCellOutStream.h"
#import "VideoFrame.h"
#import "VideoHandler.h"
#import "W3IAdList.h"
#import "WaitIndicatorProtocol.h"

FOUNDATION_EXPORT double SocialCommunicationVersionNumber;
FOUNDATION_EXPORT const unsigned char SocialCommunicationVersionString[];

