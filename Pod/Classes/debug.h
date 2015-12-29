/*
 *  debug.h
 *  C2CallPhone
 *
 *  Created by Michael Knecht on 26.02.09.
 *  Copyright 2009 Actai Networks GmbH. All rights reserved.
 *
 */

#ifndef __DEBUG_H
#define __DEBUG_H

#ifdef __C2DEBUG
#define DLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... ) 
#endif

#ifndef __DISTRIBUTION
#define XLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define XLog( s, ... )
#endif

//#ifndef __C2DEBUG
//#define C2DEBUG 0
//#else
//#define C2DEBUG 1
//#endif

//#define NSLog if (C2DEBUG == 1) NSLog

#endif