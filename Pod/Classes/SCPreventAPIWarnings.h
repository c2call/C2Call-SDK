//
//  SCPreventAPIWarnings.h
//  C2CallPhone
//
//  Created by Michael Knecht on 26.09.14.
//
//

#import <Foundation/Foundation.h>

// Do nothing, just be there to prevent iTunesConnect API Warnings

@interface SCPreventAPIWarnings : NSObject

-(NSString *) accessToken;
-(NSString *) activeSession;
-(void) fetch;
-(BOOL) isOpen;
-(void) setActiveSession:(NSString *) s;
-(void) setPopoverController:(id) controller;

@end
