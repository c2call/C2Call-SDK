//
//  SCAudioRecordingOverlayController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.07.16.
//
//

#import <UIKit/UIKit.h>

@interface SCAudioRecordingOverlayController : UIViewController

@property(nonatomic, weak) IBOutlet UILabel     *recordingTime;

-(void) setUseAction:(void (^)(NSString *richMediaKey))handler;
-(void) setCancelAction:(void (^)())handler;


@end
