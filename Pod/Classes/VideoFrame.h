//
//  VideoFrame.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.03.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol VideoFrame <NSObject>

-(int) copyFrame:(NSMutableData *)data;

/**
 * Indicates whether all frameparts have been received correctly from the RTP stream
 * @return
 */
-(BOOL) frameCompleted;

/**
 * PictureId for RTP transmission, 0 - 255
 * @return
 */
-(int) pictureId;
-(void) setPictureId:(int) pictureId;

/**
 * Keyframe marker
 * @return
 */
-(BOOL) keyFrame;
-(void) setKeyFrame:(BOOL) keyFrame;

/**
 * Number of parts for RTP transmission
 * @return
 */
-(int) frameParts;	

/**
 * Total FrameLength in bytes
 * @return
 */
-(int) frameLength;

/**
 * Current VideoFrame RTP Timestamp
 * @return
 */
-(long) timestamp;
-(void) setTimestamp:(long) timestamp;

/**
 * Get's the frame payload data for RTP transmission. If the frame is splitted into multiple rtp packets
 * the VideoFrame has multiple parts (see getFrameParts). 
 * The Frame Payload includes the Frame Payload Header
 * @param partnumber
 * @return
 */
-(NSData *) framePayload:(int) partnumber;


@end
