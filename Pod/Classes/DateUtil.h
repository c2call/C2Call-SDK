//
//  DateUtil.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.12.11.
//  Copyright (c) 2011 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject


+(NSTimeInterval) currentTime;
+(UInt64) currentTimeMilliseconds;
+(NSDate *) dateForUnixtime:(UInt64) tme;
+(NSDate *) dateForUnixLocaltime:(UInt64) tme;
+(NSString *) timeAgoForDate:(NSDate *) startDate;

@end
