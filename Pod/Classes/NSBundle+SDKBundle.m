//
//  NSBundle+SDKBundle.m
//  C2CallPhone
//
//  Created by Michael Knecht on 26/11/15.
//
//

#import "NSBundle+SDKBundle.h"

@implementation NSBundle (SDKBundle)

+(instancetype) sdkBundle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Frameworks/SocialCommunication.framework/SocialCommunication" ofType:@"bundle"];
    if (path) {
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        return bundle;
    }

    return [NSBundle mainBundle];
}

@end
