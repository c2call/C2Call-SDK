//
//  WaitIndicatorProtocol.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.05.11.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#ifndef __WAITINDICATORPROTOCOL
#define __WAITINDICATORPROTOCOL

/** Certain activities processed by C2Call SDK components might use a reasonable amount of time, which should be notified to the user.
 
 For example capture a video and processing the video for submission might take a few seconds, up to a few minutes, dependent on the video length.
 
 In this case, the user will be automatically notified by the SDK classes, by calling waitIndicatorWithTitle:andWaitMessage: delegate method.
 
 The default behavior of C2CallAppDelegate class is to instantiate an SCWaitIndicatorController to display the wait message.
 
 You may overwrite the default behavior, by overwriting the corresponding C2CallAppDelegate methods.
 
 */
@protocol WaitIndicatorDelegate <NSObject>

@optional

/** Show a Wait Dialog with a title and a wait message.
 
 Default Implementation:
    -(void) waitIndicatorWithTitle:(NSString *) aTitle andWaitMessage:(NSString *) aMessage
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (waitIndicator) {
                [waitIndicator hide];
                self.waitIndicator = nil;
            }
 
            waitIndicator = [SCWaitIndicatorController controllerWithTitle:aTitle andWaitMessage:aMessage];
            waitIndicator.autoHide = YES;
            [waitIndicator show:self.mainScreenController.view];
        });
    }

 */
-(void) waitIndicatorWithTitle:(NSString *) aTitle andWaitMessage:(NSString *) aMessage;

/** Show the default connecting to service message
 
 */
-(void) waitIndicatorConnectingToService;

/** Show the default get price for number message
 
 */
-(void) waitIndicatorGetPriceForNumber;

/** Show the Wait Dialog with title and the default wait message
 
 */
-(void) waitIndicatorWithTitle:(NSString*) title;

/** Removes the Wait Dialog from the screen
 
 */
-(void) waitIndicatorStop;

@end

#endif