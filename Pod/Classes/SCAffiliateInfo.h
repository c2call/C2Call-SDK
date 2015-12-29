//
//  SCAffiliateInfo.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.06.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <Foundation/Foundation.h>

/** Affiliate Application Record
 
 Provides Read Only access to the relevant Application Parameters
 */
@interface SCAffiliateApp : NSObject

/** @name Properties */
/** Application Identifier (Bundle Id) */
@property(nonatomic, readonly) NSString *appIdentifier;

/** Application Title */
@property(nonatomic, readonly) NSString *appTitle;

/** Application Release Status */
@property(nonatomic, readonly) NSString *appMode;

/** Application AppStore Url */
@property(nonatomic, readonly) NSString *appUrl;

/** Application Usage NSSet of NSNumber of SCApplicationUse */
@property(nonatomic, readonly) NSSet *appUse;

/** List of AdNetworks registered */
@property(nonatomic, readonly) NSDictionary *adNetworks;

/** Definition for AdSpaces (SCAdSpace)*/
@property(nonatomic, readonly) NSDictionary *adSpaces;

/** User Visibility */
@property(nonatomic, readonly) NSString *userVisibility;

@end


/** Single AdSpace definition
 
 */
@interface SCAdSpace : NSObject

/** @name Properties */
/** AdSpace Name */
@property(nonatomic, readonly) NSString *name;

/** AdSpace Type (Banner Top, Banner Bottom, Interstitial */
@property(nonatomic, readonly) NSString *type;

/** AdSpace Handler */
@property(nonatomic, readonly) NSString *handler;

/** AdSpace RefreshRate 
 
 For Banner AdSpaces only. Refresh Interval for Ads.
 
 */
@property(nonatomic, readonly) int refreshRate;

/** AdSpace EventRate 

 For Interstitial AdSpaces only. 
 The Event Rate means, show the Interstitial on every number of presenting Events.

 For example: The value 3 on the SCCallInterstitialAdSpace means, show the interstitial on every 3rd call.
 
 */
@property(nonatomic, readonly) int eventRate;

/** AdSpace ShowOnFirstEvent 
 
 For Interstitial AdSpaces only.
 Show the interstitial on the first event and then start the EventRate counting.
 
 */
@property(nonatomic, readonly) BOOL showOnFirstEvent;

/** AdSpace ShowAdSpace 
 
 Show this AdSpace.
 */
@property(nonatomic, readonly) BOOL showAdSpace;


/** Is Interstitial AdSpace
 */
@property(nonatomic, readonly) BOOL isInterstitial;

/** AdSpace should request an interstitial from AdNetwork
 
 Calculates the interstitial request based on EventRate and showOnFirstEvent setting.
 
 @return YES - request interstitial / NO - do not request interstitial from AdNetwork
 */
-(BOOL) shouldRequestInterstitial;

/** Tell the AdSpace that the interstitial did show
 */
-(void) interstitialDidShow;

/** Tell the AdSpace that the interstitial didn't show
 */
-(void) interstitialDidFailToReceiveAd;

@end

/** AdNetwork Definition
 
 Currently Supported Provider :
 
    - ADN_FLURRY
    - ADN_AARKI
    - ADN_SPONSORPAY
    - ADN_RADIUMONE
    - ADN_VUNGLE
    - ADN_TAPJOY

 */
@interface SCAdNetwork : NSObject

/** @name Properties */
/** AdNetwork Name */
@property(nonatomic, readonly) NSString *name;

/** AdNetwork Provider (ADN_FLURRY, etc.) */
@property(nonatomic, readonly) NSString *provider;

/** AdNetwork Application Id for this App 
 
 This is named differently with every provider, but all provide a kind of number or app identifier
 */
@property(nonatomic, readonly) NSString *applicationId;

/** AdNetwork Application Secret for this App
 
 Most AdNetworks provide an Application Secret to authorize the AdNetwork API Request
 */
@property(nonatomic, readonly) NSString *secret;


/** Any additional Parameters for this AdNetwork
 
 */
@property(nonatomic, readonly) NSDictionary *params;

@end


/** Affiliate Infomation Object
 
 This class requests the necessary affiliate information from the C2Call Server on application startup.
 
 */
@interface SCAffiliateInfo : NSObject

/** @name Properties */
/** Affiliate Name */
@property(nonatomic, readonly) NSString *affiliateName;

/** Affiliate Id */
@property(nonatomic, readonly) NSString *affiliateId;

/** Account Type 
 
    AT_FREE : Free Account
    AT_PRO  : Professional Account
    AT_ENTERPRISE : Enterprise Account
 */
@property(nonatomic, readonly) NSString *accountType;

/** Affiliate App */
@property(nonatomic, readonly) SCAffiliateApp     *affiliateApp;

/** @name Static Methods */
/** Get the current SCAffiliateInfo Instance
 
 If none exists, it'll be created.
 This is done by C2CallAppDelegate.
 
 */
+(SCAffiliateInfo *) instance;

@end
