//
//  VideoHandler.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFrame.h"

@class FrameInfo, NativeVideoContext, RTPPacket, VStat;

@protocol VideoHandler <NSObject>

/**
 * Returns true if the video context has been initialized and loaded correctly
 * 
 * @return
 */
-(BOOL) isInitialized;

/**
 * Is a converted frame ready for transmission
 * @return
 */
-(BOOL) isCaptureFrameAvailable;

/**
 * 	
 */
-(BOOL) isActive;	

-(void) setPreviewView:(UIView *) preview;

/**
 * Retrieve the next converted VideoFrame for transmission via RTP
 * @return
 */
-(id<VideoFrame>) getCaptureVideoFrame;

/**
 * 
 */
-(NSData *) getDecodedVideoFrame:(int) options;

/**
 * Returns the frametype of the last decoded frame
 * @return
 */
-(BOOL) isLastDecodedFrameKeyframe;

-(int) isLastDecodedFrameRotated;

/**
 * Starts the capture and conversion process
 */
-(void) startVideoCapture;

/**
 * Stops the capture and conversion process
 */
-(void) stopVideoCapture;

/**
 * Shows the actual Video Window on the screen
 */
-(void) showVideoFrame;

/**
 * Hide the Video Window
 */
-(void) hideVideoFrame;

/**
 * Width of the VideoFrame
 * @return
 */
-(int) frameWidth;

/**
 * Height of the VideoFrame
 * @return
 */
-(int) frameHeight;

-(int) frameRate;

-(void) setFrameRate:(int) newRate;

-(int) keyframeDistance;
-(void) setKeyframeDistance:(int) distance;

/**
 * Get FrameInfo Structure for the last decoded frame
 * @return
 */
-(FrameInfo *) frameInfo;	

-(int) fpsRead;
-(int) fpsWrite;

/**
 *	Hangup Call 
 */
-(void) hangUp;

/**
 * Stops all activities, removes the Window, releases all resources
 */
-(void) dispose;

-(VStat *) getVideoStatus;

-(void) handleVideoStatusEvent:(RTPPacket *) packet;

@end
