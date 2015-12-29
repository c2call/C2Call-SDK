//
//  C2WaitMessage.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.04.13.
//
//

#import <UIKit/UIKit.h>

@interface C2WaitMessage : NSObject

+(void) waitMessageWithTitle:(NSString *) aTitle andMessage:(NSString *) aMessage;
+(void) hideWaitMessage;

@end
