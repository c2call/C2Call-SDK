//
//  RTPVideoHandler.h
//  C2CallPhone
//
//  Created by Michael Knecht on 11.03.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoHandler.h"
#import "VideoFrame.h"


@class RTPSession, RTPVideoStreamVP8, FrameInfo, VPXDecoder, VPXEncoder, YUVUtil;
@class VideoQuality, VStat, DDXMLElement;

@protocol VideoHandlerDelegate <NSObject>

-(void) videoStreamAdded:(unsigned long) streamNum;

@end

@interface VStream : NSObject {
@private
    RTPVideoStreamVP8       *videoStream;
    VPXDecoder              *decoder;
    unsigned long           ssrc;
    BOOL                    notified;
    
}

@property(nonatomic, strong)    RTPVideoStreamVP8       *videoStream;
@property(nonatomic, strong)    VPXDecoder              *decoder;
@property(nonatomic) unsigned long                      ssrc;
@property(nonatomic) BOOL                               notified;

@end

#define DEFAULT_WIDTH   640
#define DEFAULT_HEIGHT  480
#define YUVSIZEFACTOR   1.5
#define MAX_CAPTUREFRAMES   1000

@interface RTPVideoHandler : NSObject<VideoHandler, AVCaptureVideoDataOutputSampleBufferDelegate> {
    //AVCaptureSession            *videoCapture;
    //AVCaptureInput              *frontCamera, *backCamera;
    AVCaptureVideoPreviewLayer  *previewLayer;

    RTPSession              *session;
    
	NSMutableArray          *vstreams;
    NSMutableDictionary     *streamInfo;
    VPXEncoder              *encoder;
    NSMutableData           *decodedYUVData;
    NSMutableData           *encodedYUVData, *converterBuffer;
    
    NSMutableArray          *videoResolutions;
	int                     currentResolution, preferredResolution, maxDeviceResolution;
	int                     resizeResolution, rotateFlag;
	BOOL                    resize, reduceResolutionIndicator;
    
	// This list contains the VideoParameters after a learning cicle of at least
	// 3 VStat events
	NSMutableArray          *preferredParameters;
	NSMutableArray          *remoteVideoStatusHistory, *localVideoStatusHistory;
	
	VideoQuality            *videoQuality;
    VStat                   *localVideoStatus, *lastRemoteVideoStatus;

	int                     currentQualityIndex, resolutionIndicator;
	int                     stepSize, validBandwidthCounter;
    int                     encodeCount;
	NSTimeInterval          averageEncodingTime, totalEncodeTime;
	BOOL                    resetEncodingTime;

	int                     frameRate, newFrameRate, rateCount, logCount; // = 12;
	int                     keyFrameDistance, newKeyframeDistance; //= 10;
	int                     maxPacketSize; // = 1000;
    int                     framesWrite, framesRead;
    CFAbsoluteTime          initialReadTime, initialWriteTime, initialFPSWrite, initialFPSRead;
    
	int                     frameWidth;
	int                     frameHeight;
    int                     fpsWrite, fpsRead;
	CFAbsoluteTime          captureStart;

    FrameInfo               *frameInfo, *encodedFrameInfo;
    
	BOOL                    active;
	
	id<VideoFrame>          capturedFrames[MAX_CAPTUREFRAMES];    
    int                     readIndex, writeIndex, pictureId, lastFrameRotated, connectionQuality;
    
	BOOL                    lastDecodedKeyframe; // = false; 
	BOOL                    decoding, forceKF, disposed; // = false;
    
    id<VideoHandlerDelegate, NSObject> delegate;
}

@property(atomic, strong) NSMutableArray        *vstreams;
@property(atomic, strong) NSMutableDictionary   *streamInfo;
@property(nonatomic, strong)  VStat             *localVideoStatus, *lastRemoteVideoStatus;
@property(nonatomic) int                        rotateFlag, connectionQuality;
@property(nonatomic, readonly) int currentCamera;
@property(nonatomic, strong) AVCaptureInput     *frontCamera, *backCamera;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer  *previewLayer;
@property(nonatomic, strong) id<VideoHandlerDelegate, NSObject> delegate;
@property(nonatomic) BOOL disposed;


- (id)initWithRTPSession:(RTPSession *) _session;
- (void)setupCaptureSession;
-(int) fpsRead;
-(int) fpsWrite;
-(void) setResolution:(int) resolutionIndex;
-(void) removeCaptureVideoFrame;
-(void) clearReceiveBuffer;
-(int) switchCamera:(int) newCamera;
-(NSString *) currentReceiveRes;
-(NSString *) currentSendRes;
-(void) handleRTPEvent:(RTPPacket*) pkt;
-(BOOL) getDecodedVideoFrame:(NSMutableData *)decodedFrame frameInfo:(FrameInfo *) info  forStream:(VStream *) stream withOptions:(int) options;
-(VStream *) streamForSsrc:(unsigned long) ssrc;
-(void) removeVideoStream:(VStream *) stream;
-(BOOL) isStreamActive:(unsigned long) ssrc;
-(DDXMLElement *) streamInfoForSsrc:(unsigned long) ssrc;
-(BOOL) encodeAndTransferYUV:(UInt8 *) yPtr u:(UInt8 *)uPtr v:(UInt8 *)vPtr width:(int) width height:(int) height rotate:(int) rotate;
-(void) setPreviewView:(UIView *) preview adjustBounds:(BOOL) adjust;

+(RTPVideoHandler *) videoHandler;

@end
