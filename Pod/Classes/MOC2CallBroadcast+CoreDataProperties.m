//
//  MOC2CallBroadcast+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 01.03.17.
//
//

#import "MOC2CallBroadcast+CoreDataProperties.h"

@implementation MOC2CallBroadcast (CoreDataProperties)

+ (NSFetchRequest<MOC2CallBroadcast *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MOC2CallBroadcast"];
}

@dynamic endDate;
@dynamic groupDescription;
@dynamic groupid;
@dynamic groupImage;
@dynamic groupImageTimestamp;
@dynamic groupName;
@dynamic groupOwner;
@dynamic groupType;
@dynamic latitude;
@dynamic live;
@dynamic locationName;
@dynamic longitude;
@dynamic mediaUrl;
@dynamic onlineUsers;
@dynamic startDate;
@dynamic featured;
@dynamic reward;
@dynamic broadcastUser;
@dynamic members;
@dynamic userData;
@dynamic tags;

@end
