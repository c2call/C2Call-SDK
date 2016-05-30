//
//  MOGroupMember.h
//  C2CallPhone
//
//  Created by Michael Knecht on 04.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MOC2CallGroup;

@interface MOGroupMember : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) MOC2CallGroup *group;

@end
