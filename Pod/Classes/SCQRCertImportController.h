//
//  SCQRCertImportController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 24.02.14.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class SCQRCertImportController;

@protocol SCQRCertImportControllerDelegate <NSObject>

@optional

- (void) scanViewController:(SCQRCertImportController *) aCtler didTabToFocusOnPoint:(CGPoint) aPoint;
- (void) scanViewController:(SCQRCertImportController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

@end


@interface SCQRCertImportController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<SCQRCertImportControllerDelegate> delegate;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTourch:(BOOL) aStatus;

@end

