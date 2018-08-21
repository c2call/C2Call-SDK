//
//  SCLocationMananger.h
//  C2CallPhone
//
//  Created by Michael Knecht on 27.07.18.
//

#import <Foundation/Foundation.h>



@interface SCLocationMananger : NSObject

@property (strong, nonatomic) CLLocation    *lastKnownLocation;
@property (nonatomic) CFAbsoluteTime        locationUpdateTime;

/** Delivers either the lastKnownLocation if age below 1 hour or requests the current location
 */
-(void) recentLocationWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion;

/** Requests the current location
 */
-(void) currentLocationWithCompletionHandler:(nonnull void (^)(CLLocation *loc)) completion;

+(instancetype) instance;

@end
