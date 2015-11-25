//
//  SCWaitIndicatorController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import <AVFoundation/AVFoundation.h>

#import "SCWaitIndicatorController.h"
#import "C2CallAppDelegate.h"

@interface SCWaitIndicatorController () {
    NSTimer									*timer;
    BOOL									visible;
}

@property(nonatomic, strong) NSString								*messageTitle, *waitMessage;


@end

@implementation SCWaitIndicatorController
@synthesize activity, waitMessage, messageTitle, labelWaitMessage, labelMessageTitle, autoHide;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

+(SCWaitIndicatorController *) controllerWithTitle:(NSString *) _messageTitle andWaitMessage:(NSString*) _waitMessage
{
    SCWaitIndicatorController *pwc = nil;
    pwc = [[C2CallAppDelegate appDelegate] instantiateViewControllerWithIdentifier:@"SCWaitIndicatorController"];
    
    pwc.waitMessage = _waitMessage;
    pwc.messageTitle = _messageTitle;
    pwc.autoHide = YES;
    return pwc;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	if (waitMessage)
		labelWaitMessage.text = waitMessage;
	
	if (messageTitle)
		labelMessageTitle.text = messageTitle;
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (waitMessage)
		labelWaitMessage.text = waitMessage;
	
	if (messageTitle)
		labelMessageTitle.text = messageTitle;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

-(BOOL) shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void) handleRotation:(UIInterfaceOrientation) o
{
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    switch (o) {
        case UIInterfaceOrientationLandscapeRight:
            self.view.layer.transform = CATransform3DMakeRotation(M_PI / 2, 0.0, 0.0, 1.0);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.view.layer.transform = CATransform3DMakeRotation(M_PI + M_PI / 2, 0.0, 0.0, 1.0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.view.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0);
            break;
        case UIInterfaceOrientationPortrait:
            self.view.layer.transform = CATransform3DIdentity;
            break;
        default:
            break;
    }
}

-(void) show:(UIView *)parentView
{
    if (visible)
        return;
	visible = YES;
    
    [self handleRotation:[UIApplication sharedApplication].statusBarOrientation];
	[parentView addSubview:self.view];
	
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	
    if (self.autoHide) {
        timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timedHide:) userInfo:nil repeats:NO];
    }
}

-(void) timedHide:(NSTimer *) t
{
	timer = nil;
	[self hide];
}

-(void) hide
{
	if (!visible)
		return;
	
	visible = NO;
	
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
    
	
	[self.view removeFromSuperview];
}



@end
