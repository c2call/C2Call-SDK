//
//  FCPlaces.h
//  C2CallPhone
//
//  Created by Michael Knecht on 3/9/12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDXMLElement, FCLocation;

@interface FCPlaces : NSObject {
   void (^complete)();
}

@property(nonatomic, strong) NSMutableArray *placesList;
@property(nonatomic, strong) DDXMLElement *placesXML;

- (id)initWithKey:(NSString *) key andCompleteHandler:(void (^)())_complete;
- (id)initWithLocation:(FCLocation *) loc andCompleteHandler:(void (^)())_complete;

@end
