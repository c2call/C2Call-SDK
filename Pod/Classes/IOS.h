//
//  IOS.h
//  C2CallPhone
//
//  Created by Michael Knecht on 19.07.10.
//  Copyright 2011 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0 478.23
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

typedef enum {
    VIDEO_RES_NORMAL,
    VIDEO_RES_HIGH,
    VIDEO_RES_HD
} SCVideoResolutionT;

@interface IOS : NSObject {

}

+(int) applicationState;
+(float) iosVersion;
+(BOOL) hasVideo;
+(int) numberOfCameraDevices;
+(NSDictionary *) maxVideoResolutionReceive;
+(NSDictionary *) maxVideoResolutionSend;
+(int) maxVP8CPUUse;
+(NSString *) deviceName;
+(unsigned int) numberOfCores;
+(BOOL) has4inchScreen;
+(void) setClient:(NSString *) c;
+(NSString *) client;
+(NSString *) advIdentifier;
+(BOOL) advTrackingEnabled;
+(NSString *) uniqueIdentifier;
+(NSString *) getMacAddress;
+(NSString *) sha1MacAddress;
+(void) setVideoResolution:(SCVideoResolutionT) vRes;
+(void) setUseAds:(BOOL) useAds;

@end
