//
//  ScreenControls.h
//  C2CallPhone
//
//  Created by Michael Knecht on 6/1/11.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScreenControls : UIViewController {
}

@property(nonatomic, weak) IBOutlet  UILabel             *fpsRead, *fpsWrite, *labelMediaStatus, *labelDataRate;
@property(nonatomic, weak) IBOutlet  UILabel             *labelName, *labelDuration, *labelRecvRes, *labelSendRes;
@property(nonatomic, weak) IBOutlet  UISegmentedControl  *cameraSwitch, *cameraSwitch2;
@property(nonatomic, weak) IBOutlet  UIView              *debugView;
@property(nonatomic, weak) IBOutlet  UIButton            *btnMicrophone, *btnExpand;

-(void) setSmallView:(NSNumber *) isSmall;

@end
