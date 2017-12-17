//
//  FCPlacesDetail.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDXMLElement;

@interface FCPlacesDetail : NSObject {
    void (^complete)(FCPlacesDetail *pd);
}

@property(nonatomic, strong) NSMutableDictionary *place;
@property(nonatomic, strong) DDXMLElement *placesXML;

- (id)initWithReference:(NSString *) key andCompleteHandler:(void (^)(FCPlacesDetail *pd))_complete;

@end
