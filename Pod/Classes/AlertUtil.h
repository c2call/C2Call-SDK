//
//  AlertUtil.h
//  C2CallPhone
//
//  Created by Michael Knecht on 22.04.09.
//  Copyright 2009 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertUtil : NSObject {

}

+(void) showNoInternet;
+(void) showServerNotReachable;
+(void) showSIPConnection3GFailed;
+(void) showSIPConnectionWifiFailed;
+(void) showOfflineAlert;
+(void) show3GAlert;
+(void) showInvalidLogin;
+(void) showShowCreditInfo;
+(void) showShowCreditInfo2;
+(void) showShowCreditInfo3;
+(void) showRemoveTestcallInfo;
+(void) showRemoveMyCallLink;
+(void) showPleaseEnterName;
+(void) showPurchaseError;
+(void) showPurchaseOk;
+(void) showPasswordChangeFailed;
+(void) showPasswordChangeSuccess;
+(void) showCallForwardFailed;
+(void) showCallForwardSuccess;
+(void) showUpdateUserProfileFailed;
+(void) showUpdateUserProfileSuccess;
+(void) showPleaseEnterText;
+(void) showAudioError;
+(void) showEncoderError;
+(void) showInviteUserInfo;
+(void) showTakeCallFailed;
+(void) showMissingMicrophone;
+(void) showFacebookRegister;
+(void) showFacebookConnectFailed;
+(void) showFacebookMergeFailed;
+(void) showInvalidNumberOrContact;
+(void) showNoVideoOffersAvailable;
+(void) showSMSInvitationSent;
+(void) showSMSTimeoutRegister;
+(void) showContactSaved;
+(void) showContactSavedError;
+(void) showRequestFailed;
+(void) showCertificateMismatchForAccount;
+(void) showCertificateTransferForAccount;
+(void) showCertificateExport:(NSString *) password;
+(void) showAPICallNotAllowed;

@end
