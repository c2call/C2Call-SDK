//
//  SCEventContentView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 22.11.17.
//

#import <UIKit/UIKit.h>

@class FCLocation, SCPTTPlayer, C2BlockAction;

@interface SCEventContentView : UIView

-(void) prepareForReuse;
-(BOOL) showTransferProgress;
-(void) updateTransferProgress:(CGFloat) progress;
-(BOOL) hideTransferProgress;

-(void) presentContentForKey:(NSString *_Nonnull) mediaKey withPreviewImage:(UIImage *_Nullable) previewImage;

@end

@interface SCTextEventContentView : SCEventContentView {
    void (^dataTapAction)(NSString * _Nonnull type, NSObject * _Nullable dataObject);
    void (^dataLongPressAction)(NSString * _Nonnull type, NSObject * _Nullable dataObject);

}

@property(weak, nonatomic, nullable) IBOutlet UILabel   *contentText;

@property(strong, nonatomic, nullable) UITapGestureRecognizer   *tapDataDetectorGR;
@property(strong, nonatomic, nullable) UILongPressGestureRecognizer   *longPressDataDetectorGR;
@property(strong, nonatomic, nullable) NSMutableArray<NSDictionary<NSString*, NSObject *> *> *dataDetectors;

-(void) presentTextContent:(NSString *_Nullable) messageText withTextColor:(UIColor *_Nullable) textColor andDataDetector:(NSDictionary<NSString*, NSArray *> *_Nullable) dataDetector;
-(void) setDataTapAction:(void (^_Nullable)(NSString * _Nonnull type, NSObject * _Nullable dataObject)) action;
-(void) setDataLongPressAction:(void (^_Nullable)(NSString * _Nonnull type, NSObject * _Nullable dataObject)) action;

@end

@interface SCPictureEventContentView : SCTextEventContentView

@property(weak, nonatomic, nullable) IBOutlet UIImageView               *contentImage;
@property(weak, nonatomic, nullable) IBOutlet UIActivityIndicatorView   *activityView;

@end

@interface SCVideoEventContentView : SCPictureEventContentView

@property(weak, nonatomic, nullable) IBOutlet UILabel          *duration;
@property(weak, nonatomic, nullable) IBOutlet UIProgressView   *progress;

@end

@interface SCAudioEventContentView : SCTextEventContentView

@property(weak, nonatomic, nullable) IBOutlet UIImageView            *play;
@property(weak, nonatomic, nullable) IBOutlet UILabel                *duration;
@property(weak, nonatomic, nullable) IBOutlet UILabel                *elapsed;
@property(weak, nonatomic, nullable) IBOutlet UIProgressView         *progress;
@property(weak, nonatomic, nullable) IBOutlet UIActivityIndicatorView   *activityView;

/** Push To Talk Player
 */
@property(strong, nonatomic, nullable) SCPTTPlayer            *pttPlayer;


@end

@interface SCCallEventContentView : SCTextEventContentView

@property(weak, nonatomic, nullable) IBOutlet UIButton               *callVideo;
@property(weak, nonatomic, nullable) IBOutlet UIButton               *callAudio;

@end

@interface SCLocationEventContentView : SCPictureEventContentView

@property(weak, nonatomic, nullable) IBOutlet UILabel               *locationInfo;
@property(weak, nonatomic, nullable) IBOutlet UIView                *locationInfoView;

@property(strong, nonatomic, nullable) FCLocation                   *location;

-(void) presentContentForLocation:(FCLocation *_Nonnull) loc withPreviewImage:(UIImage *_Nullable) previewImage;

@end

@interface SCFileEventContentView : SCPictureEventContentView

@property(weak, nonatomic, nullable) IBOutlet UILabel               *fileInfo;
@property(weak, nonatomic, nullable) IBOutlet UILabel               *sizeInfo;
@property(weak, nonatomic, nullable) IBOutlet UILabel               *typeInfo;
@property(weak, nonatomic, nullable) IBOutlet UIImageView           *fileIcon;
@property(weak, nonatomic, nullable) IBOutlet UIView                *fileInfoView;
@property(weak, nonatomic, nullable) IBOutlet UIView                *progressView;
@property(weak, nonatomic, nullable) IBOutlet UIProgressView         *progress;

@property(strong, nonatomic, readonly, nullable) NSString *filename;

@end

@interface SCContactEventContentView : SCEventContentView

@property(weak, nonatomic, nullable) IBOutlet UIImageView           *contactImage;
@property(weak, nonatomic, nullable) IBOutlet UIImageView           *vcardSmall;
@property(weak, nonatomic, nullable) IBOutlet UIView           *vcardSmallView;

@property(weak, nonatomic, nullable) IBOutlet UILabel               *contactName;
@property(weak, nonatomic, nullable) IBOutlet UIButton              *saveContact;
@property(weak, nonatomic, nullable) IBOutlet UIButton              *messageContact;

@property(strong, nonatomic, nullable) C2BlockAction *saveAction;
@property(strong, nonatomic, nullable) C2BlockAction *messageAction;

-(IBAction)saveContact:(id _Nullable )sender;
-(IBAction)messageContact:(id _Nullable )sender;


@end
