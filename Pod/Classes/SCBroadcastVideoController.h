//
//  SCBroadcastVideoController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10/05/16.
//
//

#import <UIKit/UIKit.h>
#import "RTPVideoHandler.h"

@class ScreenControls;

@interface SCBroadcastVideoController : UIViewController<VideoHandlerDelegate>

@property (nonatomic, weak) IBOutlet UIView                 *innerView;

@property (nonatomic, strong) NSString                      *broadcastGroupId;

@end
