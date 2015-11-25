//
//  FCLocation.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.03.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface FCLocation : NSObject<MKAnnotation> 

@property(nonatomic, strong) NSString        *locationKey;
@property(nonatomic, strong) NSString        *reference;
@property(nonatomic, strong) NSString        *address;
@property(nonatomic) CLLocationCoordinate2D  locationCoordinate;
@property(nonatomic, strong) NSDictionary    *geoLocation;
@property(nonatomic, strong) NSDictionary    *place;

- (id)initWithKey:(NSString *) key;
- (id)initWithCoordinate:(CLLocationCoordinate2D ) coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D ) coordinate andReference:(NSString *) ref;
- (id)initWithCoordinate:(CLLocationCoordinate2D ) coordinate andAddress:(NSString *) addr;

-(void) storeLocation;
-(BOOL) restoreLocation:(NSString *) key;

-(void) setTitle:(NSString *) _title;
-(void) setSubTitle:(NSString *) _subtitle;
-(NSString *) locationUrl;

@end
