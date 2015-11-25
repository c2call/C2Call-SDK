//
//  MOPhoneNumber.h
//  C2CallPhone
//
//  Created by Michael Knecht on 07.05.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallUser;

@interface MOPhoneNumber : NSManagedObject

@property (nonatomic, strong) NSNumber * allowEdit;
@property (nonatomic, strong) NSString * numberType;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) MOC2CallUser *contactNumbers;
@property (nonatomic, strong) MOC2CallUser *friendNumbers;

@end
