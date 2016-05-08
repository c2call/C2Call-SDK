//
//  SCBroadcastChatController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 08/05/16.
//
//

#import "SCBroadcastChatController.h"
#import "SCBroadcastController.m"

@implementation SCBroadcastChatController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidHideNotification" object:nil];
    
    
    CALayer *l = self.messageTextView.layer;
    l.borderWidth = 1.;
    l.cornerRadius = 8.;
    l.masksToBounds = YES;
    l.borderColor = [[UIColor lightGrayColor] CGColor];


}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastController class]]) {
        self.broadcast = segue.destinationViewController;
        self.broadcast.broadcastGroupId = self.broadcastGroupId;
    }
}


-(CGFloat) keyboardSize:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect appFrame = [UIApplication sharedApplication].keyWindow.frame;
    CGFloat w = appFrame.size.width;
    if (w > appFrame.size.height)
        w = appFrame.size.height;
    
    //BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = keyboardFrame.size.height;//isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    if (height == w) {
        height = keyboardFrame.size.width;
    }
    
    return height;
}


-(void) handleNotification:(NSNotification *) notification
{
    BOOL hasTabBar = !self.tabBarController.tabBar.isHidden;
    
    if ([[notification name] isEqualToString:@"UIKeyboardWillShowNotification"]) {
        CGFloat keyboardSize = [self keyboardSize:notification];
        
        
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        if (!hasTabBar) {
            tabBarHeight = 0.;
        }
        
        CGFloat kbNewHeight = keyboardSize - tabBarHeight;
        
        self.innerViewBottomContraint.constant = kbNewHeight;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardWillHideNotification"]) {
        
        self.innerViewBottomContraint.constant = 0;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];        
    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardDidShowNotification"]) {
    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardDidHideNotification"]) {
    }
    
    
} 


@end
