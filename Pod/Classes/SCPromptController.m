//
//  SCPromptController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//

#import "SCPromptController.h"
#import "C2CallAppDelegate.h"

@interface SCPromptController () {

    BOOL            isVisible;
}

@property(nonatomic, strong) IBOutlet UILabel    *prompt;
@property NSTimeInterval                         duration;

@property(nonatomic, strong) SCPromptController  *strongself;

@end

@implementation SCPromptController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) showPrompt:(NSString *) prompt parentView:(UIView *)parentView timeout:(NSTimeInterval) t
{
    if (isVisible)
        return;
    self.strongself = self;
    
    isVisible = YES;
    
    self.view.frame = parentView.bounds;
    
    // Setting prompt
    self.prompt.text = prompt;
    self.duration = t;
    
    
    // Show View
    self.view.alpha = 0.0;
    [parentView addSubview:self.view];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        __weak SCPromptController *weakself = self;
        double delayInSeconds = self.duration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakself hidePrompt:nil];
        });
    }];
    
}

-(void) hidePrompt:(NSTimer *) t
{
    if (!isVisible)
        return;
    isVisible = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        self.prompt = nil;
        self.strongself = nil;
    }];
}

+(void) promptController:(NSString *) _prompt parentView:(UIView *)_parentView timeout:(NSTimeInterval) t
{
    if ([NSThread isMainThread]) {
        SCPromptController *p = nil;
        p = [[C2CallAppDelegate appDelegate] instantiateViewControllerWithIdentifier:@"SCPromptController"];
        
        
        [p showPrompt:_prompt parentView:_parentView timeout:t];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            SCPromptController *p = nil;
            p = [[C2CallAppDelegate appDelegate] instantiateViewControllerWithIdentifier:@"SCPromptController"];
            
            
            [p showPrompt:_prompt parentView:_parentView timeout:t];
        });
    }
}

- (void)dealloc
{
    self.prompt = nil;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.prompt = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
