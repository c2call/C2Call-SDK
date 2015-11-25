//
//  MOAddress.h
//  C2CallPhone
//
//  Created by Michael Knecht on 4/17/12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOAddress : NSManagedObject

@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * zipcode;

@end
