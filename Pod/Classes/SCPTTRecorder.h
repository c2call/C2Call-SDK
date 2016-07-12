//
//  PTTRecorder.h
//  MarsApp
//
//  Created by Michael Knecht on 27/04/16.
//  Copyright © 2016 Mars General Services Pld. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    PTT_Audio_WAVE,
    PTT_AUDIO_AAC
} PTTAudioType;

@interface SCPTTRecorder : NSObject

- (instancetype)initWithAudioType:(PTTAudioType) audioType;

-(BOOL) prepareRecordingSession;
-(NSString *) recorderingTime;
-(BOOL) startRecording;
-(void) cancelRecording;
-(void) endRecordingAndSubmit:(NSString *) targetuser withCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey, NSError *error))handler;
-(void) endRecordingAndUseWithCompletionHandler:(void (^)(BOOL success, NSString *richMediaKey, NSError *error))handler;

@end
