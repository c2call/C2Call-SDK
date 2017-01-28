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
#import "ImageUtil.h"
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
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitch;



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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([SCMediaManager instance].cameraPosition == AVCaptureDevicePositionBack) {
        self.cameraSwitch.selected = YES;
    } else {
        self.cameraSwitch.selected = NO;
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
    
    if ([self.broadcastName isFirstResponder]) {
        [self.broadcastName resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.infoView.alpha = 1.0;
    }];
    
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
    
    __weak SCBroadcastStartController *weakself = self;
    
    NSString *bcastName = self.broadcastName.text;
    if ([bcastName length] == 0) {
    NSDateFormatter *dateTime = [[NSDateFormatter alloc] init];
        [dateTime setDateStyle:NSDateFormatterShortStyle];
        [dateTime setTimeStyle:NSDateFormatterShortStyle];
        bcastName = [NSString stringWithFormat:@"Video Broadcast from %@", [dateTime stringFromDate:[NSDate date]]];
    }
    
    [[C2CallPhone currentPhone] createBroadcast:bcastName withProperties:proerties withMembers:self.members withCompletionHandler:^(BOOL success, NSString * _Nullable bcastId, NSString * _Nullable result) {
        
        if (success) {
            [[SCMediaManager instance] capturePreviewImageWithCompletionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
            
                if (image) {
                    image = [ImageUtil fixImage:image withQuality:UIImagePickerControllerQualityTypeLow];
                    
                    SCBroadcast *bcast = [[SCBroadcast alloc] initWithBroadcastGroupid:bcastId retrieveFromServer:NO];
                    
                    [bcast setGroupImage:image withCompletionHandler:^(BOOL finished) {
                        weakself.recordingController.broadcastGroupId = bcastId;
                        [weakself.recordingController startBroadcasting];
                    }];
                }
            }];
        }
        startingBroadcast = NO;
    }];
}

- (IBAction)toggleCamera:(UIButton *)cameraButton {
    if ([SCMediaManager instance].cameraPosition == AVCaptureDevicePositionBack) {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionFront];
        cameraButton.selected = NO;
    } else {
        [[SCMediaManager instance] switchCamera:AVCaptureDevicePositionBack];
        cameraButton.selected = YES;
    }
}

- (IBAction)closeController:(id)sender {
    [self.recordingController closeBroadcasting];
}

@end
