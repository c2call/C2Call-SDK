//
//  MOUserData.h
//  C2CallPhone
//
//  Created by Michael Knecht on 19.02.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallGroup, MOC2CallUser;

@interface MOUserData : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * public;
@property (nonatomic, retain) MOC2CallGroup *group;
@property (nonatomic, retain) MOC2CallUser *friend;

@end
