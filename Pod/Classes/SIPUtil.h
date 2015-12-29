//
//  SIPUtil.h
//  C2CallPhone
//
//  Created by Michael Knecht on 03.01.09.
//  Copyright 2009 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SIPUtil : NSObject {

}

+(NSString*) md5:(NSString *) str;
+(NSString*) md5FromData:(NSData *) str;
+(NSString *) generateCallIdentifier:(NSString *) address; 
+(NSString *) generateBranch;
+(NSString *) generateTag;
+(NSString *) normalizePhoneNumber:(NSString *) number;
+(NSString*) sha1:(NSString*)input;
+(BOOL) isPhoneNumber:(NSString *) uid;

@end
