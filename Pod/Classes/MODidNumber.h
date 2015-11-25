//
//  MODidNumber.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.02.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallUser;

@interface MODidNumber : NSManagedObject

@property (nonatomic, retain) NSNumber * didNum;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) MOC2CallUser *user;

@end
