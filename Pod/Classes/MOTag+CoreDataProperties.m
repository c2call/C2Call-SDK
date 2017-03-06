//
//  MOTag+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 01.03.17.
//
//

#import "MOTag+CoreDataProperties.h"

@implementation MOTag (CoreDataProperties)

+ (NSFetchRequest<MOTag *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MOTag"];
}

@dynamic tag;
@dynamic featured;
@dynamic timelineItems;
@dynamic broadcasts;

@end
