//
//  SCBoard20Controller.h
//  C2CallPhone
//
//  Created by Michael Knecht on 21.11.17.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SCEventContentView, SCReplyToContentView, SCReplyToContainer;
@class SCBoardDataSource, SCBoardObject, SCBoard20Controller;
@class SCBoardObjectTimeHeader, SCBoardObjectCoreData, SCBoardObjectNewMessagesHeader;

@protocol SCBoard20ControllerDelegate<NSObject>

-(void) presentReplyToForEventId:(NSString *_Nonnull) eventId;

@end


@interface SCBoardObjectCell : UITableViewCell {
    void (^tapAction)(void);
    void (^longpressAction)(void);
    
    UITapGestureRecognizer      *tapGesture;
    UILongPressGestureRecognizer *longpressGesture;
}

@property(weak, nonatomic, nullable) SCBoard20Controller    *controller;
@property(weak, nonatomic, nullable) SCBoardObject          *boardObject;
@property(weak, nonatomic, nullable) IBOutlet UIView        *tapGestureView;

-(void) setTapAction:(void (^_Nullable)(void)) _tapAction;
-(void) setLongpressAction:(void (^_Nullable)(void)) _longpressAction;

@end

@interface SCBoardObjectTimeHeaderCell : SCBoardObjectCell

@property (weak, nonatomic, nullable) IBOutlet UILabel *timeInfoLabel;

@end

@interface SCBoardObjectSectionHeaderCell : SCBoardObjectCell

@property (weak, nonatomic, nullable) IBOutlet UILabel *sectionHeaderLabel;

@end

@interface SCBoardObjectNewMessagesHeaderCell : SCBoardObjectSectionHeaderCell

@end

@interface SCBoardObjectCoreDataCell : SCBoardObjectCell

@end

@interface SCBoardObjectEventCell : SCBoardObjectCoreDataCell {
    
    // MenuItem Actions
    void (^copyAction)(void);
    void (^answerAction)(void);
    void (^saveAction)(void);
    void (^showAction)(void);
    void (^forwardAction)(void);
    void (^retransmitAction)(void);
    void (^openLocationAction)(void);
    void (^shareAction)(void);
}

@property (weak, nonatomic, nullable) IBOutlet UIView                   *userNameView;
@property (weak, nonatomic, nullable) IBOutlet UIView                   *userImageView;
@property (weak, nonatomic, nullable) IBOutlet SCReplyToContainer       *replyToView;
@property (weak, nonatomic, nullable) IBOutlet UIView                   *rightView;

@property (weak, nonatomic, nullable) IBOutlet SCEventContentView *eventContentView;
@property (weak, nonatomic, nullable) IBOutlet UIView       *eventContentTimeView;
@property (weak, nonatomic, nullable) IBOutlet UIView       *eventCellTimeView;

@property (weak, nonatomic, nullable) IBOutlet UIStackView  *middleStack;
@property (weak, nonatomic, nullable) IBOutlet UIView       *bubbleView;

@property (weak, nonatomic, nullable) IBOutlet UIView       *topDistanceView;
@property (weak, nonatomic, nullable) IBOutlet UIView       *bottomDistanceView;

@property (weak, nonatomic, nullable) IBOutlet UILabel      *timeInfo;
@property (weak, nonatomic, nullable) IBOutlet UILabel      *cellTimeInfo;
@property (weak, nonatomic, nullable) IBOutlet UILabel      *userName;

@property (weak, nonatomic, nullable) IBOutlet UIImageView  *userImage;
@property (weak, nonatomic, nullable) IBOutlet UIImageView  *readStatus;
@property (weak, nonatomic, nullable) IBOutlet UIImageView  *cellReadStatus;
@property (weak, nonatomic, nullable) IBOutlet UIImageView  *bubbleTip;

@property (strong, nonatomic, nullable) NSString *eventContentXIB;
@property (strong, nonatomic, nullable) NSString *replyToEventId;

@property (strong, nonatomic, nullable) NSString            *transferKey;
@property (nonatomic) BOOL                                  transferMonitorActive;
@property (nonatomic) BOOL                                  retrievingVideoThumbnail;

-(void) setCopyAction:(void (^_Nullable)(void)) copyAction;
-(void) setAnswerAction:(void (^_Nullable)(void)) answerAction;
-(void) setShareAction:(void (^_Nullable)(void)) shareAction;
-(void) setSaveAction:(void (^_Nullable)(void)) saveAction;
-(void) setShowAction:(void (^_Nullable)(void)) showAction;
-(void) setForwardAction:(void (^_Nullable)(void)) forwardAction;
-(void) setRetransmitAction:(void (^_Nullable)(void)) retransmitAction;
-(void) setOpenLocationAction:(void (^_Nullable)(void)) openLocationAction;

-(void) showTransferProgress;
-(void) updateTransferProgress:(CGFloat) progress;
-(void) hideTransferProgress;

-(void) presentContentForKey:(NSString *_Nonnull) mediaKey withPreviewImage:(UIImage *_Nullable) previewImage;

-(void) startDownloadForKey:(NSString*_Nonnull) mediaKey;
-(void) monitorDownloadForKey:(NSString *_Nonnull) mediaKey;
-(void) retrieveVideoThumbnailForKey:(NSString*_Nonnull) mediaKey;
-(void) scrollToRepliedMessage;

@end

@interface SCBoardObjectEventCellIn : SCBoardObjectEventCell

@property (weak, nonatomic, nullable) IBOutlet UIButton *contentAction;
@property (weak, nonatomic, nullable) IBOutlet UIView *leftSpaceView;

- (IBAction)contentAction:(nullable id)sender;


@end

@interface SCBoardObjectEventCellOut : SCBoardObjectEventCell

@property (weak, nonatomic) IBOutlet UIImageView * _Nullable errorStatusImage;

@end


@interface SCBoard20Controller : UITableViewController

/** @name Properties */
/** Targetuserid (can be userId of phone number).
 
 Shows only messages of the defined friend or phone number contact.
 Can be nil.
 
 */
@property (nonatomic, strong, nullable) NSString * targetUserid;


@property(nonatomic, weak, nullable) id<SCBoard20ControllerDelegate> delegate;

/** Show Sender Name Header in Chat Cell
 
 Typically in Group Chats, Sender Names will be displayed on Chat Messages
 
 */

@property (nonatomic) BOOL useNameHeader;

/** Show Sender Image in Chat Cell
 
 Typically in Group Chats, Sender Images will be displayed on Chat Messages
 
 */
@property (nonatomic) BOOL useSenderImage;

/** Suppress Call Events in Event History
 
 SCChatController will set this to YES, to suppress Call Events
 in a person to person chat.
 */
@property (nonatomic) BOOL dontShowCallEvents;

@property(strong, nonatomic, nullable) SCBoardDataSource    *dataSource;
@property (nonatomic, strong, nonnull) NSCache              *smallImageCache;

-(nonnull NSString *) reuseIdentifierForBoardObject:(nonnull SCBoardObject *) bo atIndexPath:(nonnull NSIndexPath *) indexPath;

-(void) configureBoardBackground;
-(UIColor *_Nullable) textColorCellIn;
-(UIColor *_Nullable) textColorCellOut;
-(CGSize) maxPictureSize;
-(CGSize) maxVideoSize;
-(UIImage *_Nullable) previewImageForKey:(NSString *_Nonnull) mediaKey maxSize:(CGSize) sz;
-(UIColor *_Nullable) colorForMember:(NSString *) member;

-(void) configureEventContentColor:(SCBoardObjectEventCell *_Nonnull) cell;

-(void) configureTimeHeaderCell:(SCBoardObjectTimeHeaderCell *_Nonnull) cell forBoardObject:(SCBoardObjectTimeHeader *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureNewMessagesHeaderCell:(SCBoardObjectNewMessagesHeaderCell *_Nonnull) cell forBoardObject:(SCBoardObjectNewMessagesHeader *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureEventCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureEventCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureTextCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureTextCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configurePictureCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configurePictureCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureVideoCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureVideoCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureAudioCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureAudioCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureLocationCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureLocationCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureFileCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureFileCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureVCardCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureVCardCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureFriendCellIn:(SCBoardObjectEventCellIn *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;
-(void) configureFriendCellOut:(SCBoardObjectEventCellOut *_Nonnull) cell forBoardObject:(SCBoardObjectCoreData *_Nonnull) bo atIndexPath:(NSIndexPath *_Nonnull) indexPath;

-(void) configureCell:(nonnull SCBoardObjectCell *) cell forBoardObject:(nonnull SCBoardObject *) bo atIndexPath:(nonnull NSIndexPath *) indexPath;
-(void) transferCompletedForKey:(NSString *_Nullable) mediaKey onCell:(SCBoardObjectEventCell *_Nullable) cell;

-(void) contentAction:(nonnull SCBoardObjectEventCellIn *)cell;
-(void) scrollToMessageWithEventId:(NSString *_Nonnull) eventId;
-(void) updateCell:(UITableViewCell *) cell;

-(void) dispose;

-(BOOL) canShareWithApps:(NSString *_Nonnull) key;
-(void) shareWithApps:(NSString*_Nonnull) key;
-(void) shareEmail:(NSString *_Nonnull) key;
-(void) shareMessageForKey:(NSString *_Nonnull) key;
-(void) shareRichMessageForKey:(NSString *_Nonnull) key;
-(void) forwardMessage:(NSString *_Nonnull)message;
-(void) copyText:(NSString *_Nonnull) text;
-(void) copyVCard:(NSString *_Nonnull) vcard;
-(void) copyImageForKey:(NSString *_Nonnull) key;
-(void) copyLocationForKey:(NSString *_Nonnull) key;
-(void) copyMovieForKey:(NSString *_Nonnull) key;


@end


