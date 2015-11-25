//
//  MOOpenId.h
//  C2CallPhone
//
//  Created by Michael Knecht on 4/17/12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOOpenId : NSManagedObject

@property (nonatomic, strong) NSString * openId;
@property (nonatomic, strong) NSString * host;

@end
