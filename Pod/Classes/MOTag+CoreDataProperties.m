//
//  MOTag+CoreDataProperties.m
//  C2CallPhone
//
//  Created by Michael Knecht on 29.04.17.
//
//

#import "MOTag+CoreDataProperties.h"

@implementation MOTag (CoreDataProperties)

+ (NSFetchRequest<MOTag *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MOTag"];
}

@dynamic featured;
@dynamic tag;
@dynamic referenceUrl;
@dynamic infoText;
@dynamic reward;
@dynamic broadcasts;
@dynamic timelineItems;

@end
