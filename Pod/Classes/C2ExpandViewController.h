//
//  C2ExpandViewController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 29.11.12.
//
//

#import <UIKit/UIKit.h>
#import "C2BlockAction.h"

@interface C2ExpandViewController : UIViewController {
    UIViewController    *savedParentViewController;
    UIView              *savedSuperView;
    CGRect              savedFrame;
    
    BOOL        expanded;
}

@property(nonatomic) BOOL       forcePortrait;
@property(nonatomic, strong)    C2BlockAction   *willExpand, *animateExpand, *didExpand, *willCollapse, *animateCollapse, *didCollapse;
@property(nonatomic, strong) IBOutlet UIView    *expandView;
@property(nonatomic) NSTimeInterval     animationDuration;

-(IBAction) toggleExpandCollapse:(id) sender;

-(void) handleRotation:(UIInterfaceOrientation) o;
-(UIInterfaceOrientation) currentInterfaceOrientation;

@end
