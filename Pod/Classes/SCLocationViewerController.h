//
//  SCLocationViewerController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class FCLocation;

/** Presents the standard C2Call SDK Location Viewer Controller.
 */

@interface SCLocationViewerController : UIViewController

/** @name Outlets */
/** MapView; see MKMapView. */
@property(nonatomic, weak) IBOutlet MKMapView     *mapView;

/** Address Title. */
@property(nonatomic, weak) IBOutlet UILabel       *addressTitle;

/** Address Label. */
@property(nonatomic, weak) IBOutlet UILabel       *addressLabel;

/** View containing addressTitle; see addressLabel.
 
 Can be hidden on touch.
 */
@property(nonatomic, weak) IBOutlet UIView          *addressView;

/** @name Setting the location */
/** Sets the Location to present. 
 
 @param key - Rich Media Key for the location
 @param user - Name of the user belonging to that location
 */
-(void) setLocationForKey:(NSString *) key andUser:(NSString *) user;

/** @name Actions */
/** Changes the MapType; expects an UISegmentedControl as sender.
 
 Default Implementation:
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }

 @param sender - The initiator of the action
 */
-(IBAction)changeMapType:(id)sender;

/** Focuses the map region to show your current position and the provided location.

 @param sender - The initiator of the action
 */
-(IBAction)focusMap:(id)sender;

/** Shows the default content menu using SCPopupMenu.
 
 Default Implementation:
 
     SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    NSString *url = nil;
    if (self.location.place) {
        url = [self.location.place objectForKey:@"url"];
    }
    
    if (self.currentLocation && self.location) {
        [cv addChoiceWithName:NSLocalizedString(@"Show Route", @"Choice Title") andSubTitle:NSLocalizedString(@"Show Route Information in Google Maps", @"Button") andIcon:[UIImage imageNamed:@"ico_navigate"] andCompletion:^{
            NSString *url = @"http://maps.google.com/maps?daddr=%f,%f&saddr=%f,%f";
            url = [NSString stringWithFormat:url, location.locationCoordinate.latitude, location.locationCoordinate.longitude, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"navigon://"]]) {
            [cv addChoiceWithName:NSLocalizedString(@"Navigon Mobile Navigator", @"Choice Title") andSubTitle:NSLocalizedString(@"Launch Navigon", @"Button") andIcon:[UIImage imageNamed:@"ico_launch_navigon"] andCompletion:^{
                NSString *url = @"coordinate/%@/%.6f/%.6f";
                
                NSString *name = self.navigationItem.title;
                if (self.location.place) {
                    name = [self.location.place objectForKey:@"name"];
                }
                url = [NSString stringWithFormat:url, name, location.locationCoordinate.longitude, location.locationCoordinate.latitude];
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                url = [NSString stringWithFormat:@"navigon://%@", url];
                DLog(@"openUrl : %@", url);
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tomtomhome://"]]) {
            [cv addChoiceWithName:NSLocalizedString(@"TomTom Navigation", @"Choice Title") andSubTitle:NSLocalizedString(@"Launch TomTom", @"Button") andIcon:[UIImage imageNamed:@"ico_launch_tomtom"] andCompletion:^{
                NSString *url = @"tomtomhome://geo:action=show&lat=%.8f&long=%.8f&name=%@";
                NSString *name = self.navigationItem.title;
                
                if (self.location.place) {
                    name = [self.location.place objectForKey:@"name"];
                }
                
                name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                url = [NSString stringWithFormat:url, location.locationCoordinate.latitude, location.locationCoordinate.longitude, name];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"com.sygic.aura://"]]) {
            [cv addChoiceWithName:NSLocalizedString(@"Sygic GPS", @"Choice Title") andSubTitle:NSLocalizedString(@"Launch Sygic GPS", @"Button") andIcon:[UIImage imageNamed:@"ico_navigate"] andCompletion:^{
                NSString *url = @"com.sygic.aura://lat=%.6f?lon=%.6f?type=drive";
                url = [NSString stringWithFormat:url, location.locationCoordinate.latitude, location.locationCoordinate.longitude];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }];
        }
    }
    
    
    if (url) {
        [cv addChoiceWithName:NSLocalizedString(@"Open Url", @"Choice Title") andSubTitle:NSLocalizedString(@"Open places details", @"Button") andIcon:[UIImage imageNamed:@"ico_open_url"] andCompletion:^{
            
            [self openBrowserWithUrl:url andTitle:self.location.title];
        }];
    }
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{}];
    
    [cv showMenu];

 @param sender - The initiator of the action
*/
-(IBAction)openMenu:(id)sender;


@end
