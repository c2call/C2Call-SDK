//
//  SCMediaManager.h
//  C2Call SDK
//
//  Created by Michael Knecht on 20.06.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/** The SCMediaManager class is the shared instance for managing video capture sessions.
 
 The SCMediaManager class can be controlled by the application in order to hook into a video capture session during a video call and to receive the captured frames for further processing like face recognition.
 The C2Call SDK video call subsystem uses this class to request a capture session and register a AVCaptureVideoDataOutputSampleBufferDelegate. 
 Up to two AVCaptureVideoDataOutputSampleBufferDelegate can be registered for a video capture session.
 It's important that any additional video frame processing should be fast enough to allow a smoth video call with 10 - 20 frames per second. 
 Video frames consume a lot of memory. Please don't forget to run a profiler session on any additional video processing in order to detect potential memory leaks.

 */

@class GPUImageFilter;

@interface SCMediaManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

/** @name Properties */
/** Returns the current active video capture device (front or rear camera) */
@property(nonatomic, readonly, nullable) AVCaptureDevice    *videoCaptureDevice;

/** Returns the current active video capture session */
@property(nonatomic, readonly, nullable) AVCaptureSession     *videoCaptureSession;

@property(nonatomic, readonly) AVCaptureDevicePosition cameraPosition;

/** Soundfile path for hold the line announcement when the call is interrupted */
@property(nonatomic, strong, nullable)  NSString *holdTheLineSoundFilePath;

/** Donot use hold the line announcement when the call is interrupted */
@property(nonatomic) BOOL disableHoldTheLineAnnouncement;


/** Disable internal video capture session management 
 This option allows to setup and run the video capture session externally, in order to use tools like GPUImage for video image processing.
 The developer is then responsible  to call

 [[SCMediaManager instance] captureOutput:didOutputSampleBuffer:fromConnection:]
 
 with the processed video data for submission.
 */
@property(nonatomic) BOOL useExternalVideoCapture;

/** Enable/Disable GPUImage Video Capture
 C2Call API supports GPUImage Filtering for Video Capture. 
 With this feature enabled, GPUImageFilters can be applied to the video feed before sending it to the remote party.
 Other features like screen sharing, video recording will be disabled when using this feature.
 This property must be set before the call starts.
 
 The GPUImage library must be linked to the App, otherwise setting this property has no effect
 
 @see setGPUImageFilter:
 
 */
@property(nonatomic) BOOL useGPUImageVideoCapture;

/** Set a GPUImageFilter for video processing
 
 nil will remove a previously set filter.
 Setting a filter will automatically set useGPUImageVideoCapture = YES;
 
 Filter can be changed during a call if useGPUImageVideoCapture was YES before the call started.
 
 @param filter - The GPUImage Filter to be applied to all video frames
 @return YES - If GPU Image is available / NO if GPUImage library is not added to the project
 */
-(BOOL) setGPUImageFilter:(nullable GPUImageFilter *) filter;


/** Add a VideoDataOutput Delegate to the current capture session.
 
 If the capture session is already running, the delegate will be simply added and called for every available video frame;
 If the session is not running it can be started with startVideoCapture.
 Every delegate should stop only its own capture session, using stopVideoCaptureForDelegate.
 This also removes the delegate. 
 
 Stop all video output with stopVideoCapture. All delegates will be removed.
 
 @param delegate - The AVCaptureVideoDataOutputSampleBufferDelegate
 @return YES if delegate has been added, NO if max delegates have been reached.
 */
-(BOOL) addVideoDataOutputDelegate:(nonnull id<AVCaptureVideoDataOutputSampleBufferDelegate>) delegate;

/** Is front camera available.
 @return YES / NO
 */
-(BOOL) hasFrontCamera;

/** Is rear camera available.
 @return YES / NO
 */
-(BOOL) hasRearCamera;

/** Set current video caputre session preset
 @param sessionPreset - Video Capture Session Preset
 */
-(void) setVideoCaptureSessionPreset:(nonnull NSString *) sessionPreset;

/** Switch between cameras
 
 AVCaptureDevicePositionUnspecified stops the capture output temporary.
 
 @param The selected camera device
 @return Returns the new device or the old device if the camera couldn't be changed.
 */
-(AVCaptureDevicePosition) switchCamera:(AVCaptureDevicePosition) camera;

/** Returns the previewLayer.
 @return The camera preview layler.
 */
-(nullable AVCaptureVideoPreviewLayer *) previewLayer;

/** @name Media Background Sound Handling */
/** Start Background Audio during a call

 This feature will mix the recorded voice from microphone with the sound from an audio file
 before transferring it to the remote party in an audio or video call

 @param soundfilePath - Path to the sound file 
 @param loop - Repeat endless
 */
-(void) startBackgroundAudio:(nonnull NSString *) soundfilePath loopAudio:(BOOL) loop;

/** Stop Background Audio
*/
-(void) stopBackgroundAudio;

/** Set the audio volumes when mixing background audio
 *
 *  When mixing background audio, the audio streams for voice and the sound files 
 *  are being reduced or increased before beeing mixed.
 *  You can set the factor or reducing or increasing for each stream separately
 *  It's recomended to increase the voice and reduce the background sounds, so that 
 *  the voice is not being overtaken by the background sound.
 *  The actual recommended factors are
 *      voice:  1.2 - 1.3
 *      sound:  0.3 - 0.5
 *
 *  However this depends on the actual sound files for background audio and should be 
 *  checked experimentally for your own case.
 *  The default value is 1.0 / 1.0.
 *
 *  @param voice - Voice volume factor (Recommended Range: 1.0 - 1.5)
 *  @param sound - Sound volume factor (Recommended Range: 0.2 - 1.0)
 */
-(void) setBackgroundAudioVolumeForVoice:(float) voice andSound:(float) sound;

/** @name Media Capture Handling */

/** Setup Capture Sesession
 
 Initialize the VideoCapture Session
 
 */
-(void) setupCaptureSession;


/** Start Video Capture
 
 Does nothing if the session is already running.
 */
-(void) startVideoCapture;

/** Stop video capture for a specific delegate.
 
 The delegate will be removed. If it's the last delegate, the capture session will be stopped.
 
 @param delegate - The delegate to remove.
 */
-(void) stopVideoCaptureForDelegate:(nonnull id) delegate;

/** Remove all delegates and stop the capture session.
 */
-(void) stopVideoCapture;

/** Start a screenSharing session during an active video call
 
 @param shareView The view to be shared
 */
-(void) startScreenSharingForView:(nonnull UIView *) shareView;

/** Stop active screenSharing session
 
 */
-(void) stopScreenSharing;


/** Start Recording of the current MediaStream
 
 */
-(void) startMediaRecording;

/** Stop recording of the current media stream
 
 @param handler - The completion handler will be called with the mediaKey as parameter after completion
 */
-(void) stopMediaRecordingWithCompletionHandler:(nullable void (^)(NSString * _Nullable mediaKey))handler;


/** Start Recording of the current VoIP Audio Stream
 
 @param mediaType - Either AVFileTypeAppleM4A or AVFileTypeWAVE is supported
 */
-(void) startAudioRecording:(nonnull NSString *) mediaType;

/** Stop recording of the current VoIP Audio Stream
 
 @param handler - The completion handler will be called with the mediaKey as parameter after completion
 */
-(void) stopAudioRecordingWithCompletionHandler:(nullable void (^)(NSString * _Nullable mediaKey))handler;


/** Start ScreenCapture Recording of the provided UIView
 
 The provide view will be recorded as screen capture session into an MP4 video file.
 The view will be recorded with 10 frames / second.
 
 @param captureView - The view to be captured and recorded
 @param useAudio - Capture Audio from the microphone
 
 */
-(void) startScreenCaptureForView:(nonnull UIView *) captureView usingAudio:(BOOL) useAudio;

/** Stop recording of the current screen capture session
 
 @param handler - The completion handler will be called with the mediaKey as parameter after completion
 */

-(void) stopScreenCaptureWithCompletionHandler:(nullable void (^)(NSString * _Nullable mediaKey))handler;

/** Disable Audio / Video output while a capture session is running
 
 This is a global setting which will keep it's setting between 2 calls
 @param disable - Set YES to disable the Audio Video output, NO to re-enable
 */
-(void) disableMediaOutput:(BOOL) disable;

/** Disable Video output while a capture session is running

 This is a global setting which will keep it's setting between 2 calls

@param disable - Set YES to pause the Video output, NO to re-enable
*/
-(void) disableVideoOutput:(BOOL) disable;

/** Disable Audio output while a capture session is running

 This is a global setting which will keep it's setting between 2 calls

@param disable - Set YES to pause the Audio output, NO to re-enable
*/
-(void) disableAudioOutput:(BOOL) disable;

/** @name AVCaptureConnection properties */

/** A Boolean value that indicates whether the system should enable video stabilization when it is available.
 @param enable - Set to YES for enabling
 */
-(void) setVideoStabilizationWhenAvailable:(BOOL) enable;

/** The orientation of the video.

@see AVCaptureConnection videoOriantation

@param enable - The orientation
*/
-(void) setOrientation:(AVCaptureVideoOrientation) orientation;

/** For internal use only
 @param frameRate - The FrameRate
 */
-(void) setFrameRate:(int) frameRate;

/** Capture the current preview image
 
 Capture a still image recorded by the camera during a video call.
 
 @param handler - The completion handler
 */
-(void) capturePreviewImageWithCompletionHandler:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))handler;


/** Experimental, for internal use only
 
 Directly transfer YUV encoded data
 
 @param yPtr - ptr to Y data
 @param uPtr - ptr to U data
 @param vPtr - ptr to V data
 @param width - image width
 @param height - image height
 @param rotate - [0 .. 3] : rotate image 0, 90, 180 and 270 degrees
 */

-(void) encodeAndTransferYUV:(nonnull UInt8 *) yPtr u:(nonnull UInt8 *)uPtr v:(nonnull UInt8 *)vPtr width:(int) width height:(int) height rotate:(int) rotate;

/** Returns the next decoded video frame in YUV420 format
 
 The method will wait for the next frame and returns it in YUV420 format including size and rotation metadata
 
 Dictionary Keys:
    frame : NSData - The Frame data
    width : NSNumber - Image width
    height : NSNumber - Image height
    rotation : NSNumber - Rotation Value (0 - 3)
 
 IMPORTANT: Process the frame data before retrieving the next frame.
 The data buffer takes always only one frame and will be overwritten with the next frame
 
 @return dictionary with frame data or nil
 */
-(nullable NSDictionary *) getDecodedVideoFrame;

/** Initialize the default audio session
 */
-(void) regularAudioSession;

/** Initialize the recording audio session
 */
-(void) recordingAudioSession;

/** @name Static Methods */
/** Returns a share instance of SCMediaManager.
 
 @return The media manager.
 */
+(nonnull SCMediaManager *) instance;

/** Set the Default CaptureSession Preset
 
 SCMediaManager uses AVCaptureSessionPresetMedium when creating the AVCaptureSession by default.
 Use setDefaultCaptureSessionPreset: before accessing the instace first time to change the default capture session preset.
 
 @param preset - AVCaptureSessionPreset
 */
+(void) setDefaultCaptureSessionPreset:(nonnull NSString *) preset;

@end
