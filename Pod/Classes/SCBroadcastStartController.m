//
//  SCBroadcastStartController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 16/05/16.
//
//

#import <CoreLocation/CoreLocation.h>

#import "SCBroadcastStartController.h"
#import "SCBroadcastRecordingController.h"
#import "SCUserSelectionController.h"
#import "SCLocationSubmitController.h"
#import "SCBroadcast.h"
#import "C2CallPhone.h"
#import "SCMediaManager.h"
#import "SCMediaManager.h"
#import "C2CallAppDelegate.h"
#import "FCLocation.h"
#import "SCFlatButton.h"
#import "IOS.h"

@interface SCBroadcastStartController () <CLLocationManagerDelegate>{
    BOOL startingBroadcast;
    CLLocationManager   *locationManager;
    CLLocation          *currentLocation;
}

@property(nonatomic, strong) NSArray    *members;
@property(nonatomic, strong) NSString   *locationKey;
@property(atomic, strong) CLLocation    *currentLocation;
@property (weak, nonatomic) IBOutlet SCFlatButton *startButton;



@end

@implementation SCBroadcastStartController

-(void) viewDidLoad
{
    [super viewDidLoad];

    self.startButton.enabled = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 100;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    
    if ([IOS iosVersion] >= 8.0) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        } else {
            [locationManager startUpdatingLocation];
        }
    } else {
        [locationManager startUpdatingLocation];
    }

}

- (void)dealloc
{
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    locationManager = nil;
}

#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    self.currentLocation = newLocation;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.startButton.enabled = YES;
    });
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;
{
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SCUserSelectionControllerSegue"]) {
        __weak UINavigationController *nav = (UINavigationController *) segue.destinationViewController;
        
        SCUserSelectionController *vc = (SCUserSelectionController *) nav.topViewController;
        
        [vc setResultAction:^(NSArray *result) {
            self.members = result;
            
            [nav dismissViewControllerAnimated:YES completion:NULL];
        }];
        
        [vc setCancelAction:^{
            [nav dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
    
    if ([segue.identifier isEqualToString:@"SCLocationSubmitControllerSegue"]) {
        __weak UINavigationController *nav = (UINavigationController *) segue.destinationViewController;
        
        SCLocationSubmitController *vc = (SCLocationSubmitController *) nav.topViewController;
        
        [vc setSubmitAction:^(NSString *locationKey) {
            self.locationKey = locationKey;
            [nav dismissViewControllerAnimated:YES completion:NULL];
        }];
        
        [vc setCancelAction:^{
            [nav dismissViewControllerAnimated:YES completion:NULL];
        }];
    }

}


- (IBAction)broadcastNameChanged:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)startVideo:(id)sender {
    
    if (startingBroadcast)
        return;
    
    startingBroadcast = YES;
    
    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:@"Starting Broadcast" andWaitMessage:nil];
    
    NSDictionary *proerties = @{@"UseLocation" : @(YES)};
    if (self.locationKey) {
        FCLocation *loc = [[FCLocation alloc] initWithKey:self.locationKey];
        
        if (loc.title) {
            proerties = @{@"LocationName" : loc.title, @"Longitude": [@(loc.locationCoordinate.longitude) stringValue], @"Latitude": [@(loc.locationCoordinate.latitude) stringValue]};
        } else {
            proerties = @{@"Longitude": [@(loc.locationCoordinate.longitude) stringValue], @"Latitude": [@(loc.locationCoordinate.latitude) stringValue]};
        }        
    } else if (self.currentLocation) {
        proerties = @{@"Longitude": [@(self.currentLocation.coordinate.longitude) stringValue], @"Latitude": [@(self.currentLocation.coordinate.latitude) stringValue]};
    }
    
    [[C2CallPhone currentPhone] createBroadcast:self.broadcastName.text withProperties:proerties withMembers:self.members withCompletionHandler:^(BOOL success, NSString * _Nullable bcastId, NSString * _Nullable result) {
       
        [[C2CallAppDelegate appDelegate] waitIndicatorStop];
        
        if (success) {
            
            [[SCMediaManager instance] capturePreviewImageWithCompletionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
                
                if (image) {
                    SCBroadcast *bcast = [[SCBroadcast alloc] initWithBroadcastGroupid:bcastId retrieveFromServer:NO];
                    [bcast setGroupImage:image withCompletionHandler:^(BOOL finished) {
                        self.recordingController.broadcastGroupId = bcastId;
                        [self.recordingController startBroadcasting];
                    }];
                }
            }];
        }
        startingBroadcast = NO;
    }];
}

- (IBAction)toggleCamera:(UIButton *)cameraButton {
    if (cameraButton.selected) {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionFront];
    } else {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionBack];
    }
}

- (IBAction)closeController:(id)sender {
    [self.recordingController closeBroadcasting];
}

@end
