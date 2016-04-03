//
//  C2CallHandler.h
//  C2CallPhone
//
//  Created by Michael Knecht on 13.01.09.
//  Copyright 2009 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"
#import "WaitIndicatorProtocol.h"
#import "FlurryEventProtocol.h"
#import "UserInfoProtocol.h"

@protocol C2CallEventResult

-(void) eventResult:(NSString *) event result:(BOOL)success message:(NSString *) message;

@end

@class C2CallFacebook, C2CallConnection, SIPTimer, SIPRequest, C2CallDataManager, MOC2CallUser, SCAffiliateInfo;

@interface C2CallHandler : NSObject {
	NSString		*c2apiUrl;
	NSString		*email;
    NSString        *c2callUserid;
	NSString		*password;
	NSString		*sessionId;
    NSDictionary    *sessionInfo;
	CFAbsoluteTime	lastSessionRenew;
	SIPTimer			*renewTimer;
	int				sessionRetryCount, getUserRetryCount;

#ifndef __NOFACEBOOK
	C2CallFacebook  *facebook;
#endif    
	
	DDXMLElement	*c2user;
	DDXMLElement	*userCredits;
	NSString		*userCreditsString;
	NSString		*infoServiceVersion;
	NSString		*infoServiceUrl;
	NSString		*callMeLink;
    NSString        *ownNumber, *didNumber;
    NSDictionary    *didInfo;
    BOOL            ownNumberVerified;
	NSData			*deviceToken;
    NSSet           *generatedRelations;
    CFAbsoluteTime  generatedRelationsTime, updateFriendsTime;
    
	NSArray			*proxyList;
	NSArray			*unconfirmedInvites;
	NSArray			*callHistory;
	NSMutableArray	*messageHistory;

	NSMutableDictionary	*nameForUidMap;
	NSMutableDictionary *friendMap, *contactMap, *certificateMap;
	NSMutableDictionary *userPictures;
    NSMutableDictionary *priceCache;
	NSMutableDictionary *groupMap;
	
	BOOL			started, userPictureUpdateRunning;
	BOOL			initialization;
	BOOL			isLogin, isLoginEvent, loginFailed;
	BOOL			hasContacts, hasFriends, hasUserCredit;
	BOOL			hasInitialData, hasRegisteredForRemoteNotification;

	C2CallDataManager   *dataManager;
	
	C2CallConnection	*connectionSession;
	C2CallConnection	*connectionFriends;
	C2CallConnection	*connectionContacts;
	C2CallConnection	*connectionRelationEvents;
	C2CallConnection	*connectionUpdateRelationEvents;
	C2CallConnection	*connectionCallHistory;
	C2CallConnection	*connectionMessageHistory;
	C2CallConnection	*connectionUser;
	C2CallConnection	*connectionUserCredits;
	C2CallConnection	*connectionInvite;
	C2CallConnection	*connectionRegister;
	C2CallConnection	*connectionWriteContact;
	C2CallConnection	*connectionRemoveContact;
	C2CallConnection	*connectionCallInfo;
	C2CallConnection	*connectionPriceInfo;
	C2CallConnection	*connectionRenewSession;
	C2CallConnection	*connectionRegisterAPS;
	C2CallConnection	*connectionUnRegisterAPS;
	C2CallConnection	*connectionAddCredit;
	C2CallConnection	*connectionUpdateUserProfile;
	C2CallConnection	*connectionCallForward;
	C2CallConnection	*connectionChangePassword;
	C2CallConnection	*connectionUnconfirmedInvites;
	C2CallConnection	*connectionRemoveCallHistory;
	C2CallConnection	*connectionRemoveMsgHistory;
	C2CallConnection	*connectionRemoveChatHistory;
	C2CallConnection	*connectionGetCallMeLink;
	C2CallConnection	*connectionCommitAddresses;
	C2CallConnection	*connectionPasswordEMail;
	C2CallConnection	*connectionGetDIDInfo;
	C2CallConnection	*connectionCreateGroup;
	C2CallConnection	*connectionDeleteGroup;
	C2CallConnection	*connectionUpdateGroup;

    id<UserInfoDelegate, WaitIndicatorDelegate, FlurryEventsDelegate>      userInfoDelegate;
}

@property(strong) NSString			*sessionId, *c2apiUrl, *userCreditsString, *infoServiceVersion, *infoServiceUrl, *callMeLink, *c2callUserid, *email, *ownNumber, *didNumber, *loginToken, *loginSession;
@property(strong) DDXMLElement		*c2user, *userCredits;
@property(strong) NSArray			*callHistory, *proxyList, *unconfirmedInvites, *adNetworkInfo;
@property(strong) NSSet             *generatedRelations;
@property(strong) NSMutableArray	*messageHistory, *friendList, *contactList;
@property(strong) NSMutableSet      *c2newFriends;

@property(strong) SIPTimer			*renewTimer;
@property(strong) NSData			*deviceToken;
@property(strong) NSMutableDictionary *friendMap, *userPictures, *priceCache, *groupMap, *contactMap;
@property(nonatomic, weak) SCAffiliateInfo  *affiliateInfo;
@property(nonatomic, strong) NSDictionary   *sessionInfo, *didInfo;
@property(nonatomic) BOOL           ownNumberVerified, callMeLinkActive;
@property(nonatomic, strong) C2CallDataManager      *dataManager;
@property(nonatomic, assign) int    currentRelease;
@property(nonatomic) BOOL processingFacebookLogin, useVoIPPush;

// AWS Temorary Token
@property(nonatomic, strong) NSString   *accessKey, *secretKey, *securityToken, *expireDate;

#ifndef __NOFACEBOOK
@property(strong) C2CallFacebook	*facebook;
#endif

@property(nonatomic, strong)        id<UserInfoDelegate, WaitIndicatorDelegate, FlurryEventsDelegate>      userInfoDelegate;
@property BOOL						isLogin, loginFailed, hasUserCredit, started;

-(id) initWithUrl:(NSString *) url;
-(NSString *) nameForUserid:(NSString *) userid;
-(BOOL) addPhoneNumber:(NSString *) numberType forContact:(NSString *) contactEmail;
-(void) createSessionForUser:(NSString *) email withPassword:(NSString *) password;
-(void) createSessionForUserWithToken:(NSString *) token;
-(void) createFBSession;
-(void) refreshFriends;
-(void) refreshContacts;
-(void) refreshCallHistory;
-(void) refreshMessageHistory;
-(void) refreshGroupHistory:(NSString *) groupid forDays:(int) days;
-(void) refreshUser;
-(void) refreshUserCredits;
-(void) refreshUnconfirmedInvites;
-(void) refreshCallMeLink;
-(BOOL) activateCallMeLink:(BOOL) active;
-(BOOL) retrieveInitialUserData;
-(DDXMLElement *) objectForUserid:(NSString *) userid;
-(NSString *) useridForEMail:(NSString *) email;
-(void) inviteUser:(NSString *)emailAddress firstName:(NSString *)firstName lastName:(NSString *)lastName text:(NSString *) text;
-(BOOL) inviteUserSynchronized:(NSString *)emailAddress firstName:(NSString *)firstName lastName:(NSString *)lastName text:(NSString *) text;
-(void) writeContact:(DDXMLElement *)contact;
-(BOOL) writeContactSynchronously:(DDXMLElement *)contact;
-(void) updateContactForUser:(MOC2CallUser *) user;
-(DDXMLDocument *) registerUser:(NSDictionary *)userInfo eventSource:(id) source;
-(void) removeFriend:(DDXMLElement *)_friend;
-(void) removeFriendForUserid:(NSString *)_friend;
-(void) confirmFriends:(NSArray *)friends;
-(void) removeContact:(DDXMLElement *)contact;
-(void) removeCallHistory:(NSArray *)callidList;
-(void) removeMsgHistory:(NSArray *)msgidList;
-(void) removeChatHistory:(NSString *)friendid;
-(void) callInfo:(NSMutableDictionary *)p;
-(void) getPriceForNumber:(NSString *) number;
-(NSDictionary *) getUserCredits:(BOOL) forceRefresh;
-(NSDictionary *) getApplicationCredits;
-(BOOL) redeemVoucher:(NSString *) voucher withContentType:(NSString *) ctype;
-(BOOL) chargeApplicationCredit:(double) value forTransactionId:(NSString *) tid;
-(DDXMLDocument *) getAffiliateInfo;
-(void) startC2CallHandler;
-(void) stopC2CallHandler;
-(void) dispose;
-(void) willResignActive;
-(void) didEnterBackground;
-(void) didBecomeActive;
-(void) willTerminate;
-(void) willEnterForeground;
-(void) registerAPS:(NSData *)token;
-(void) registerAPS:(NSData *)token isVoIP:(BOOL) voip;
-(void) unregisterAPS;
-(void) callMePush:(NSString *) userid;
-(BOOL) addCredit:(NSString *)value currency:(NSString *) currency transactionid:(NSString *) tid receipt:(NSData *) receipt;
-(BOOL) addCredit:(NSString *)value currency:(NSString *) currency transactionid:(NSString *) tid receipt:(NSData *) receipt useSandbox:(BOOL) sandbox;
-(void) updateUserProfile:(DDXMLElement *)user;
-(BOOL) updateUserProfileWithSynchronousRequest:(DDXMLElement *)user;
-(void) callForward:(NSString *) type number:(NSString *) number;
-(void) changePassword:(NSString *) password;
-(void) setPassword:(NSString *) password data:(NSData *) data;
-(void) startC2CallHandlerInBackground;
-(void) facebookLogin:(id) data;
-(void) reconnectWithFacebook;
-(void) logout;
-(void) commitAddresses:(DDXMLElement *)addresses;
-(void) submitPasswordEMail:(NSString *) emailAddress;
-(void) submitNumberVerification:(NSString *) phoneNumber forcePINCall:(BOOL) force;
-(void) refreshRelationEvents;
-(void) notifyPriceInfo:(NSData *) data forNumber:(NSString *) number isSMS:(BOOL) isSMS;
-(BOOL) queryPriceForNumber:(NSString *) number;
-(BOOL) queryPriceForNumber:(NSString *) number isSMS:(BOOL) isSMS;
-(BOOL) checkFriendForEMail:(NSString *) emailAddress;
-(BOOL) checkFriendForUserid:(NSString *) userid;
-(BOOL) rewardUserForValue:(NSNumber *)value andProvider:(NSString *) provider;
-(int) creditValue;
-(NSString*) creditCurrency;
-(BOOL) hasCredit:(int) minCredit;
-(void) updateDIDInfo:(NSData *) data;
-(void) refreshDIDInfo;
-(DDXMLElement *) createFriendCallerGroup:(NSString *) groupName withFriends:(NSArray *) groupMember;
-(DDXMLElement *) createFriendCallerGroupWithSynchonousRequest:(NSString *) groupName withFriends:(NSArray *) groupMember;
-(BOOL) deleteFriendCallerGroup:(NSString *) groupid;
-(BOOL) updateFriendCallerGroup:(DDXMLElement *)group;
-(BOOL) joinFriendCallerGroup:(NSString *)groupid;
-(DDXMLElement *) getFriendCallerGroup:(NSString *)groupid;
-(void) handleGroupCallEvent:(SIPRequest *) request;
-(BOOL) isGroupUser:(NSString *) userid;
-(BOOL) removeMsg:(NSString *) msgid;
-(BOOL) recallMessge:(NSString *) msgid remoteUser:(NSString *) remoteUser;
-(NSString *) messageUrlForKey:(NSString *) key;
-(void) addUserPicture:(UIImage *)pic forUserid:(NSString *) userid;
-(UIImage *) userPictureForUserid:(NSString *) userid;
-(BOOL) deleteMOC2CallUser:(MOC2CallUser *)userObject;
-(void) renewSession;
-(BOOL) updateUserProfileWithUserImage:(NSString *) key;
-(BOOL) hasUserimageKeyForUserid:(NSString *) userid;
-(NSString *) userimageKeyForUserid:(NSString *) userid;
-(BOOL) writeOfferXML:(NSString *)xmlString;
-(DDXMLDocument *) getOfferXML;
-(DDXMLDocument *) getAppRecommendation;
-(DDXMLElement *) getUserInfoForUserid:(NSString *) userid;
-(BOOL) numberVerificationForRegister:(NSString *) number withPinMessage:(NSString *) pinMessage forcePinCall:(BOOL) force;
-(NSDictionary *) createGroupLinkForGroup:(NSString *) groupid;
-(NSDate *) getLastOnlineStatusForUser:(NSString *) userid;
-(NSString *) requestBTClientToken;
-(NSDictionary *) addBrainTreeCredit:(NSString *)value currency:(NSString *)currency nonce:(NSString *) nonce channel:(NSString *) channel;
-(BOOL) existingUser:(NSString *) email;
-(NSString *) userForCallerid:(NSString *) callerid;

-(DDXMLDocument *) didInfo:(int) didnum;
-(DDXMLDocument *) didTarifInfo;
-(NSString *) didReserveNumber:(NSString *) countryCode areacode:(NSString *) areaCode;
-(int) didReorderNumber:(int) didnum;
-(BOOL) didCancelNumber:(int) didnum;
-(int) didExtendNumber:(int) didnum withCountry:(NSString *) country pricemodel:(NSString *) priceModel receipt:(NSString *)receipt transactionId:(NSString *) tid useSandbox:(BOOL) sandbox;
-(int) didOrderReservedNumber:(int) didnum withCountry:(NSString *) country number:(NSString *) number pricemodel:(NSString *) priceModel receipt:(NSString *)receipt transactionId:(NSString *) tid useSandbox:(BOOL) sandbox;
-(int) didOrderNumber:(int) didnum withCountry:(NSString *) country areacode:(NSString *)areacode pricemodel:(NSString *) priceModel receipt:(NSString *)receipt transactionId:(NSString *) tid useSandbox:(BOOL) sandbox;
-(NSString *) getSmartDialNumber:(NSString *) country number:(NSString *) number description:(NSString *) description;
-(NSString *) requestWebCallbackForNumber:(NSString *) number1 number2:(NSString *) number2;
-(BOOL) cancelWebCallback:(NSString *) callbackId;
-(NSArray *) getCountriesForAccessNumbers;
-(NSDictionary *) getTollfreeAccessNumbers;
-(void) refreshLoginCredentials;
-(NSArray *) getCallingPlans;

+(C2CallHandler *) defaultHandler;

@end
