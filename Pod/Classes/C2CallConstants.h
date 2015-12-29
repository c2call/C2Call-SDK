/*
 *  C2CallConstants.h
 *  C2CallPhone
 *
 *  Created by Michael Knecht on 17.01.09.
 *  Copyright 2009 Actai Networks GmbH. All rights reserved.
 *
 */

#define	DEFAULT_EMAIL				@"emailKey"
#define	DEFAULT_PASSWORD			@"passwordKey"
#define	DEFAULT_MYPHONENUMBER       @"myPhoneNumber"
#define	DEFAULT_NUMBERVERIFIED      @"numberVerified"
#define	DEFAULT_VERIFYNUMBERSEEN    @"verifyNumberSeen"
#define DEFAULT_VERIFYPIN           @"verifyPin"
#define DEFAULT_C2CALLAPIURL		@"c2callApiUrlKey"
#define DEFAULT_ADDCREDITURL		@"addCreditUrlKey"
#define DEFAULT_PROXYHOST			@"proxyHostKey"
#define DEFAULT_PROXYPORT			@"proxyPortKey"
#define DEFAULT_COUNTRYCODE			@"countryCode"
#define DEFAULT_AREACODE			@"areaCode"
#define DEFAULT_SHOWTESTCALL		@"showTestCall"
#define DEFAULT_SHOWCALLERID		@"showCallerId"
#define DEFAULT_HASCOUNTRY			@"hasCountry"
#define DEFAULT_ECHOTAPS			@"echoTaps"
#define DEFAULT_ECHOBUFFER			@"echoBuffer"
#define DEFAULT_NOTIFYIM			@"notifyInstantMessage"
#define DEFAULT_NOTIFYCALLME		@"notifyCallMe"
#define DEFAULT_NOTIFYMISSEDEVENTS	@"notifyMissedEvents"
#define DEFAULT_ENABLEAPNS			@"enablePushNotifications"
#define DEFAULT_LISTTYPE			@"listType"
#define DEFAULT_INFOSERVICE			@"infoServiceVersion"
#define DEFAULT_FBLOGIN				@"facebookLogin"
#define DEFAULT_FBTOKEN				@"FBAccessTokenKey"
#define DEFAULT_FBEXPIRE			@"FBExpirationDateKey"
#define DEFAULT_FBSEEN				@"facebookSeen"
#define DEFAULT_REGISTERSTATUS		@"registerStatus"
#define DEFAULT_RATEUS              @"rateUs"
#define DEFAULT_RATEUSDONE          @"rateUsDone"
#define DEFAULT_LIKEUS              @"likeUs"
#define DEFAULT_LIKEUSDONE          @"likeUsDone"
#define DEFAULT_SHOWWELCOMESCREEN	@"showWelcomeScreen"
#define DEFAULT_WELCOMESCREENSEEN	@"WelcomeScreenSeen"
#define DEFAULT_SECUREWELCOMESCREENSEEN	@"SecureWelcomeScreenSeen"
#define DEFAULT_GENERATEFRIENDLIST	@"GF"
#define DEFAULT_ADDRESSRECORDCOUNT  @"addressRecordCount"
#define DEFAULT_SORTBYFIRSTNAME         @"sortByFirstName"
#define DEFAULT_NAMEORDERBYFIRSTNAME    @"nameOrderByFirstName"
#define DEFAULT_USE_ENCRYPTION      @"useEncryption"
#define DEFAULT_ENCRYPT_MESSAGES    @"encryptMessages"



#define DEFAULT_NAVBARCOLOR [UIColor  colorWithRed:5./255. green:120./255. blue:174./255. alpha:1.0]
#ifdef __FCPRO
#define DEFAULT_NAVBARCOLOR7 [UIColor colorWithRed:(0x56/255.) green:(0xad/255.) blue:(0xed/ 255.) alpha:1.0]
#elif __FCHD
#define DEFAULT_NAVBARCOLOR7 [UIColor colorWithRed:62./255. green:130./255. blue:229./255. alpha:1.0]
#else
#define DEFAULT_NAVBARCOLOR7 [UIColor colorWithRed:(0x56/255.) green:(0xad/255.) blue:(0xed/ 255.) alpha:1.0]
#endif
#define DEFAULT_NAVBARBGCOLOR [UIColor  colorWithRed:33./255. green:100./255. blue:161./255. alpha:1.0]
//#define DEFAULT_NAVBARCOLOR [UIColor  colorWithRed:0x11/255. green:0x1e/255. blue:0x36/255. alpha:1.0]
//#define DEFAULT_NAVBARCOLOR [UIColor  whiteColor]

#define DEFAULT_TOOLBARCOLOR [UIColor  colorWithRed:0x11/255. green:0x1e/255. blue:0x36/255. alpha:1.0]
#define DEFAULT_TABBARCOLOR [UIColor  colorWithRed:0x11/255. green:0x1e/255. blue:0x36/255. alpha:1.0]

// 83 215 105
#define DEFAULT_GREENCOLOR [UIColor colorWithRed:(0x53/255.) green:(0xd7/255.) blue:(0x69/ 255.) alpha:1.0]

// 86 173 237
#define DEFAULT_IDLECOLOR [UIColor colorWithRed:(0x56/255.) green:(0xad/255.) blue:(0xed/ 255.) alpha:1.0]

// 252 62 57
#define DEFAULT_REDCOLOR [UIColor colorWithRed:(0xfc/255.) green:(0x3e/255.) blue:(0x39/ 255.) alpha:1.0]

// 253 148 38
#define DEFAULT_ORANGECOLOR [UIColor colorWithRed:(0xfd/255.) green:(0x94/255.) blue:(0x26/ 255.) alpha:1.0]

// 86 173 237
#define DEFAULT_LIGHTBLUECOLOR [UIColor colorWithRed:(0x56/255.) green:(0xad/255.) blue:(0xed/ 255.) alpha:1.0]

// 34 133 231
#define DEFAULT_BLUECOLOR [UIColor colorWithRed:(0x22/255.) green:(0x85/255.) blue:(0xe7/ 255.) alpha:1.0]

// 21 118 214
#define DEFAULT_DARKBLUECOLOR [UIColor colorWithRed:(0x15/255.) green:(0x76/255.) blue:(0xd6/ 255.) alpha:1.0]

#ifdef __FCHD
#define C2CALL_RELEASE              17
#else
#define C2CALL_RELEASE              17
#endif
