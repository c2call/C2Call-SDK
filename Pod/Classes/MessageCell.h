//
//  MessageCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 27.01.09.
//  Copyright 2009 Actai Networks GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  FCLocation, C2TapImageView;

@interface MessageCell : UITableViewCell<UIGestureRecognizerDelegate> {
    UITapGestureRecognizer      *tapGesture;
    UILongPressGestureRecognizer *longpressGesture;
}

@property(nonatomic, weak) IBOutlet UIView                *bubbleView;
@property(nonatomic, weak) IBOutlet UIView                *videoBanner;
@property(nonatomic, weak) IBOutlet UIView                *messageImageView;
@property(nonatomic, weak) IBOutlet UIImageView           *iconSubmitted;
@property(nonatomic, weak) IBOutlet C2TapImageView        *userImage;
@property(nonatomic, weak) IBOutlet UITextView            *textfield;
@property(nonatomic, weak) IBOutlet UILabel               *headline;
@property(nonatomic, weak) IBOutlet UILabel               *duration;
@property(nonatomic, weak) IBOutlet UILabel               *locationAddress;
@property(nonatomic, weak) IBOutlet UILabel               *contactName;
@property(nonatomic, weak) IBOutlet UILabel               *info;
@property(nonatomic, weak) IBOutlet UIProgressView        *progress;
@property(nonatomic, weak) IBOutlet UIImageView           *messageImage;
@property(nonatomic, weak) IBOutlet UIImageView           *imageNewIndicator;
@property(nonatomic, weak) IBOutlet UIButton              *downloadButton;
@property(nonatomic, weak) IBOutlet UIButton              *locationTitle;
@property(nonatomic, weak) IBOutlet UIButton              *addFriendButton;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView              *activity;
@property(nonatomic, strong) NSString                       *downloadKey;
@property(nonatomic, strong) NSString                       *locationUrl;

-(void) startDownloadForKey:(NSString*) key;
-(void) monitorUploadForKey:(NSString *) key;
-(void) monitorDownloadForKey:(NSString *) key;
-(void) retrieveVideoThumbnailForKey:(NSString*) key;
-(void) retrieveLocation:(FCLocation *) loc;
-(void) setVCard:(NSString *) vcard;
-(NSDictionary *) queryParameters:(NSString *) query;

-(IBAction)download:(id)sender;
-(IBAction)openLocation:(id)sender;
-(void) setTapAction:(void (^)()) _tapAction;
-(void) setLongpressAction:(void (^)()) _longpressAction;

-(void) setCopyAction:(void (^)()) _copyAction;
-(void) setAnswerAction:(void (^)()) _answerAction;
-(void) setShareAction:(void (^)()) _shareAction;
-(void) setSaveAction:(void (^)()) _saveAction;
-(void) setShowAction:(void (^)()) _showAction;
-(void) setForwardAction:(void (^)()) _forwardAction;
-(void) setRetransmitAction:(void (^)()) _retransmitAction;
-(void) setOpenLocationAction:(void (^)()) _openLocationAction;

-(void) reset;
-(void) dispose;

@end
