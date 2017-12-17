//
//  SCBoard20Controller.m
//  C2CallPhone
//
//  Created by Michael Knecht on 21.11.17.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+SCCustomViewController.h"

#import "SCBoard20Controller.h"
#import "SCBoardDataSource.h"
#import "SCEventContentView.h"
#import "SCReplyToContentView.h"
#import "SocialCommunication.h"
#import "FCPlacesDetail.h"
#import "FCGeocoder.h"
#import "SCPTTPlayer.h"
#import "debug.h"

@implementation SCBoardObjectCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    NSLog(@"SCBoardTest:prepareForReuse");
    
    if (tapGesture) {
        [self.tapGestureView removeGestureRecognizer:tapGesture];
        [tapGesture removeTarget:self action:NULL];
        
        tapGesture = nil;
        tapAction = nil;
    }
    
    if (longpressGesture) {
        [self.tapGestureView removeGestureRecognizer:longpressGesture];
        [longpressGesture removeTarget:self action:NULL];
        
        longpressGesture = nil;
        longpressAction = nil;
    }
}

- (void)layoutSubviews
{
    
    if (!tapGesture && tapAction && self.tapGestureView) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.tapGestureView.userInteractionEnabled = YES;
        self.tapGestureView.multipleTouchEnabled = YES;
        [self.tapGestureView addGestureRecognizer:tapGesture];
    }
    
    if (!longpressGesture && longpressAction && self.tapGestureView) {
        longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongpress:)];
        [self addGestureRecognizer:longpressGesture];
        self.tapGestureView.userInteractionEnabled = YES;
        self.tapGestureView.multipleTouchEnabled = YES;
        [self.tapGestureView addGestureRecognizer:longpressGesture];
    }
    
    [super layoutSubviews];
}

-(void) setTapAction:(void (^)(void)) _tapAction;
{
    if (tapAction) {
    }
    tapAction = _tapAction;
    [self setNeedsLayout];
}


-(void) setLongpressAction:(void (^)(void)) _longpressAction;
{
    if (longpressAction) {
    }
    longpressAction = _longpressAction;
    [self setNeedsLayout];
}

-(void) dispose
{
    DLog(@"SCBoardObjectCell:dispose()");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.tapGestureView) {
        NSArray *list = [NSArray arrayWithArray:self.tapGestureView.gestureRecognizers];
        
        for (UIGestureRecognizer *gr in list) {
            [gr removeTarget:self action:NULL];
            [self.tapGestureView removeGestureRecognizer:gr];
        }
    }
    
    tapGesture = nil;
    longpressGesture = nil;
    
    tapAction = nil;
    longpressAction = nil;
    
}

-(void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        DLog(@"tapAction");
        
        if (tapAction) {
            tapAction();
        }
    }
}

-(void)handleLongpress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        DLog(@"longpressAction : %ld",(long) sender.state);
        
        if (longpressAction) {
            longpressAction();
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    DLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer : %@ / %@", gestureRecognizer, otherGestureRecognizer);
    return NO;
}

@end

@implementation SCBoardObjectTimeHeaderCell

@end

@implementation SCBoardObjectSectionHeaderCell

@end

@implementation SCBoardObjectNewMessagesHeaderCell

@end

@implementation SCBoardObjectCoreDataCell

@end

@implementation SCBoardObjectEventCell

-(void) prepareForReuse {
    [super prepareForReuse];
    
    [self.eventContentView prepareForReuse];
    
    self.topDistanceView.hidden = NO;
    self.bottomDistanceView.hidden = NO;
    self.boardObject = nil;
    
    self.retrievingVideoThumbnail = NO;
    if (self.transferKey) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.transferKey = nil;
        self.transferMonitorActive = NO;
        
        [self hideTransferProgress];
    }
    
    [self.replyToView setHidden:YES];
}

-(void) setEventContentView:(SCEventContentView *)eventContentView
{
    if (_eventContentView) {
        [self.middleStack removeArrangedSubview:_eventContentView];
        [_eventContentView removeFromSuperview];
    }
    
    if (eventContentView) {
        [self.middleStack insertArrangedSubview:eventContentView atIndex: 2];
    }
    
    _eventContentView = eventContentView;
}

-(void) setReplyToView:(SCReplyToContentView *)replyToView
{
    if (_replyToView) {
        [self.middleStack removeArrangedSubview:_replyToView];
        [_replyToView removeFromSuperview];
    }
    
    if (replyToView) {
        [self.middleStack insertArrangedSubview:replyToView atIndex: 1];
    }
    
    _replyToView = replyToView;
}

-(void) setCopyAction:(void (^)(void)) _copyAction;
{
    copyAction = _copyAction;
}

-(void) setShareAction:(void (^)(void)) _shareAction;
{
    shareAction = _shareAction;
}

-(void) setSaveAction:(void (^)(void)) _saveAction;
{
    saveAction = _saveAction;
}

-(void) setShowAction:(void (^)(void)) _showAction;
{
    showAction = _showAction;
}

-(void) setForwardAction:(void (^)(void)) _forwardAction;
{
    forwardAction = _forwardAction;
}

-(void) setRetransmitAction:(void (^)(void)) _retransmitAction;
{
    retransmitAction = _retransmitAction;
}

-(void) setOpenLocationAction:(void (^)(void)) _openLocationAction;
{
    openLocationAction = _openLocationAction;
}

-(void) setAnswerAction:(void (^)(void)) _answerAction;
{
    answerAction = _answerAction;
}

-(IBAction) copyAction:(id) sender
{
    if (copyAction)
        copyAction();
}

-(IBAction) answerAction:(id) sender
{
    if (answerAction)
        answerAction();
}

-(IBAction) shareAction:(id) sender
{
    if (shareAction)
        shareAction();
}

-(IBAction) saveAction:(id) sender
{
    if (saveAction)
        saveAction();
}

-(IBAction) forwardAction:(id) sender
{
    if (forwardAction)
        forwardAction();
}

-(IBAction) retransmitAction:(id) sender
{
    if (retransmitAction)
        retransmitAction();
}

-(IBAction) showAction:(id) sender
{
    if (showAction)
        showAction();
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copyAction:) && copyAction) {
        return YES;
    }
    
    if (action == @selector(shareAction:) && shareAction) {
        return YES;
    }
    
    if (action == @selector(showAction:) && showAction) {
        return YES;
    }
    
    if (action == @selector(forwardAction:) && forwardAction) {
        return YES;
    }
    
    if (action == @selector(saveAction:) && saveAction) {
        return YES;
    }
    
    if (action == @selector(retransmitAction:) && retransmitAction) {
        return YES;
    }
    
    if (action == @selector(answerAction:) && answerAction) {
        return YES;
    }
    
    return NO;
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(void) showTransferProgress;
{
    [self.eventContentView showTransferProgress];
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    [self.eventContentView updateTransferProgress:progress];
}

-(void) hideTransferProgress;
{
    [self.eventContentView hideTransferProgress];
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    [self.eventContentView presentContentForKey:mediaKey withPreviewImage:previewImage];
}

-(void) handleNotification:(NSNotification*) notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(handleNotification:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    if (self.transferKey && [[notification name] isEqualToString:self.transferKey]) {
        
        NSNumber *p = [notification.userInfo objectForKey:@"progress"];
        if (p) {
            [self showTransferProgress];
            
            [self updateTransferProgress:[p floatValue] / 100.];
        }
        
        NSNumber *finished = [notification.userInfo objectForKey:@"finished"];
        if (finished) {
            [self hideTransferProgress];
            
            NSString *key = self.transferKey;
            if ([finished boolValue] && self.transferKey) {
                
                UIImage *imageObject = [self.controller previewImageForKey:self.transferKey maxSize:[self.controller maxPictureSize]];
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                [self presentContentForKey:self.transferKey withPreviewImage:imageObject];
                self.transferKey = nil;
            }
            [self.controller transferCompletedForKey:key onCell:self];
            
        }
    }
}


-(void) startDownloadForKey:(NSString*) key
{
    DLog(@"startDownloadForKey : %@", key);
    if ([key rangeOfString:@"(null)"].location != NSNotFound) {
        return;
    }

    if (self.retrievingVideoThumbnail) {
        return;
    }
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:key]) {
        return;
    }

    
    if ([[C2CallPhone currentPhone] downloadStatusForKey:key]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.transferMonitorActive = NO;
    
    [self showTransferProgress];

    [self monitorDownloadForKey:key];
    
    
    BOOL res = [[C2CallPhone currentPhone] retrieveObjectForKey:key completion:^(BOOL finished) {
        if (finished) {
        }
    }];
    
    
    if (!res) {
        // Try once more
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"Retry retrieveObjectForKey!");
            BOOL result = [[C2CallPhone currentPhone] retrieveObjectForKey:key completion:^(BOOL finished) {
                if (finished) {
                }
            }];
            
            if (!result) {
                DLog(@"Failed to retrieve Object : %@", key);
            }
        });
    }
}

-(void) monitorDownloadForKey:(NSString *) key
{
    if ([key rangeOfString:@"(null)"].location != NSNotFound) {
        return;
    }
    
    if (self.transferMonitorActive) {
        return;
    }
    
    
    self.transferKey = key;
    self.transferMonitorActive = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:key object:nil];
    

    // Automatically show progress on next progress event...
}

-(void) retrieveVideoThumbnailForKey:(NSString*) mediaKey
{
    if (![mediaKey hasPrefix:@"video://"]) {
        DLog(@"Not a video object : %@", mediaKey);
        return;
    }
    
    if (self.retrievingVideoThumbnail) {
        DLog(@"Already retrieving : %@", mediaKey);
        return;
    }
    
    DLog(@"retrieveVideoThumbnailForKey : %@", mediaKey);
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        UIImage *image = [[C2CallPhone currentPhone] thumbnailForKey:mediaKey];
        [self presentContentForKey:mediaKey withPreviewImage:image];
        return;
    }

    self.retrievingVideoThumbnail = YES;
    self.transferKey = mediaKey;
    
    [self showTransferProgress];
    
    [[C2CallPhone currentPhone] retrieveVideoThumbnailForKey:mediaKey completionHandler:^(UIImage *thumbnail) {
        DLog(@"VideoThumbnail retrieved!");
        self.retrievingVideoThumbnail = NO;
        
        // Check whether the cell is still active for this key
        if ([self.transferKey isEqualToString:mediaKey]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage *thumb = thumbnail;
                if (!thumb) {
                    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
                    thumb = [UIImage imageNamed:@"ico_broken_video" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
                }
                [self presentContentForKey:mediaKey withPreviewImage:thumb];
                
                [self hideTransferProgress];
                
                [self.controller transferCompletedForKey:mediaKey onCell:self];
            });
            self.transferKey = nil;
        }
    }];
}

- (IBAction)shareContent:(id)sender {
}

-(void) retrieveLocation:(FCLocation *) loc
{
    
    
    if ([[C2CallPhone currentPhone] hasThumbnailForKey:loc.locationKey]) {
        UIImage *locationImage = [[C2CallPhone currentPhone] thumbnailForKey:loc.locationKey];
        if ([self.eventContentView isKindOfClass:[SCLocationEventContentView class]]) {
            SCLocationEventContentView *cv = (SCLocationEventContentView *) self.eventContentView;
            [cv presentContentForLocation:loc withPreviewImage:locationImage];
        } else {
            [self.eventContentView presentContentForKey:loc.locationKey withPreviewImage:locationImage];
        }
    } else {
        self.transferKey = loc.locationKey;
        [self showTransferProgress];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *locationImage = [[C2CallPhone currentPhone] thumbnailForKey:loc.locationKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.transferKey isEqualToString:loc.locationKey]) {
                    [self hideTransferProgress];
                    
                    if ([self.eventContentView isKindOfClass:[SCLocationEventContentView class]]) {
                        SCLocationEventContentView *cv = (SCLocationEventContentView *) self.eventContentView;
                        [cv presentContentForLocation:loc withPreviewImage:locationImage];
                    } else {
                        [self.eventContentView presentContentForKey:loc.locationKey withPreviewImage:locationImage];
                    }
                }
            });
        });
    }
    
    if (loc.reference && !loc.place) {
        FCPlacesDetail *placesDetail = [[FCPlacesDetail alloc] initWithReference:loc.reference andCompleteHandler:^(FCPlacesDetail *pd){
            loc.place = pd.place;
            [loc storeLocation];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controller transferCompletedForKey:loc.locationKey onCell:self];
            });
            
        }];
        if (placesDetail) {
            
        }
    }
    
    if (!loc.address && !loc.reference) {
        FCGeocoder *geocoder = [[FCGeocoder alloc] initWithLocation:loc andCompleteHandler:^(FCGeocoder *gc){
            if ([gc.placesList count] > 0) {
                loc.geoLocation = [gc.placesList objectAtIndex:0];
                loc.address = [loc.geoLocation objectForKey:@"address"];
                [loc storeLocation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controller transferCompletedForKey:loc.locationKey onCell:self];
                });
            }
        }];
        if (geocoder) {
            
        }
    }
}

@end

@implementation SCBoardObjectEventCellIn

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.contentAction.hidden = YES;
    self.readStatus.hidden = YES;
    [self.eventContentTimeView setNeedsLayout];
}

- (IBAction)contentAction:(id)sender {
    
    [self.controller contentAction:self];
}

@end

@implementation SCBoardObjectEventCellOut

-(void) prepareForReuse {
    [super prepareForReuse];
    
    self.readStatus.hidden = NO;
    self.errorStatusImage.image = nil;
}

-(void) monitorUploadForKey:(NSString *) key
{
    if ([key rangeOfString:@"(null)"].location != NSNotFound) {
        return;
    }
    
    self.transferKey = key;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:key object:nil];
}


@end


@interface SCBoard20Controller ()<SCBoardDataSourceDelegate, MFMailComposeViewControllerDelegate>

@property(strong, nonatomic) NSDateFormatter    *timeFormatter;
@property(nonatomic) BOOL                   scrollToBottom;
@property(nonatomic) BOOL                   loadingPreviousMessages;
@property(strong, nonatomic) NSIndexPath    *lastVisibleRow;

@property(strong, nonatomic) NSMutableDictionary *cellHeightsDictionary;
@property(strong, nonatomic) NSMutableArray     *animationIcon;
@property(strong, nonatomic) NSMutableArray     *animationIconWhite;
@property(strong, nonatomic) NSMutableDictionary<NSString*, UIColor*>   *colorMap;
@property(strong, nonatomic) NSArray<UIColor*>   *colorList;
@property(nonatomic) NSUInteger    colorNum;
@property(nonatomic) NSInteger    lastContentOffset;
@property(nonatomic) BOOL   isGroup;
@property(strong, nonatomic) NSCache            *previewImageCache;

@end

@implementation SCBoard20Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellHeightsDictionary = [NSMutableDictionary dictionary];
    self.colorMap = [NSMutableDictionary dictionary];
    self.previewImageCache = [[NSCache alloc] init];
    
    self.animationIcon = [[NSMutableArray alloc] initWithCapacity:4];
    [self.animationIcon addObject:[UIImage imageNamed:@"ico_sending_0"]];
    [self.animationIcon addObject:[UIImage imageNamed:@"ico_sending_1"]];
    [self.animationIcon addObject:[UIImage imageNamed:@"ico_sending_2"]];
    [self.animationIcon addObject:[UIImage imageNamed:@"ico_sending_3"]];

    self.animationIconWhite = [[NSMutableArray alloc] initWithCapacity:4];
    [self.animationIconWhite addObject:[UIImage imageNamed:@"ico_sending_0_white"]];
    [self.animationIconWhite addObject:[UIImage imageNamed:@"ico_sending_1_white"]];
    [self.animationIconWhite addObject:[UIImage imageNamed:@"ico_sending_2_white"]];
    [self.animationIconWhite addObject:[UIImage imageNamed:@"ico_sending_3_white"]];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [self configureBoardBackground];
    
    self.tableView.estimatedRowHeight = 50.;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.smallImageCache = [[NSCache alloc] init];
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.dataSource = [[SCBoardDataSource alloc] init];
    self.dataSource.delegate = self;
    self.dataSource.targetUserid = self.targetUserid;
    self.dataSource.dontShowCallEvents = self.dontShowCallEvents;
    
    self.scrollToBottom = YES;
    
    if (self.targetUserid) {
        self.isGroup = [[C2CallPhone currentPhone] isGroupUser:self.targetUserid];
    }
    
    [self.dataSource layzInitialize];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.targetUserid) {
        [[SCDataManager instance] resetMissedMessagesForContact:self.targetUserid];
        
        if (!self.dontShowCallEvents) {
            [[SCDataManager instance] resetMissedCallsForContact:self.targetUserid];
        }
    }

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onKeyboardWillShow:(NSNotification *) notification
{
    NSArray<NSIndexPath *> *visibleRows = [self.tableView indexPathsForVisibleRows];
    
    if (visibleRows) {
        self.lastVisibleRow = [visibleRows lastObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onKeyboardDidShow:nil];
        });
    }
}

-(void) onKeyboardDidShow:(NSNotification *) notification
{
    if (self.lastVisibleRow) {
        [self.tableView scrollToRowAtIndexPath:self.lastVisibleRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        self.lastVisibleRow = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.dataSource numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInSection:section];
}

-(BOOL) isInboundMessage:(SCBoardObjectCoreData *) msg
{
    NSString *eventType = msg.dataObject.eventType;
    
    if ([eventType isEqualToString:@"MessageIn"] || [eventType isEqualToString:@"CallIn"]) {
        return true;
    }
    
    return false;
}

-(NSString *) eventContentXIBMessageObject:(SCBoardObjectCoreData *) msg
{
    
    if ([msg.dataObject.eventType isEqualToString:@"CallIn"] || [msg.dataObject.eventType isEqualToString:@"CallOut"]) {
        return @"SCCallEvent";
    }
    
    SCRichMediaType rmType = [[C2CallPhone currentPhone] mediaTypeForKey:msg.dataObject.text];
    switch (rmType) {
        case SCMEDIATYPE_IMAGE:
            return @"SCPictureEvent";
        case SCMEDIATYPE_VIDEO:
            return @"SCVideoEvent";
        case SCMEDIATYPE_VOICEMAIL:
            return @"SCAudioEvent";
        case SCMEDIATYPE_VCARD:
            return @"SCContactEvent";
        case SCMEDIATYPE_FILE:
            return @"SCFileEvent";
        case SCMEDIATYPE_FRIEND:
            return @"SCTextEvent";
        case SCMEDIATYPE_LOCATION:
            return @"SCLocationEvent";
        case SCMEDIATYPE_BROADCAST:
        default: // Text
            return @"SCTextEvent";
    }
}

-(NSString *) replyToContentXIBMessageObject:(SCBoardObjectCoreData *) msg
{
    return nil;
}

-(void) loadEventContentXIB:(SCBoardObjectEventCell *) cell forBoardObject:(SCBoardObjectCoreData *) bo
{
    NSString *xibFile = [self eventContentXIBMessageObject:bo];
    NSLog(@"SCBoardTest:loadEventContentXIB: %@",xibFile);
    if ([cell.eventContentXIB isEqualToString:xibFile]) {
        // Resued Cell with right content, do nothing
        NSLog(@"SCBoardTest:loadEventContentXIB: %@ - Already Loaded",xibFile);
        return;
    }
    
    cell.eventContentTimeView = nil;
    
    // Restore CellViews
    cell.timeInfo = cell.cellTimeInfo;
    cell.readStatus = cell.cellReadStatus;
    
    cell.eventContentXIB = xibFile;
    
    UINib *nib = nil;
    if ([[NSBundle mainBundle] pathForResource:xibFile ofType:@"nib"]) {
        nib = [UINib nibWithNibName:xibFile bundle:nil];
    }
    
    if (!nib) {
        nib = [UINib nibWithNibName:xibFile bundle:[NSBundle bundleForClass:[self class]]];
    }
    
    [nib instantiateWithOwner:cell options:nil];
    [cell.eventContentView prepareForReuse];
    
    //[cell.eventContentView.superview setNeedsUpdateConstraints];
    //[cell.eventContentView.superview updateConstraintsIfNeeded];
}

-(void) loadReplyToContentXIB:(SCBoardObjectEventCell *) cell forBoardObject:(SCBoardObjectCoreData *) bo
{
    NSString *xibFile = [self replyToContentXIBMessageObject:bo];
    if (!xibFile) {
        return;
    }
    UINib *nib = [UINib nibWithNibName:xibFile bundle:nil];
    [nib instantiateWithOwner:cell options:nil];
}

-(NSString *) reuseIdentifierForBoardObject:(SCBoardObject *) bo atIndexPath:(NSIndexPath *) indexPath;
{
    if ([bo isKindOfClass:[SCBoardObjectTimeHeader class]]) {
        return @"SCBoardObjectTimeHeaderCell";
    }
    
    if ([bo isKindOfClass:[SCBoardObjectNewMessagesHeader class]]) {
        return @"SCBoardObjectNewMessagesHeaderCell";
    }
    
    if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
        
        if ([self isInboundMessage:(SCBoardObjectCoreData *) bo]) {
            return @"SCBoardObjectEventCellIn";
        } else {
            return @"SCBoardObjectEventCellOut";
        }
    }
    
    if ([bo isKindOfClass:[SCBoardObjectNewMessagesHeader class]]) {
        return @"SCBoardObjectNewMessagesHeaderCell";
    }
    
    
    
    return @"SCBoardObject";
}

-(BOOL) isPhoneNumber:(NSString *) uid
{
    if ([uid hasPrefix:@"+"] && [uid rangeOfString:@"@"].location == NSNotFound) {
        return YES;
    }
    return NO;
}

-(UIImage *) imageForElement:(MOC2CallEvent *) elem
{
    NSString *contact = elem.originalSender;
    if (!contact) {
        contact = elem.contact;
    }
    UIImage *image = [self.smallImageCache objectForKey:contact];
    if (image)
        return image;
    
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    image = [[C2CallPhone currentPhone] userimageForUserid:contact];
    if (image) {
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:17.5];
        [self.smallImageCache setObject:image forKey:contact];
        return image;
    }
    
    if ([self isPhoneNumber:contact]) {
        image = [UIImage imageNamed:@"btn_ico_adressbook_contact" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:17.5];
        [self.smallImageCache setObject:image forKey:contact];
        return image;
    }
    
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:contact];
    if ([user.userType intValue] == 2) {
        image = [UIImage imageNamed:@"btn_ico_avatar_group" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:17.5];
        [self.smallImageCache setObject:image forKey:contact];
        return image;
        
    }
    
    image = [UIImage imageNamed:@"btn_ico_avatar" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
    image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
    [self.smallImageCache setObject:image forKey:contact];
    return image;
}

#pragma mark Configure TableViewCells

-(void) configureBoardBackground
{
}

-(UIColor *) textColorCellIn
{
    return [UIColor darkGrayColor];
}

-(UIColor *) textColorCellOut
{
    return [UIColor whiteColor];
}

-(CGSize) maxPictureSize
{
    return CGSizeMake(240, 240);
}

-(CGSize) maxVideoSize
{
    return CGSizeMake(240, 240);
}

-(UIImage *) previewImageForKey:(NSString *) mediaKey maxSize:(CGSize) sz
{
    UIImage *img = [self.previewImageCache objectForKey:mediaKey];
    if (img) {
        return img;
    }
    
    img = [[C2CallPhone currentPhone] thumbnailForKey:mediaKey];
    
    if (!img) {
        return nil;
    }
    
    
    if (img.size.width > sz.width || img.size.height > sz.height) {
        if (sz.width > sz.height) {
            img = [ImageUtil thumbnailFromImage:img withSize:sz.width];
        } else {
            img = [ImageUtil thumbnailFromImage:img withSize:sz.height];
        }
    }

    [self.previewImageCache setObject:img forKey:mediaKey];
    return img;
}

-(void) configureTimeHeaderCell:(SCBoardObjectTimeHeaderCell *) cell forBoardObject:(SCBoardObjectTimeHeader *) bo atIndexPath:(NSIndexPath *) indexPath
{
    cell.timeInfoLabel.text = bo.timeHeader;
}

-(void) configureNewMessagesHeaderCell:(SCBoardObjectNewMessagesHeaderCell *) cell forBoardObject:(SCBoardObjectNewMessagesHeader *) bo atIndexPath:(NSIndexPath *) indexPath
{
    cell.sectionHeaderLabel.text = bo.sectionHeader;
}

-(NSDictionary<NSString *, NSArray*> *) dataDetectorAction:(NSString *) messageText
{
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
    NSArray *matches = [detector matchesInString:messageText
                                         options:0
                                           range:NSMakeRange(0, [messageText length])];
    
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:10];
    
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            [links addObject:url];
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            [numbers addObject:phoneNumber];
        }
    }
    
    NSMutableDictionary<NSString *, NSArray*> *result = [NSMutableDictionary dictionaryWithCapacity:2];
    if ([links count] > 0) {
        result[@"url"] = links;
    }
    
    if ([numbers count] > 0) {
        result[@"phone"] = numbers;
    }
    
    if ([result count] > 0) {
        return result;
    }
    
    return nil;
}

-(void) configureEventCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    MOC2CallEvent *elem = bo.dataObject;
    
    cell.boardObject = bo;
    
    cell.userImage.image = [self imageForElement:elem];
    cell.userImage.hidden = bo.sameSenderOnPreviousMessage;
    
    cell.userImageView.hidden = !self.useSenderImage;
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    cell.userName.text = sendername;
    cell.userName.textColor = [self colorForMember:elem.originalSender? elem.originalSender: elem.contact];
    
    if (self.useNameHeader) {
        cell.userNameView.hidden = bo.sameSenderOnPreviousMessage;
    } else {
        cell.userNameView.hidden = YES;
    }
    
    cell.topDistanceView.hidden = bo.sameSenderOnPreviousMessage;
    
    
    cell.bubbleTip.hidden = bo.sameSenderOnPreviousMessage && self.isGroup;
    
    cell.timeInfo.text = [self.timeFormatter stringFromDate:elem.timeStamp];
    cell.readStatus.hidden = YES;
    
    if ([bo.dataObject.eventType isEqualToString:@"MessageIn"] && [bo.dataObject.status intValue] < 4) {
        [[SCDataManager instance] markAsRead:elem];
    }
    if (cell.eventContentTimeView) {
        cell.eventCellTimeView.hidden = YES;
    } else {
        cell.eventCellTimeView.hidden = NO;
    }
}

-(void) configureEventCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    MOC2CallEvent *elem = bo.dataObject;
    
    cell.boardObject = bo;
    
    [cell.userNameView setHidden:YES];
    cell.timeInfo.text = [self.timeFormatter stringFromDate:elem.timeStamp];
    
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    int status = [elem.status intValue];
    if (status == 3) {
        cell.errorStatusImage.image = [UIImage imageNamed:@"ico_notdelivered" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        cell.readStatus.hidden = YES;
        return;
    }
    
    cell.topDistanceView.hidden = bo.sameSenderOnPreviousMessage;
    cell.bubbleTip.hidden = bo.sameSenderOnPreviousMessage && self.isGroup;
    cell.readStatus.hidden = NO;

    SCRichMediaType rtype = [[C2CallPhone currentPhone] mediaTypeForKey:bo.dataObject.text];
    
    BOOL isImage = rtype == SCMEDIATYPE_IMAGE;
    [self setSubmittedStatusIcon:cell.readStatus forStatus:status isImage:isImage];
    
    if (cell.eventContentTimeView) {
        cell.eventCellTimeView.hidden = YES;
    } else {
        cell.eventCellTimeView.hidden = NO;
    }
}

-(BOOL) prepareDataDetectorAction:(NSDictionary<NSString *, NSArray*> *) dataDetector forCell:(SCBoardObjectEventCell *) cell
{
    NSArray<NSURL *> *links = dataDetector[@"url"];
    NSArray<NSString *> *numbers = dataDetector[@"phone"];
    
    
    if ([links count] > 0 || [numbers count] > 0) {
        if ([links count] == 1 && [numbers count] == 0) {
            
            NSURL *url = links[0];
            [cell setTapAction:^{
                [[UIApplication sharedApplication] openURL:url];
            }];
            return YES;
        }
        
        [cell setTapAction:^{
            SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
            
            for (NSURL *url in links) {
                [cv addChoiceWithName:NSLocalizedString(@"Open URL", @"Choice Title") andSubTitle:[url absoluteString] andIcon:[UIImage imageNamed:@"ico_webmail_import"] andCompletion:^()
                 {
                     [[UIApplication sharedApplication] openURL:url];
                 }];
                
            }
            
            for (NSString *phoneNumber in numbers) {
                NSString *intlNumber = [SIPUtil normalizePhoneNumber:phoneNumber];
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Call Number", @"MenuItem")];
                
                [cv addChoiceWithName:title andSubTitle:intlNumber andIcon:[UIImage imageNamed:@"btn_ico_call"] andCompletion:^{
                    [[SIPPhone currentPhone] callNumber:phoneNumber];
                }];
            }
            
            [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
            }];
            
            [cv showMenu];
        }];
        
        return YES;
    }

    return NO;
}

-(void) configureTextCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    NSString *text = bo.dataObject.text;
    
    NSDictionary<NSString *, NSArray*> *dataDetector = [self dataDetectorAction:text];
    
    if (dataDetector) {
        [self prepareDataDetectorAction:dataDetector forCell:cell];
    }

    [cell setLongpressAction:^{
        [self showLongpressMenuForCell:weakcell withMediaKey:text];
    }];
    
    if ([cell.eventContentView isKindOfClass:[SCTextEventContentView class]]) {
        SCTextEventContentView *cv = (SCTextEventContentView *) cell.eventContentView;
        
        [cv presentTextContent:text  withTextColor:[self textColorCellIn] andDataDetector:dataDetector];
    }
}

-(void) configureTextCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    NSString *text = [bo.dataObject.text copy];
    
    NSDictionary<NSString *, NSArray*> *dataDetector = [self dataDetectorAction:text];
    
    if (dataDetector) {
        [self prepareDataDetectorAction:dataDetector forCell:cell];
    }

    [cell setLongpressAction:^{
        [self showLongpressMenuForCell:weakcell withMediaKey:text];
    }];
    
    if ([cell.eventContentView isKindOfClass:[SCTextEventContentView class]]) {
        SCTextEventContentView *cv = (SCTextEventContentView *) cell.eventContentView;
        [cv presentTextContent:text  withTextColor:[self textColorCellOut] andDataDetector:[self dataDetectorAction:text]];
    }
    
}

-(void) configurePictureCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    
    cell.contentAction.hidden = NO;
    
    NSString *mediaKey = bo.dataObject.text;
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxPictureSize]];
        
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        [cell setTapAction:^{
            [self showImage:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_image" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            
        } else {
            [cell startDownloadForKey:mediaKey];
        }
    }
    
}

-(void) configurePictureCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        
        UIImage *image = [[C2CallPhone currentPhone] imageForKey:mediaKey];
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [self setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
            }];
            
            return;
        }
        
        cell.readStatus.image = nil;
        [cell monitorUploadForKey:mediaKey];
        return;
    }
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxPictureSize]];
        
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        [cell setTapAction:^{
            [weakcell.controller showImage:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_image" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            
        } else {
            [weakcell startDownloadForKey:mediaKey];
        }
    }
}

-(void) configureVideoCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    
    cell.contentAction.hidden = NO;

    BOOL failed = NO, hasVideo = NO;
    NSString *mediaKey = bo.dataObject.text;
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxVideoSize]];
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        hasVideo = YES;
    } else {
        UIImage *thumb = [self previewImageForKey:mediaKey maxSize:[self maxVideoSize]];

        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_video" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        } else {
            if (!thumb) {
                [cell retrieveVideoThumbnailForKey:mediaKey];
            }
        }
    }
    
    if (!failed && hasVideo) {
        [cell setTapAction:^{
            [self showVideo:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
        
        return;
    }
    
    if (!failed && !hasVideo) {
        [cell setTapAction:^{
            [weakcell startDownloadForKey:mediaKey];
        }];
    }
    
}

-(void) configureVideoCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxVideoSize]];

        [cell presentContentForKey:mediaKey withPreviewImage:image];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [self setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
            }];
            
            return;
        }
        
        cell.readStatus.image = nil;
        [cell monitorUploadForKey:mediaKey];
        return;
    }
    
    BOOL failed = NO, hasVideo = NO;
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxVideoSize]];
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        hasVideo = YES;
    } else {
        UIImage *thumb = [self previewImageForKey:mediaKey maxSize:[self maxVideoSize]];

        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_image" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        } else {
            if (!thumb) {
                [cell retrieveVideoThumbnailForKey:mediaKey];
            }
        }
    }
    
    
    if (!failed && hasVideo) {
        [cell setTapAction:^{
            [self showVideo:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
        return;
    }
    
    if (!failed && !hasVideo) {
        [cell setTapAction:^{
            [weakcell startDownloadForKey:mediaKey];
        }];
    }
}

-(void) configureAudioCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    
    cell.contentAction.hidden = NO;

    BOOL failed = NO, hasAudio = NO;
    NSString *mediaKey = bo.dataObject.text;

    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        hasAudio = YES;
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_voice_msg" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        } else {
            [weakcell startDownloadForKey:mediaKey];
        }
    }
    
    if (!failed && hasAudio) {
        
        if ([cell.eventContentView isKindOfClass:[SCAudioEventContentView class]]) {
            __weak SCAudioEventContentView *ev = (SCAudioEventContentView *) cell.eventContentView;
            
            if (ev.pttPlayer) {
                if ([ev.pttPlayer.mediaKey isEqualToString:mediaKey]) {
                    ev.pttPlayer.progress = ev.progress;
                    ev.pttPlayer.playButton = ev.play;
                }
                
            }
            
            [cell setTapAction:^{
                if (ev.pttPlayer) {
                    if ([ev.pttPlayer.mediaKey isEqualToString:mediaKey]) {
                        if ([ev.pttPlayer isPlaying]) {
                            [ev.pttPlayer pause];
                        } else {
                            [ev.pttPlayer play];
                        }
                    } else {
                        if ([ev.pttPlayer isPlaying]) {
                            [ev.pttPlayer pause];
                        }
                        ev.pttPlayer = nil;
                        ev.pttPlayer = [[SCPTTPlayer alloc] initWithMediaKey:mediaKey];
                        ev.pttPlayer.progress = ev.progress;
                        ev.pttPlayer.playButton = ev.play;
                        [ev.pttPlayer play];
                    }
                } else {
                    ev.pttPlayer = nil;
                    ev.pttPlayer = [[SCPTTPlayer alloc] initWithMediaKey:mediaKey];
                    ev.pttPlayer.progress = ev.progress;
                    ev.pttPlayer.playButton = ev.play;
                    [ev.pttPlayer play];
                }
                
            }];
        }
        
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
        
        return;
    }
    
    if (!failed && !hasAudio) {
        [cell setTapAction:^{
            //[weakcell startDownloadForKey:mediaKey];
        }];
    }

}

-(void) configureAudioCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [self setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
            }];
            
            return;
        }
        
        cell.readStatus.image = nil;
        [cell monitorUploadForKey:mediaKey];
        return;
    }
    
    BOOL failed = NO, hasAudio = NO;
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        hasAudio = YES;
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_voice_msg" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        } else {
            [weakcell startDownloadForKey:mediaKey];
        }
    }
    
    if (!failed && hasAudio) {
        
        if ([cell.eventContentView isKindOfClass:[SCAudioEventContentView class]]) {
            __weak SCAudioEventContentView *ev = (SCAudioEventContentView *) cell.eventContentView;
            
            if (ev.pttPlayer) {
                if ([ev.pttPlayer.mediaKey isEqualToString:mediaKey]) {
                    ev.pttPlayer.progress = ev.progress;
                    ev.pttPlayer.playButton = ev.play;
                }

            }
            
            [cell setTapAction:^{
                if (ev.pttPlayer) {
                    if ([ev.pttPlayer.mediaKey isEqualToString:mediaKey]) {
                        if ([ev.pttPlayer isPlaying]) {
                            [ev.pttPlayer pause];
                        } else {
                            [ev.pttPlayer play];
                        }
                    } else {
                        if ([ev.pttPlayer isPlaying]) {
                            [ev.pttPlayer pause];
                        }
                        ev.pttPlayer = nil;
                        ev.pttPlayer = [[SCPTTPlayer alloc] initWithMediaKey:mediaKey];
                        ev.pttPlayer.progress = ev.progress;
                        ev.pttPlayer.playButton = ev.play;
                        [ev.pttPlayer play];
                    }
                } else {
                    ev.pttPlayer = nil;
                    ev.pttPlayer = [[SCPTTPlayer alloc] initWithMediaKey:mediaKey];
                    ev.pttPlayer.progress = ev.progress;
                    ev.pttPlayer.playButton = ev.play;
                    [ev.pttPlayer play];
                }
                
            }];
        }
        
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
        
        return;
    }
    
    if (!failed && !hasAudio) {
        [cell setTapAction:^{
            //[weakcell startDownloadForKey:mediaKey];
        }];
    }
    
}

-(void) configureLocationCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    
    cell.contentAction.hidden = NO;

    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:mediaKey];
    [cell retrieveLocation:loc];
    
    [cell setOpenLocationAction:^{
        if (loc.locationUrl) {
            NSString *name = [loc.place objectForKey:@"name"];
            [self openBrowserWithUrl:loc.locationUrl andTitle:name];
        }
    }];
    
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    [cell setTapAction:^{
        [self showLocation:mediaKey forUser:sendername];
    }];
    
    [cell setLongpressAction:^{
        [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
    }];
    
}

-(void) configureLocationCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:mediaKey];
    [cell retrieveLocation:loc];
    
    [cell setOpenLocationAction:^{
        if (loc.locationUrl) {
            NSString *name = [loc.place objectForKey:@"name"];
            [self openBrowserWithUrl:loc.locationUrl andTitle:name];
        }
    }];
    
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    [cell setTapAction:^{
        [self showLocation:mediaKey forUser:sendername];
    }];
    
    [cell setLongpressAction:^{
        [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
    }];
    
    
}


-(void) configureFileCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    
    BOOL failed = NO, hasFile = NO;
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    cell.contentAction.hidden = NO;

    
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        hasFile = YES;
    } else {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_video" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        }
    }
    
    if (!failed && hasFile) {
        [cell setTapAction:^{
            [self showDocument:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
        
        return;
    }
    
    if (!failed && !hasFile) {
        [cell setTapAction:^{
            [weakcell startDownloadForKey:mediaKey];
        }];
    }
    
}

-(void) configureFileCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    
    BOOL failed = NO, hasFile = NO;
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [self setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
            }];
            
            return;
        }
        
        cell.readStatus.image = nil;
        [cell monitorUploadForKey:mediaKey];
        return;
    }
    
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        hasFile = YES;
    } else {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
            
            UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_video" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [self setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        }
    }
    
    if (!failed && hasFile) {
        [cell setTapAction:^{
            [self showDocument:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
        
        return;
    }
    
    if (!failed && !hasFile) {
        [cell setTapAction:^{
            [weakcell startDownloadForKey:mediaKey];
        }];
    }
    
}

-(void) configureVCardCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    cell.contentAction.hidden = NO;

    __weak SCBoardObjectEventCellIn *weakcell = cell;
    
    NSArray *personArray = nil;
    ABRecordRef person = NULL;
    
    BOOL failed = NO;
    
    NSString *vcard = bo.dataObject.text;
    @try {
        
        NSData *data = nil;
        if ([vcard hasPrefix:@"vcard://"]) {
            if (![[C2CallPhone currentPhone] hasObjectForKey:vcard]) {
                if ([[C2CallPhone currentPhone] downloadStatusForKey:vcard]) {
                    [cell monitorDownloadForKey:vcard];
                } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:vcard]) {
                    // We need a broken link image here and a download button
                    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
                    
                    UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_vcard" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
                    [cell presentContentForKey:vcard withPreviewImage:brokenImage];
                    
                    [cell setLongpressAction:^{
                        [self setRetransmitDownloadActionForCell:weakcell withMediaKey:vcard];
                    }];
                    failed = YES;
                } else {
                    [cell startDownloadForKey:vcard];
                }

                [cell presentContentForKey:NSLocalizedString(@"Loading...", @"VCARD") withPreviewImage:nil];

                return;
            } else {
                NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:vcard];
                data = [NSData dataWithContentsOfURL:url];
            }
        } else {
            data = [vcard dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if ([data length] == 0) {
            DLog(@"VCARD is empty");
            [cell presentContentForKey:NSLocalizedString(@"Empty VCARD", @"VCARD") withPreviewImage:nil];
            return;
        }
        
        
        personArray = (NSArray *) CFBridgingRelease(ABPersonCreatePeopleInSourceWithVCardRepresentation(NULL,(__bridge CFDataRef) data));
        person = (__bridge ABRecordRef)([personArray objectAtIndex:0]);
        
        NSString *compositName =  (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
        CFDataRef imageData = ABPersonCopyImageData(person);
        UIImage *vcardImage = nil;
        
        if (imageData != NULL) {
            vcardImage = [UIImage imageWithData:(__bridge NSData *)imageData];
            CFRelease(imageData);
        }
        [cell presentContentForKey:compositName withPreviewImage:vcardImage];
        
        [cell setTapAction:^{
            [self showContact:vcard];
        }];
        
        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:vcard];
        }];
        
        if ([cell.eventContentView isKindOfClass:[SCContactEventContentView class]]) {
            SCContactEventContentView *cv = (SCContactEventContentView *) cell.eventContentView;
            
            cv.saveAction = [C2BlockAction actionWithAction:^(id sender) {
                CFErrorRef error = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreate();
                ABAddressBookAddRecord(addressBook, person, &error);
                
                if (error == NULL) {
                    ABAddressBookSave(addressBook, &error);
                    [AlertUtil showContactSaved];
                } else {
                    [AlertUtil showContactSavedError];
                }
            }];
            
            cv.messageAction =[C2BlockAction actionWithAction:^(id sender) {
                [self showContact:vcard];
            }];
            
        }


    }
    @catch (NSException *exception) {
        DLog(@"Exception:setVCard : %@", exception);
    }
    @finally {
        personArray = nil;
    }

}

-(void) configureVCardCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    
    NSArray *personArray = nil;
    ABRecordRef person = NULL;
    
    BOOL failed = NO;
    
    NSString *vcard = bo.dataObject.text;
    @try {
        
        NSData *data = nil;
        if ([vcard hasPrefix:@"vcard://"]) {
            if (![[C2CallPhone currentPhone] hasObjectForKey:vcard]) {
                if ([[C2CallPhone currentPhone] downloadStatusForKey:vcard]) {
                    [cell monitorDownloadForKey:vcard];
                } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:vcard]) {
                    // We need a broken link image here and a download button
                    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
                    
                    UIImage *brokenImage = [UIImage imageNamed:@"ico_broken_vcard" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
                    [cell presentContentForKey:vcard withPreviewImage:brokenImage];
                    
                    [cell setLongpressAction:^{
                        [self setRetransmitDownloadActionForCell:weakcell withMediaKey:vcard];
                    }];
                    failed = YES;
                } else {
                    [cell startDownloadForKey:vcard];
                }
                
                [cell presentContentForKey:NSLocalizedString(@"Loading...", @"VCARD") withPreviewImage:nil];
                
                return;
            } else {
                NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:vcard];
                data = [NSData dataWithContentsOfURL:url];
            }
        } else {
            data = [vcard dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if ([data length] == 0) {
            DLog(@"VCARD is empty");
            [cell presentContentForKey:NSLocalizedString(@"Empty VCARD", @"VCARD") withPreviewImage:nil];
            return;
        }
        
        
        personArray = (NSArray *) CFBridgingRelease(ABPersonCreatePeopleInSourceWithVCardRepresentation(NULL,(__bridge CFDataRef) data));
        person = (__bridge ABRecordRef)([personArray objectAtIndex:0]);
        
        NSString *compositName =  (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
        CFDataRef imageData = ABPersonCopyImageData(person);
        UIImage *vcardImage = nil;
        
        if (imageData != NULL) {
            vcardImage = [UIImage imageWithData:(__bridge NSData *)imageData];
            CFRelease(imageData);
        }
        [cell presentContentForKey:compositName withPreviewImage:vcardImage];
        
        [cell setTapAction:^{
            //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0x42/255. green:0x85/255. blue:0xf4/255. alpha:1.0]];

            [self showContact:vcard];
        }];

        [cell setLongpressAction:^{
            [self showLongpressMenuForCell:weakcell withMediaKey:vcard];
        }];
        
        if ([cell.eventContentView isKindOfClass:[SCContactEventContentView class]]) {
            SCContactEventContentView *cv = (SCContactEventContentView *) cell.eventContentView;
            
            cv.saveAction = [C2BlockAction actionWithAction:^(id sender) {
                CFErrorRef error = NULL;
                
                NSArray *personArray = nil;
                ABRecordRef person = NULL;

                personArray = (NSArray *) CFBridgingRelease(ABPersonCreatePeopleInSourceWithVCardRepresentation(NULL,(__bridge CFDataRef) data));
                person = (__bridge ABRecordRef)([personArray objectAtIndex:0]);

                ABAddressBookRef addressBook = ABAddressBookCreate();
                ABAddressBookAddRecord(addressBook, person, &error);
                
                if (error == NULL) {
                    ABAddressBookSave(addressBook, &error);
                    [AlertUtil showContactSaved];
                } else {
                    [AlertUtil showContactSavedError];
                }
            }];
            
            cv.messageAction = [C2BlockAction actionWithAction:^(id sender) {
              [self showContact:vcard];
            }];
        }

    }
    @catch (NSException *exception) {
        DLog(@"Exception:setVCard : %@", exception);
    }
    @finally {
        personArray = nil;
    }

}

-(void) configureFriendCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
}

-(void) configureFriendCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
}

-(void) configureEventContentColor:(SCBoardObjectEventCell *) cell
{
    cell.eventContentView.backgroundColor = cell.bubbleView.backgroundColor;
}

-(void) configureCell:(SCBoardObjectCell *) cell forBoardObject:(SCBoardObject *) bo atIndexPath:(NSIndexPath *) indexPath
{
    
    cell.controller = self;
    
    if ([bo isKindOfClass:[SCBoardObjectTimeHeader class]]) {
        [self configureTimeHeaderCell:(SCBoardObjectTimeHeaderCell *) cell forBoardObject:(SCBoardObjectTimeHeader *) bo atIndexPath:indexPath];
    }
    
    if ([bo isKindOfClass:[SCBoardObjectNewMessagesHeader class]]) {
        [self configureNewMessagesHeaderCell:(SCBoardObjectNewMessagesHeaderCell *)cell forBoardObject:(SCBoardObjectNewMessagesHeader *) bo atIndexPath:indexPath];
    }
    
    if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
        SCBoardObjectCoreData *msg = (SCBoardObjectCoreData *) bo;
        
        [self configureEventContentColor:(SCBoardObjectEventCell *)cell];
        
        if ([self isInboundMessage:(SCBoardObjectCoreData *) bo]) {
            SCRichMediaType rmType = [[C2CallPhone currentPhone] mediaTypeForKey:msg.dataObject.text];
            switch (rmType) {
                case SCMEDIATYPE_IMAGE:
                    [self configurePictureCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_VIDEO:
                    [self configureVideoCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_VOICEMAIL:
                    [self configureAudioCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_VCARD:
                    [self configureVCardCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_FILE:
                    [self configureFileCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_FRIEND:
                    [self configureFriendCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_LOCATION:
                    [self configureLocationCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_BROADCAST:
                    [self configureTextCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                default: // Text
                    [self configureTextCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
            }
        } else {
            SCRichMediaType rmType = [[C2CallPhone currentPhone] mediaTypeForKey:msg.dataObject.text];
            switch (rmType) {
                case SCMEDIATYPE_IMAGE:
                    [self configurePictureCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_VIDEO:
                    [self configureVideoCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_VOICEMAIL:
                    [self configureAudioCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_VCARD:
                    [self configureVCardCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_FILE:
                    [self configureFileCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_FRIEND:
                    [self configureFriendCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_LOCATION:
                    [self configureLocationCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                case SCMEDIATYPE_BROADCAST:
                    [self configureTextCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
                default: // Text
                    [self configureTextCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *)bo atIndexPath:indexPath];
                    return;
            }
        }
    }
    
    
}

-(void) configureCell:(UITableViewCell *) cell forIndexPath:(NSIndexPath *) indexPath
{
    SCBoardObject *bo = [self.dataSource boardObjectAtIndexPath:indexPath];
    // Configure the prepared cell
    [self configureCell:(SCBoardObjectCell *) cell forBoardObject:bo atIndexPath:indexPath];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

// save height
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.cellHeightsDictionary setObject:@(cell.frame.size.height) forKey:indexPath];
}

// give exact height value
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self.cellHeightsDictionary objectForKey:indexPath];
    if (height) return height.doubleValue;
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SCBoardObject *bo = [self.dataSource boardObjectAtIndexPath:indexPath];
    NSString *reuseIdentifier = [self reuseIdentifierForBoardObject:bo atIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Install Content from XIB file
    if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
        [self loadEventContentXIB:(SCBoardObjectEventCell *) cell forBoardObject:(SCBoardObjectCoreData *) bo];
        [self loadReplyToContentXIB:(SCBoardObjectEventCell *) cell forBoardObject:(SCBoardObjectCoreData *) bo];
    }
    
    // Configure the prepared cell
    [self configureCell:(SCBoardObjectCell *) cell forBoardObject:bo atIndexPath:indexPath];
    
    //[cell.contentView setNeedsLayout];
    //[cell.contentView layoutIfNeeded];
    
    return cell;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCBoardObject *bo = [self.dataSource boardObjectAtIndexPath:indexPath];
    
    if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
        SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) bo;
        NSString *eventType = bocd.dataObject.eventType;
        
        if ([eventType isEqualToString:@"MessageSubmit"]) {
            int status = [bocd.dataObject.status intValue];
            if (status != 3) {
                return NO;
            }
        }
        return YES;
        
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SCBoardObject *bo = [self.dataSource boardObjectAtIndexPath:indexPath];
        
        if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
            SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) bo;
            MOC2CallEvent *elem = bocd.dataObject;
            
            if (elem) {
                [[SCDataManager instance] removeDatabaseObject:elem];
            }
        }
    }
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Hide Keyboard in SCChatController on touch
    if ([self.parentViewController respondsToSelector:@selector(hideKeyboard:)]) {
        [self.parentViewController performSelector:@selector(hideKeyboard:) withObject:nil];
    }
}

-(void) performScrollToBottom:(BOOL) useDelay
{
    self.scrollToBottom = NO;
    double delayInSeconds = 0.05;
    
    if (!useDelay) {
        int section = (int)self.tableView.numberOfSections - 1;
        int row =  (int)[self.tableView numberOfRowsInSection:section] - 1;
        if (section >= 0 && row >= 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        return;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        int section = (int)self.tableView.numberOfSections - 1;
        int row =  (int)[self.tableView numberOfRowsInSection:section] - 1;
        if (section >= 0 && row >= 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
}

- (void)killScroll
{
    CGPoint offset = self.tableView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.tableView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [self.tableView setContentOffset:offset animated:NO];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        return;
    }
    
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        CGFloat coffset = scrollView.contentOffset.y;
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        
        NSIndexPath *topIndexPath = indexPaths[0];
        if (topIndexPath.row <= 10 && !self.loadingPreviousMessages) {
            self.loadingPreviousMessages = YES;
            self.lastContentOffset = scrollView.contentOffset.y;
            
            NSLog(@"SCBoardTest: dataSourceDidReloadContent : %@ / %@", @(coffset), @(topIndexPath.row));
            SCBoardObject *topBoardObject = [self.dataSource boardObjectAtIndexPath:topIndexPath];
            
            //[self killScroll];

            CGRect before = [self.tableView rectForRowAtIndexPath:topIndexPath];       // 2

            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadingPreviousMessages = [self.dataSource previousMessages];
                
                if (self.loadingPreviousMessages) {
                    NSIndexPath *newIndexPath = [self.dataSource indexPathForBoardObject:topBoardObject];
                    
                    CGPoint contentOffset = [self.tableView contentOffset];                    // 3
                    [self.tableView reloadData];                                               // 4
                    
                    [self.tableView layoutIfNeeded];
                    
                    CGRect after = [self.tableView rectForRowAtIndexPath:newIndexPath];        // 5
                    contentOffset.y += (after.origin.y - before.origin.y);
                    contentOffset.y = floor(contentOffset.y);
                    self.lastContentOffset = contentOffset.y;
                    
                    NSLog(@"SCBoardTest: dataSourceDidReloadContent : %@/%@ - %@/%@ - %@/%@", @(topIndexPath.row), @(newIndexPath.row), @(before.origin.y), @(after.origin.y), @(contentOffset.y), @(self.lastContentOffset));
                    
                    
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        //[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        scrollView.contentOffset = contentOffset;
                        
                        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.loadingPreviousMessages = NO;
                        //});
                    //});
                    //[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            });
            return;
        }
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y) {
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self customPrepareForSegue:segue sender:sender];
}

#pragma mark SCBoardDataSourceDelegate

- (void)dataSource:(nonnull SCBoardDataSource *)dataSource didChangeObject:(nullable id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(SCBoardDataSourceChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
{
    NSLog(@"SCBoardTest:dataSource:didChangeObject: %@ - %@",@(type), indexPath? @(indexPath.row) : @(newIndexPath.row));
    
    @try {
        switch(type) {
            case SCBoardDataSourceChangeInsert:
            {
                NSUInteger rows = [self.tableView numberOfRowsInSection:indexPath.section];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
                
                // On append message, scroll to bottom
                if (newIndexPath.row == rows) {
                    self.scrollToBottom = YES;
                }
            }
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
                
            case NSFetchedResultsChangeUpdate: {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self configureCell:cell forIndexPath:indexPath];
            }
                //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                break;
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
        }
        
    }
    @catch (NSException *exception) {
        DLog(@"Error : didChangeObject : %@", exception);
        [self.tableView reloadData];
    }
    
}

- (void)dataSourceWillChangeContent:(nonnull SCBoardDataSource *)dataSource;
{
    [self.tableView beginUpdates];
    NSLog(@"SCBoardTest:dataSource:dataSourceWillChangeContent");
    
}

- (void)dataSourceDidChangeContent:(nonnull SCBoardDataSource *)dataSource;
{
    [self.tableView endUpdates];
    
    NSLog(@"SCBoardTest:dataSource:dataSourceDidChangeContent");
    
    if (self.scrollToBottom) {
        [self performScrollToBottom:NO];
    }
    
}

-(void) dataSourceDidReloadContent;
{
    [self.tableView reloadData];
    
    if (self.scrollToBottom) {
        [self performScrollToBottom:YES];
    }
    
}

#pragma mark Board Actions

-(void) contentAction:(SCBoardObjectEventCellIn *)cell {
    if ([cell.boardObject isKindOfClass:[SCBoardObjectCoreData class]]) {
        SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) cell.boardObject;
        
        [self shareRichMessageForKey:bocd.dataObject.text];
    }

}

-(BOOL) canShareWithApps:(NSString *) key
{
    SCRichMediaType mt = [[C2CallPhone currentPhone] mediaTypeForKey:key];
    
    switch (mt) {
        case SCMEDIATYPE_TEXT:
        case SCMEDIATYPE_IMAGE:
        case SCMEDIATYPE_USERIMAGE:
        case SCMEDIATYPE_VIDEO:
        case SCMEDIATYPE_VOICEMAIL:
        case SCMEDIATYPE_FILE:
        case SCMEDIATYPE_VCARD:
            //case SCMEDIATYPE_LOCATION:
            return YES;
        default:
            return NO;
    }
    
}

-(void) shareWithApps:(NSString*) key
{
    SCRichMediaType mt = [[C2CallPhone currentPhone] mediaTypeForKey:key];
    
    UIActivityViewController *activityViewController = nil;
    
    switch (mt) {
        case SCMEDIATYPE_TEXT:
        {
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[key] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_IMAGE:
        {
            NSURL *mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:key];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_USERIMAGE:
        {
            NSURL *mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:key];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_VIDEO:
        {
            NSURL *mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:key];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_VOICEMAIL:
        {
            NSURL *mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:key];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_FILE:
        {
            NSURL *mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:key];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_VCARD:
        {
            NSURL *mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:key];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        case SCMEDIATYPE_FRIEND:
            break;
        case SCMEDIATYPE_LOCATION:{
            FCLocation *loc = [[FCLocation alloc] initWithKey:key];
            NSURL *mediaUrl = [loc storeLocationAsVCard];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaUrl] applicationActivities:nil];
        }
            break;
        default:
            break;
    }
    
    if (activityViewController) {
        [self presentViewController:activityViewController animated:YES completion:^{
            
        }];
    }
}

-(void) shareEmail:(NSString *) key
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:key];
    NSString *name = [[C2CallPhone currentPhone] nameForKey:key];
    NSString *contentType = [[C2CallPhone currentPhone] contentTypeForKey:key];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    [controller addAttachmentData:data mimeType:contentType
                         fileName:name];
    
    [self presentViewController:controller animated:YES completion:NULL];
}

-(void) shareMessageForKey:(NSString *) key
{
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Forward to friend", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    if ([self canShareWithApps:key]) {
        [cv addChoiceWithName:NSLocalizedString(@"Share", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via App", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_action" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^(){
            [self shareWithApps:key];
        }];
    }
    
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
    
}

-(void) shareRichMessageForKey:(NSString *) key
{
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Forward to friend", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    if ([self canShareWithApps:key]) {
        [cv addChoiceWithName:NSLocalizedString(@"Share", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via App", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_action" inBundle:frameWorkBundle compatibleWithTraitCollection:nil] andCompletion:^(){
            [self shareWithApps:key];
        }];
    }
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
}

// Not implemented yet
-(void) sharePhotoOrVideo:(NSString *) key
{
    
}

-(void) forwardMessage:(NSString *)message
{
    if ([message hasPrefix:@"image://"] || [message hasPrefix:@"video://"] ||[message hasPrefix:@"audio://"] ||[message hasPrefix:@"vcard://"] ||[message hasPrefix:@"loc://"] ||[message hasPrefix:@"friend://"] || [message hasPrefix:@"file://"] ) {
        [self composeMessage:nil richMessageKey:message];
    } else {
        [self composeMessage:message richMessageKey:nil];
    }
    
}

-(void) copyText:(NSString *) text
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        [pasteBoard setString:text];
    }
}

-(void) copyVCard:(NSString *) vcard
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        NSData *data = [vcard dataUsingEncoding:NSUTF8StringEncoding];
        [pasteBoard setData:data forPasteboardType:(NSString*)kUTTypeVCard];
    }
}

-(void) copyImageForKey:(NSString *) key
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        if ([[C2CallPhone currentPhone] hasObjectForKey:key]) {
            UIImage *img = [[C2CallPhone currentPhone] imageForKey:key];
            [pasteBoard setImage:img];
        }
    }
}

-(void) copyLocationForKey:(NSString *) key
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        UIImage *img = [ImageUtil imageFromLocation:[[FCLocation alloc] initWithKey:key]];
        if (img)
            [pasteBoard setImage:img];
    }
}

-(void) copyMovieForKey:(NSString *) key
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:key];
        if (url) {
            [pasteBoard setURL:url];
        }
    }
}

-(void) showImage:(NSString *) key
{
    @try {
        NSMutableArray *imageList = [NSMutableArray array];
        for (SCBoardObjectCoreData *cdo in [self.dataSource allBoardImages]) {
            MOC2CallEvent *elem = cdo.dataObject;
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
            [info setObject:elem.text forKey:@"image"];
            [info setObject:elem.eventId forKey:@"eventId"];
            [info setObject:elem.timeStamp forKey:@"timeStamp"];
            [info setObject:elem.eventType forKey:@"eventType"];
            if (elem.senderName)
                [info setObject:elem.senderName forKey:@"senderName"];
            
            [imageList addObject:info];
            
        }
        
        [self showPhotos:imageList currentPhoto:key];
    }
    @catch (NSException *exception) {
        
    }
}

-(void) transferCompletedForKey:(NSString *) mediaKey onCell:(SCBoardObjectEventCell *) cell
{
    if (cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                [self configureCell:cell forIndexPath:indexPath];
                //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

-(void) setSubmittedStatusIcon:(UIImageView *) iconSubmitted forStatus:(int) messageStatus isImage:(BOOL) isImage
{
    iconSubmitted.animationImages = nil;
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    switch (messageStatus) {
        case 1:
            iconSubmitted.image = nil;
            iconSubmitted.animationImages = isImage?self.animationIconWhite : self.animationIcon;
            iconSubmitted.animationDuration = 1.5;
            [iconSubmitted startAnimating];
            [iconSubmitted setHidden:NO];
            break;
        case 2:
            if (isImage) {
                iconSubmitted.image = [UIImage imageNamed:@"ico_deliverd_white" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            } else {
                iconSubmitted.image = [UIImage imageNamed:@"ico_deliverd" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            }
            [iconSubmitted setHidden:NO];
            break;
        case 3:
            if (isImage) {
                iconSubmitted.image = [UIImage imageNamed:@"ico_notdeliverd_white" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            } else {
                iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            }
            [iconSubmitted setHidden:NO];
            break;
        case 4:
            if (isImage) {
                iconSubmitted.image = [UIImage imageNamed:@"ico_read_white" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            } else {
                iconSubmitted.image = [UIImage imageNamed:@"ico_read" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
            }
            
            [iconSubmitted setHidden:NO];
            break;
        default:
            [iconSubmitted setHidden:YES];
            break;
    }
    
}


-(void) setRetransmitActionForCell:(SCBoardObjectEventCellOut *) cell withMediaKey:(NSString *) mediaKey andUserid:(NSString *) userid
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
    
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
    [cell setRetransmitAction:^{
        [[C2CallPhone currentPhone] submitRichMessage:mediaKey message:nil toTarget:userid];
    }];
    [menulist addObject:item];
    menu.menuItems = menulist;
    
    CGRect rect = cell.eventContentView.frame;
    rect = [cell convertRect:rect fromView:cell.eventContentView];
    [menu setTargetRect:rect inView:cell];
    [cell becomeFirstResponder];
    [menu setMenuVisible:YES animated:YES];
    
}

-(void) setRetransmitDownloadActionForCell:(SCBoardObjectEventCell *) cell withMediaKey:(NSString *) mediaKey {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
    
    __weak SCBoardObjectEventCell *weakcell = cell;
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
    [cell setRetransmitAction:^{
        [weakcell startDownloadForKey:mediaKey];
    }];
    [menulist addObject:item];
    
    menu.menuItems = menulist;
    
    CGRect rect = weakcell.eventContentView.frame;
    rect = [cell convertRect:rect fromView:cell.eventContentView];
    [menu setTargetRect:rect inView:cell];
    [cell becomeFirstResponder];
    [menu setMenuVisible:YES animated:YES];
    
}

-(void) showLongpressMenuForCell:(SCBoardObjectEventCell *) cell withMediaKey:(NSString *) mediaKey
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
    
    SCRichMediaType mt = [[C2CallPhone currentPhone] mediaTypeForKey:mediaKey];

    
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share", @"MenuItem") action:@selector(shareAction:)];
    [cell setShareAction:^{
        [self shareRichMessageForKey:mediaKey];
    }];
    [menulist addObject:item];

    if (mt == SCMEDIATYPE_TEXT) {
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [self copyImageForKey:mediaKey];
        }];
        [menulist addObject:item];
        
    }
    
    if (mt == SCMEDIATYPE_VIDEO || mt == SCMEDIATYPE_IMAGE) {
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Save", @"MenuItem") action:@selector(saveAction:)];
        
        [cell setSaveAction:^{
            switch (mt) {
                case SCMEDIATYPE_IMAGE:
                    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Saving Image to Album", @"Title") andWaitMessage:nil];
                    break;
                case SCMEDIATYPE_VIDEO:
                    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Saving Video to Album", @"Title") andWaitMessage:nil];
                    break;
                    
                default:
                    break;
            }
            
            [[C2CallPhone currentPhone] saveToAlbum:mediaKey withCompletionHandler:^(NSURL *assetURL, NSError *error) {
                [[C2CallAppDelegate appDelegate] waitIndicatorStop];
            }];
        }];
        [menulist addObject:item];
        
    }
    
    menu.menuItems = menulist;
    CGRect rect = cell.eventContentView.frame;
    rect = [cell convertRect:rect fromView:cell.eventContentView];
    [menu setTargetRect:rect inView:cell];
    [cell becomeFirstResponder];
    [menu setMenuVisible:YES animated:YES];
    
}

-(NSArray<UIColor *> *) colorsForMemberNames
{
    NSMutableArray<UIColor *> *list = [NSMutableArray array];
    
    UIColor *color = nil;
    
    color = [UIColor colorWithRed:0x77/255. green:0x34/255. blue:0xD3/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x63/255. green:0xB2/255. blue:0x18/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x42/255. green:0x85/255. blue:0xF4/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0xFB/255. green:0xBC/255. blue:0x05/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x23/255. green:0x2F/255. blue:0x3E/255. alpha:1.0];
    [list addObject:color];
    
    color = [UIColor colorWithRed:0xFF/255. green:0x93/255. blue:0x00/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0xF4/255. green:0x43/255. blue:0x36/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0xE9/255. green:0x1E/255. blue:0x63/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x9C/255. green:0x27/255. blue:0xB0/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x6F/255. green:0x81/255. blue:0xEA/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x10/255. green:0x58/255. blue:0xC6/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x00/255. green:0xBC/255. blue:0xD4/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0xB8/255. green:0xDC/255. blue:0x39/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x4C/255. green:0xAF/255. blue:0x50/255. alpha:1.0];
    [list addObject:color];
    color = [UIColor colorWithRed:0x00/255. green:0x96/255. blue:0x88/255. alpha:1.0];
    [list addObject:color];
    
    return list;
}

-(UIColor *) colorForMember:(NSString *) member
{
    if (!member) {
        return nil;
    }
    
    UIColor *color = self.colorMap[member];
    
    if (color) {
        return color;
    }
    
    if (!self.colorList) {
        self.colorList = [self colorsForMemberNames];
    }
    
    if ([self.colorList count] == 0) {
        return nil;
    }
    
    if (self.colorNum >= [self.colorList count]) {
        self.colorNum %= [self.colorList count];
    }
    color = self.colorList[self.colorNum];
    
    self.colorNum++;
    self.colorNum %= [self.colorList count];
    
    self.colorMap[member] = color;
    
    return color;
}

#pragma mark MailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    UIView *firstResponder = [self findFirstResponder:controller.view];
    [firstResponder resignFirstResponder];
    double delayInSeconds = 0.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [controller dismissViewControllerAnimated:YES completion:NULL];
    });
}

@end

