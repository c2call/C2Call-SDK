//
//  SCBroadcastChatController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 08/05/16.
//
//

#import "SCBroadcastChatController.h"
#import "SCBroadcastController.h"
#import "SCBroadcastVideoController.h"
#import "SCMediaManager.h"
#import "C2CallPhone.h"

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

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self callBroadcast:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        [[C2CallPhone currentPhone] hangUp];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastController class]]) {
        self.broadcast = segue.destinationViewController;
        self.broadcast.broadcastGroupId = self.broadcastGroupId;
    }
    
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastVideoController class]]) {
        self.broadcastVideo = segue.destinationViewController;
        self.broadcastVideo.broadcastGroupId = self.broadcastGroupId;
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


- (IBAction)hideKeyboard:(id)sender {
    if ([self.messageTextView isFirstResponder]) {
        [self.messageTextView resignFirstResponder];
    }
}

- (IBAction)callBroadcast:(id)sender {
    if (self.broadcastGroupId){
        [[SCMediaManager instance] disableMediaOutput:YES];
        [[C2CallPhone currentPhone] callVideo:self.broadcastGroupId groupCall:YES];
    }
}

- (IBAction)sendMessage:(id)sender {
    if (self.broadcastGroupId && [self.messageTextView.text length] > 0){
        [[C2CallPhone currentPhone] submitMessage:self.messageTextView.text toUser:self.broadcastGroupId];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.messageTextView.text = nil;
            
            if ([self.messageTextView isFirstResponder]) {
                [self.messageTextView resignFirstResponder];
            }
        });
    }
    
}

- (IBAction)hangUp:(id)sender {
    [[C2CallPhone currentPhone] hangUp];
}


@end
