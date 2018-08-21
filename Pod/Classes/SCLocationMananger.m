//
//  SCLocationMananger.m
//  C2CallPhone
//
//  Created by Michael Knecht on 27.07.18.
//
#import <CoreLocation/CoreLocation.h>
#import "SCLocationMananger.h"
#import "SCLoyaltyCampaign.h"
#import "SocialCommunication.h"

static SCLocationMananger *__instance = nil;
static NSString     *__MUTEX__ = @"__MUTEX__";

@interface SCLocationHandler : NSObject<CLLocationManagerDelegate> {
    void (^completionAction)(CLLocation *loc);
    
    CLLocationManager       *locationManager;
    
    id retainSelf;
    BOOL startOnAuthorize;
}

+(void) currentLocationWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion;

@end

@implementation SCLocationHandler

- (instancetype)initWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion
{
    self = [super init];
    if (self) {
        completionAction = completion;
        
        retainSelf = self;
        startOnAuthorize = NO;
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    return self;
}

-(void) startUpdatingLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [locationManager requestLocation];
    } else {
        startOnAuthorize = YES;
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocationAccuracy currentAccuracy = -1;
    CLLocation *foundLocation = nil;
    
    for (CLLocation *loc in locations) {
        if (!foundLocation) {
            foundLocation = loc;
            currentAccuracy = loc.horizontalAccuracy;
            continue;
        }
        
        if (loc.horizontalAccuracy < currentAccuracy) {
            foundLocation = loc;
            currentAccuracy = loc.horizontalAccuracy;
        }
    }
    
    [self performCompleteAction:foundLocation];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self performCompleteAction:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
{
    
    if (startOnAuthorize) {
        startOnAuthorize = NO;
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            DLog(@"SCLocationHandler: Requesting Location");
            [locationManager requestLocation];
            return;
        }
        
        [self performCompleteAction:nil];
    }
    
}

-(void) performCompleteAction:(CLLocation *) loc
{
    if (completionAction) {
        completionAction(loc);
    }
    locationManager.delegate = nil;
    locationManager = nil;
    
    id currentSelf = retainSelf;
    if (currentSelf) {
        retainSelf = nil;
    }
}

+(void) currentLocationWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion;
{
    SCLocationHandler *handler = [[SCLocationHandler alloc] initWithCompletionHandler:completion];
    
    
    [handler startUpdatingLocation];
}

@end


@interface SCLocationMananger() {
    
}

@property(nonatomic, strong) NSMutableArray<C2BlockAction *> *locationRequests;

@end

@implementation SCLocationMananger

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationUpdateTime = 0;
        _locationRequests = nil;
    }
    return self;
}

-(void) recentLocationWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion {
    
    if (CFAbsoluteTimeGetCurrent() - _locationUpdateTime > 3600.0) {
        [self currentLocationWithCompletionHandler:completion];
        return;
    }
    
    if (completion) {
        completion(_lastKnownLocation);
    }
    
}


-(void) currentLocationWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        if (completion) {
            completion(nil);
        }
    }
    
    __weak SCLocationMananger *weakself = self;
    
    BOOL doRequest = NO;
    @synchronized(__MUTEX__) {
        if (!self.locationRequests) {
            self.locationRequests = [NSMutableArray array];
            doRequest = YES;
        }
        
        C2BlockAction *action = [C2BlockAction actionWithAction:^(id sender) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(weakself.lastKnownLocation);
                });
            }
        }];
        
        [self.locationRequests addObject:action];
    }
    
    if (!doRequest) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SCLocationHandler currentLocationWithCompletionHandler:^(CLLocation *loc) {
            _lastKnownLocation = loc;
            _locationUpdateTime = CFAbsoluteTimeGetCurrent();
           
            @synchronized(__MUTEX__) {
                for (C2BlockAction *action in weakself.locationRequests) {
                    [action fireAction:nil];
                }
                
                weakself.locationRequests = nil;
            }
        }];
    });
}

+(instancetype) instance;
{
    @synchronized(__MUTEX__) {
        if (!__instance) {
            __instance = [[SCLocationMananger alloc] init];
        }
    }
    
    return __instance;
}

@end
