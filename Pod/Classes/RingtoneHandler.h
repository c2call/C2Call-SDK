//
//  RingtoneHandler.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.05.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class C2AudioFile;

@interface C2SystemSound : NSObject
{
	//SystemSoundID			sound;
	C2AudioFile				*audio;
    
    
	BOOL			soundCompleted, timerSound;
    
	NSTimer					*timer;
	NSTimeInterval			interval;
}

@property(strong) NSTimer		*timer;
@property NSTimeInterval		interval;
@property BOOL soundCompleted;

-(id) initWithRessource:(NSString *) soundFile ofType:(NSString *) ext;

-(void) startSound;
-(void) startAlert;
-(void) stopSound;
-(void) playSound;
-(void) playAlert;



@end


@interface RingtoneHandler : NSObject {
	C2SystemSound	*messageSound;
	C2SystemSound	*ringtone;
	C2SystemSound	*ringbackTone;
	C2SystemSound	*busyTone;	
	C2SystemSound	*offerwall;	
	C2SystemSound	*error;	
	C2SystemSound	*callme;	
	C2SystemSound	*messageIn;	
	C2SystemSound	*messageOut;	
}

@property(strong) C2SystemSound		*messageSound;
@property(strong) C2SystemSound		*ringtone;
@property(strong) C2SystemSound		*ringbackTone;
@property(strong) C2SystemSound		*busyTone, *error, *offerwall, *callme, *messageIn, *messageOut;

+(RingtoneHandler *) defaultHandler;

@end
