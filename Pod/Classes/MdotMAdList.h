//
//  MdotMAdList.h
//  C2CallPhone
//
//  Created by Michael Knecht on 28.11.10.
//  Copyright 2011 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MdotMAdList : NSObject {
	NSArray		*addList;
	NSString	*queryUrl;
}

@property(strong) NSArray		*addList;
@property(strong) NSString		*queryUrl;

+(MdotMAdList *) currentAdList;


@end
