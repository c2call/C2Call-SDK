//
//  FCGeocoder.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDXMLElement, FCLocation;
@interface FCGeocoder : NSObject {
    void (^complete)(FCGeocoder *gc);
}

@property(nonatomic, strong) NSMutableArray *placesList;
@property(nonatomic, strong) DDXMLElement *placesXML;

- (id)initWithKey:(NSString *) key andCompleteHandler:(void (^)(FCGeocoder *gc))_complete;
- (id)initWithLocation:(FCLocation *) loc andCompleteHandler:(void (^)(FCGeocoder *gc))_complete;
@end
