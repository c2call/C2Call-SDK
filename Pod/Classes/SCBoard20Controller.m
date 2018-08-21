//
//  SCBoard20Controller.m
//  C2CallPhone
//
//  Created by Michael Knecht on 21.11.17.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <UIViewController+SCCustomViewController.h>

#import <Contacts/Contacts.h>
#import <SafariServices/SSReadingList.h>
#import "SCBoard20Controller.h"
#import "SCBoardDataSource.h"
#import "SCEventContentView.h"
#import "SCReplyToContentView.h"
#import "SCReplyToContainer.h"
#import "SCLinkPreviewContentView.h"
#import "SCLinkPreview.h"
#import "SocialCommunication.h"
#import "FCPlacesDetail.h"
#import "FCGeocoder.h"
#import "SCPTTPlayer.h"
#import "debug.h"

#import "SCLinkMetaInfo.h"

@implementation SCBoardObjectCell

- (void)dealloc
{
    DLog(@"SCBoardObjectCell:dealloc");
    [self dispose];
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    DLog(@"SCBoardTest:prepareForReuse");
    
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
    
    self.controller = nil;
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
    self.replyToEventId = nil;
    
    self.retrievingVideoThumbnail = NO;
    if (self.transferKey) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.transferKey = nil;
        self.transferMonitorActive = NO;
        
        [self hideTransferProgress];
    }
    
    if (_replyToView.replyToView) {
        [_replyToView.stackView removeArrangedSubview:_replyToView.replyToView];
        [_replyToView.replyToView removeFromSuperview];
        _replyToView.replyToView = nil;
    }

    _replyToView.hidden = YES;
    
    if (_linkPreview.contentView) {
        [_linkPreview.stackView removeArrangedSubview:_linkPreview.contentView];
        [_linkPreview.contentView removeFromSuperview];
        _linkPreview.contentView = nil;
    }
    _linkPreview.hidden = YES;
}

-(void) setEventContentView:(SCEventContentView *)eventContentView
{
    if (_eventContentView) {
        [self.middleStack removeArrangedSubview:_eventContentView];
        [_eventContentView removeFromSuperview];
    }
    
    if (eventContentView) {
        [self.middleStack insertArrangedSubview:eventContentView atIndex: 3];
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


-(void) setLinkPreview:(SCLinkPreviewContentView *)linkPreview
{
    if (_linkPreview) {
        [self.middleStack removeArrangedSubview:_linkPreview];
        [_linkPreview removeFromSuperview];
    }
    
    if (linkPreview) {
        [self.middleStack insertArrangedSubview:linkPreview atIndex:2];
    }
    
    _linkPreview = linkPreview;
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
    if ([self.eventContentView showTransferProgress]) {
        [self.controller updateCell:self];
    }
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    [self.eventContentView updateTransferProgress:progress];
}

-(void) hideTransferProgress;
{
    if ([self.eventContentView hideTransferProgress]) {
        [self.controller updateCell:self];
    }
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
    __weak SCBoardObjectEventCell *weakcell = self;
    
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
        weakcell.retrievingVideoThumbnail = NO;
        
        // Check whether the cell is still active for this key
        if ([weakcell.transferKey isEqualToString:mediaKey]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage *thumb = thumbnail;
                if (!thumb) {
                    thumb = [[SCAssetManager instance] imageForName:@"ico_broken_video"];
                }
                [weakcell presentContentForKey:mediaKey withPreviewImage:thumb];
                
                [weakcell hideTransferProgress];
                
                [weakcell.controller transferCompletedForKey:mediaKey onCell:weakcell];
            });
            weakcell.transferKey = nil;
        }
    }];
}

- (IBAction)shareContent:(id)sender {
}

-(void) retrieveLocation:(FCLocation *) loc
{
    __weak SCBoardObjectEventCell *weakcell = self;
    
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
                [weakcell.controller transferCompletedForKey:loc.locationKey onCell:weakcell];
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
                    [weakcell.controller transferCompletedForKey:loc.locationKey onCell:weakcell];
                });
            }
        }];
        if (geocoder) {
            
        }
    }
}

-(void) scrollToRepliedMessage
{
    if (self.replyToEventId) {
        [self.controller scrollToMessageWithEventId:self.replyToEventId];
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
    self.sentMediaActionBtn.hidden = YES;
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

- (IBAction)sentMediaAction:(id)sender
{
    [self.controller sentMediaAction:self];
}

@end


@interface SCBoard20Controller ()<SCBoardDataSourceDelegate, MFMailComposeViewControllerDelegate> {
    BOOL    isChangingContent;
    NSMutableArray<NSNumber *>    *contentCount;
    NSInteger   insertedObjects, deletedObjects;
    NSIndexPath *scrolledToIndexPath;
}


@property(strong, nonatomic) NSDateFormatter    *timeFormatter;
@property(nonatomic) BOOL                   scrollToBottom;
@property(nonatomic) BOOL                   loadingPreviousMessages;
@property(strong, nonatomic) NSIndexPath    *lastVisibleRow;

@property(strong, nonatomic) NSMutableDictionary *cellHeightsDictionary;
@property(strong, nonatomic) NSMutableArray     *animationIcon;
@property(strong, nonatomic) NSMutableArray     *animationIconWhite;
@property(strong, nonatomic) NSMutableDictionary<NSString*, UIColor*>   *colorMap;

@property(strong, nonatomic) NSArray<UIColor*>                                  *colorList;
@property(strong, nonatomic) NSArray<NSDictionary<NSString*, NSObject*> *>     *groupDataDetectors;

@property(nonatomic) NSUInteger    colorNum;
@property(nonatomic) NSInteger    lastContentOffset;
@property(nonatomic) BOOL   isGroup;
@property(strong, nonatomic) NSCache            *previewImageCache;

@end

@implementation SCBoard20Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    isChangingContent = NO;
    contentCount = [[NSMutableArray alloc] initWithCapacity:200];

    self.cellHeightsDictionary = [NSMutableDictionary dictionary];
    self.colorMap = [NSMutableDictionary dictionary];
    self.previewImageCache = [[NSCache alloc] init];
    
    self.animationIcon = [[NSMutableArray alloc] initWithCapacity:4];
    [self.animationIcon addObject:[[SCAssetManager instance] imageForName:@"ico_sending_0"]];
    [self.animationIcon addObject:[[SCAssetManager instance] imageForName:@"ico_sending_1"]];
    [self.animationIcon addObject:[[SCAssetManager instance] imageForName:@"ico_sending_2"]];
    [self.animationIcon addObject:[[SCAssetManager instance] imageForName:@"ico_sending_3"]];
    
    self.animationIconWhite = [[NSMutableArray alloc] initWithCapacity:4];
    [self.animationIconWhite addObject:[[SCAssetManager instance] imageForName:@"ico_sending_0_white"]];
    [self.animationIconWhite addObject:[[SCAssetManager instance] imageForName:@"ico_sending_1_white"]];
    [self.animationIconWhite addObject:[[SCAssetManager instance] imageForName:@"ico_sending_2_white"]];
    [self.animationIconWhite addObject:[[SCAssetManager instance] imageForName:@"ico_sending_3_white"]];
    
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
    
    if (self.isGroup) {
        self.groupDataDetectors = [self prepareGroupUserDataDetectors];
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
        
        [self.dataSource saveChanges];
    }
    
}

-(void) dispose {
    [self.dataSource dispose];
    self.delegate = nil;
    self.dataSource = nil;
    [self.previewImageCache removeAllObjects];
}

- (void)dealloc
{
    DLog(@"SCBoard20Controller:dealloc()");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray<NSDictionary<NSString*, NSObject*> *> *) prepareGroupUserDataDetectors
{
    SCGroup *group = [[SCGroup alloc] initWithGroupid:self.targetUserid retrieveFromServer:NO];
    
    NSMutableArray<NSDictionary<NSString*, NSObject*> *> *dataDetectors = [NSMutableArray array];
    
    for (NSString *member in group.groupMembers) {
        NSString *name = [[C2CallPhone currentPhone] nameForUserid:member];
        if ([name isEqualToString:member]) {
            NSString *firstname = [group firstnameForGroupMember:member];
            NSString *lastname = [group nameForGroupMember:member];
            if ([firstname length] > 0 && [lastname length] > 0) {
                name = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
            } else if ([firstname length] > 0) {
                name = firstname;
            } else if ([lastname length] > 0) {
                name = lastname;
            }
        }
        
        if (name) {
            NSMutableDictionary *dataDetector = [NSMutableDictionary dictionaryWithCapacity:4];
            dataDetector[@"name"] = name;
            dataDetector[@"userid"] = member;
            UIColor *color = [self colorForMember:member];
            if (color) {
                dataDetector[@"color"] = color;
            }

            [dataDetectors addObject:dataDetector];
        }
    }
    
    return dataDetectors;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.dataSource numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isChangingContent) {
        return [contentCount[section] integerValue];
    }

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
    return @"SCReplyToContent";
}

-(void) loadEventContentXIB:(SCBoardObjectEventCell *) cell forBoardObject:(SCBoardObjectCoreData *) bo
{
    NSString *xibFile = [self eventContentXIBMessageObject:bo];
    DLog(@"SCBoardTest:loadEventContentXIB: %@",xibFile);
    if ([cell.eventContentXIB isEqualToString:xibFile]) {
        // Resued Cell with right content, do nothing
        DLog(@"SCBoardTest:loadEventContentXIB: %@ - Already Loaded",xibFile);
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
    DLog(@"loadReplyToContentXIB: %@", bo.dataObject.text);
    
    NSString *replyToEventId = bo.dataObject.replyTo;

    if (!replyToEventId) {
        return;
    }
    
    NSString *xibFile = [self replyToContentXIBMessageObject:bo];
    if (!xibFile) {
        return;
    }
    
    UINib *nib = nil;
    if ([[NSBundle mainBundle] pathForResource:xibFile ofType:@"nib"]) {
        nib = [UINib nibWithNibName:xibFile bundle:nil];
    }
    
    if (!nib) {
        nib = [UINib nibWithNibName:xibFile bundle:[NSBundle bundleForClass:[self class]]];
    }
    [nib instantiateWithOwner:cell.replyToView options:nil];
    
    if (![cell.replyToView.replyToView presentReplyToContentFor:replyToEventId]) {
        return;
    }
    
    cell.replyToEventId = replyToEventId;
    
    if (cell.replyToView.replyToView.replyToUserid && self.isGroup) {
        UIColor *color = [self colorForMember:cell.replyToView.replyToView.replyToUserid];
        if (color) {
            [cell.replyToView.replyToView setReplyToColor:color];
        }
    }

    [cell.replyToView.replyToTap addTarget:cell action:@selector(scrollToRepliedMessage)];
    
    [cell.replyToView.stackView addArrangedSubview:cell.replyToView.replyToView];
    cell.replyToView.hidden = NO;
    [cell.replyToView setNeedsUpdateConstraints];
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
    
    image = [[C2CallPhone currentPhone] userimageForUserid:contact];
    if (image) {
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:17.5];
        [self.smallImageCache setObject:image forKey:contact];
        return image;
    }
    
    if ([self isPhoneNumber:contact]) {
        image = [[SCAssetManager instance] imageForName:@"btn_ico_adressbook_contact"];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:17.5];
        [self.smallImageCache setObject:image forKey:contact];
        return image;
    }
    
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:contact];
    if ([user.userType intValue] == 2) {
        image = [[SCAssetManager instance] imageForName:@"btn_ico_avatar_group"];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:17.5];
        [image setAccessibilityHint:@"default_pic"];
        [self.smallImageCache setObject:image forKey:contact];
        return image;
        
    }
    
    image = [[SCAssetManager instance] imageForName:@"btn_ico_avatar"];
    image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
    [image setAccessibilityHint:@"default_pic"];
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
    return [[UIColor blackColor] colorWithAlphaComponent:0.75];
}

-(CGSize) maxPictureSize
{
    return CGSizeMake(480, 480);
}

-(CGSize) maxVideoSize
{
    return CGSizeMake(480, 480);
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
    
    if (self.groupDataDetectors && [messageText rangeOfString:@"@"].location != NSNotFound) {
        result[@"users"] = [self.groupDataDetectors copy];
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
    
    cell.userImageView.hidden = !self.useSenderImage;
    cell.userImage.hidden = bo.sameSenderOnPreviousMessage;
    if (!(cell.userImage.hidden)) {
        UIImage *pic = [self imageForElement:elem];
        if ([pic.accessibilityHint isEqualToString:@"default_pic"]) {
            cell.userImage.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
        } else {
            cell.userImage.backgroundColor = [UIColor clearColor];
        }
        cell.userImage.image = pic;
    }
    
    BOOL showUserName = self.useNameHeader && !(bo.sameSenderOnPreviousMessage);
    cell.userNameView.hidden = !(showUserName);
    if (showUserName)
    {
        NSString *sendername = elem.senderName ? elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
        cell.userName.text = sendername;
        cell.userName.textColor = [self colorForMember:elem.originalSender? elem.originalSender: elem.contact];
    }
    
    cell.topDistanceView.hidden = bo.sameSenderOnPreviousMessage;
    
    cell.bubbleTip.hidden = bo.sameSenderOnPreviousMessage && self.isGroup;
    
    cell.timeInfo.text = [self.timeFormatter stringFromDate:elem.timeStamp];
    cell.readStatus.hidden = YES;
    
    if ([bo.dataObject.eventType isEqualToString:@"MessageIn"]) {
        if ([bo.dataObject.status intValue] < 4) {
            [[SCDataManager instance] markAsRead:elem];
        }
        
        if (bo.messageText && bo.mediaKey) {
            NSString *subEvent = [NSString stringWithFormat:@"%@#1", bo.eventId];
            //NSLog(@"subEvent: %@", subEvent);
            
            MOC2CallEvent *subtext = [[SCDataManager instance] eventForEventId:subEvent];
            if (subtext && [subtext.status intValue] < 4) {
                [[SCDataManager instance] markAsRead:subtext];
            }
        }
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
    
    int status = [elem.status intValue];
    if (status == 3) {
        cell.errorStatusImage.image = [[SCAssetManager instance] imageForName:@"ico_notdelivered"];
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
    
    __weak SCBoard20Controller *weakself = self;

    
    if ([links count] > 0 || [numbers count] > 0) {
        if ([links count] == 1 && [numbers count] == 0) {
            
            NSURL *url = links[0];
            [cell setTapAction:^{
                [[UIApplication sharedApplication] openURL:url];
            }];
            return YES;
        }
        
        [cell setTapAction:^{
            SCPopupMenu *cv = [SCPopupMenu popupMenu:weakself];
            
            for (NSURL *url in links) {
                [cv addChoiceWithName:NSLocalizedString(@"Open URL", @"Choice Title") andSubTitle:[url absoluteString] andIcon:[[SCAssetManager instance] imageForName:@"ico_webmail_import"] andCompletion:^()
                 {
                     [[UIApplication sharedApplication] openURL:url];
                 }];
                
            }
            
            for (NSString *phoneNumber in numbers) {
                NSString *intlNumber = [SIPUtil normalizePhoneNumber:phoneNumber];
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Call Number", @"MenuItem")];
                
                [cv addChoiceWithName:title andSubTitle:intlNumber andIcon:[[SCAssetManager instance] imageForName:@"btn_ico_call"] andCompletion:^{
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

-(BOOL) prepareDataDetectorActionForTextContentView:(SCTextEventContentView *) cv
{
    __weak SCBoard20Controller *weakself = self;
    
    [cv setDataTapAction:^(NSString * _Nonnull type, NSObject * _Nullable dataObject) {
        if ([type isEqualToString:@"url"]) {
            if ([dataObject isKindOfClass:[NSURL class]]) {
                NSURL *url = (NSURL *) dataObject;
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        
        if ([type isEqualToString:@"phone"]) {
            if ([dataObject isKindOfClass:[NSString class]]) {
                NSString *phoneNumber = (NSString *) dataObject;
                //NSString *intlNumber = [SIPUtil normalizePhoneNumber:phoneNumber];
                
                [[SIPPhone currentPhone] callNumber:phoneNumber];
            }

        }
        
        if ([type isEqualToString:@"user"]) {
            if ([dataObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *user = (NSDictionary *) dataObject;
                NSString *userid = user[@"userid"];
                if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
                    return;
                }
                
                if ([[C2CallPhone currentPhone] isGroupUser:userid]) {
                    [weakself showGroupDetailForGroupid:userid];
                } else {
                    [weakself showFriendDetailForUserid:userid];
                }
            }
        }
    }];
    
    [cv setDataLongPressAction:^(NSString * _Nonnull type, NSObject * _Nullable dataObject)
    {
        if ([type isEqualToString:@"url"])
        {
            if ([dataObject isKindOfClass:[NSURL class]])
            {
                NSURL *url = (NSURL *) dataObject;
                
                SCPopupMenu *popup = [SCPopupMenu popupMenu:self];
                
                [popup addChoiceWithName:NSLocalizedString(@"Open URL", @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     [[UIApplication sharedApplication] openURL:url];
                 }];
                
                [popup addChoiceWithName:NSLocalizedString(@"Add to Reading List", @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     [[SSReadingList defaultReadingList] addReadingListItemWithURL:url title:url.host previewText:url.absoluteString error:nil];
                 }];
                
                [popup addChoiceWithName:NSLocalizedString(@"Copy", @"Choice Title") andSubTitle:[url absoluteString] andIcon:nil andCompletion:^()
                {
                     [weakself copyText:[url absoluteString]];
                }];
                
                [popup addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
                }];
                
                [popup showMenu];
            }
        }
        
        if ([type isEqualToString:@"phone"]) {
            if ([dataObject isKindOfClass:[NSString class]]) {
                NSString *phoneNumber = (NSString *) dataObject;
                NSString *intlNumber = [SIPUtil normalizePhoneNumber:phoneNumber];
                
                [weakself copyText:intlNumber];
                
                UINavigationItem *item = weakself.parentViewController.navigationItem;
                if (!item) {
                    item = weakself.navigationItem;
                }
                
                item.prompt = @"Number copied...";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    item.prompt = nil;
                });
            }
            
        }
        
        if ([type isEqualToString:@"user"]) {
            if ([dataObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *user = (NSDictionary *) dataObject;
                NSString *userid = user[@"userid"];
                NSString *name = user[@"name"];
                
                if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
                    return;
                }

                SCPopupMenu *cv = [SCPopupMenu popupMenu:weakself];

                [cv addChoiceWithName:NSLocalizedString(name, @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     if ([[C2CallPhone currentPhone] isGroupUser:userid]) {
                         [weakself showGroupDetailForGroupid:userid];
                     } else {
                         [weakself showFriendDetailForUserid:userid];
                     }
                 }];

                [cv addChoiceWithName:NSLocalizedString(@"VoIP Call", @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     [[C2CallPhone currentPhone] callVoIP:userid];
                 }];

                [cv addChoiceWithName:NSLocalizedString(@"Video Call", @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     [[C2CallPhone currentPhone] callVideo:userid];
                 }];

                [cv addChoiceWithName:NSLocalizedString(@"Chat", @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     [weakself showChatForUserid:userid];
                 }];

                [cv addChoiceWithName:NSLocalizedString(@"Copy", @"Choice Title") andSubTitle:nil andIcon:nil andCompletion:^()
                 {
                     [weakself copyText:name];
                 }];

                [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
                }];
                
                [cv showMenu];
            }
        }
    }];

    return YES;
}

-(void) configureTextCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    NSString *text = bo.dataObject.text;
    
    NSDictionary<NSString *, NSArray*> *dataDetector = [self dataDetectorAction:text];
    
    //if (dataDetector) {
    //    [self prepareDataDetectorAction:dataDetector forCell:cell];
    //}
    
    [cell setLongpressAction:^{
        [weakself showLongpressMenuForCell:weakcell withMediaKey:text];
    }];
    
    if ([cell.eventContentView isKindOfClass:[SCTextEventContentView class]])
    {
        SCTextEventContentView *cv = (SCTextEventContentView *) cell.eventContentView;
        cv.containerCell = cell;
        [cv presentTextContent:text  withTextColor:[self textColorCellIn] andDataDetector:dataDetector];
        
        if (dataDetector)
        {
            [self prepareDataDetectorActionForTextContentView:cv];
            
            NSArray<NSURL *> *urls = dataDetector[@"url"];
            if([urls count] > 0)
            {
                NSString *link = [[urls firstObject] absoluteString];
                NSDictionary *cachedData = [[[SCLinkMetaInfo sharedInstance] cache] objectForKey:link];
                
                if(cachedData)
                {
                    [self processMetaData:cachedData forCell:cell];
                }
                else
                {
                    [[SCLinkMetaInfo sharedInstance] metadataForURL:[urls firstObject] completion:^(NSDictionary *data, NSString *errorMessage) {
                        if(data)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self reloadCellAtIndexPath:indexPath];
                            });
                        }
                    }];
                }
                
            }
        }
    }
}

-(void) configureTextCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    NSString *text = [bo.dataObject.text copy];
    
    NSDictionary<NSString *, NSArray*> *dataDetector = [self dataDetectorAction:text];
    
    //if (dataDetector) {
    //    [self prepareDataDetectorAction:dataDetector forCell:cell];
    //}
    
    [cell setLongpressAction:^{
        [weakself showLongpressMenuForCell:weakcell withMediaKey:text];
    }];
    
    if ([cell.eventContentView isKindOfClass:[SCTextEventContentView class]])
    {
        SCTextEventContentView *cv = (SCTextEventContentView *) cell.eventContentView;
        cv.containerCell = cell;
        [cv presentTextContent:text  withTextColor:[self textColorCellOut] andDataDetector:dataDetector];
        
        if (dataDetector)
        {
            [self prepareDataDetectorActionForTextContentView:cv];
            
            NSArray<NSURL *> *urls = dataDetector[@"url"];
            if([urls count] > 0)
            {
                NSString *link = [[urls firstObject] absoluteString];
                NSDictionary *cachedData = [[[SCLinkMetaInfo sharedInstance] cache] objectForKey:link];
                
                if(cachedData)
                {
                    [self processMetaData:cachedData forCell:cell];
                }
                else
                {
                    [[SCLinkMetaInfo sharedInstance] metadataForURL:[urls firstObject] completion:^(NSDictionary *data, NSString *errorMessage) {
                        if(data)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self reloadCellAtIndexPath:indexPath];
                            });
                        }
                    }];
                }
            }
        }
    }
}

-(void)reloadCellAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


-(void) configurePictureCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    [(SCPictureEventContentView*)cell.eventContentView setMessageText:bo.messageText withColor:[self textColorCellIn]];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;
    
    cell.contentAction.hidden = NO;
    NSString *mediaKey = bo.dataObject.text;
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxPictureSize]];
        
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        [cell setTapAction:^{
            [weakself showImage:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            UIImage *brokenImage = [[SCAssetManager instance] imageForName:@"ico_broken_image"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            
        } else {
            [cell startDownloadForKey:mediaKey];
        }
    }
    
}

-(void) configurePictureCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    [(SCPictureEventContentView*)cell.eventContentView setMessageText:bo.messageText withColor:[self textColorCellOut]];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    cell.sentMediaActionBtn.hidden = NO;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        
        UIImage *image = [[C2CallPhone currentPhone] imageForKey:mediaKey];
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [weakself setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
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
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
        }];
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            UIImage *brokenImage = [[SCAssetManager instance] imageForName:@"ico_broken_image"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            
        } else {
            [weakcell startDownloadForKey:mediaKey];
        }
    }
}

-(void) configureVideoCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    [(SCVideoEventContentView*)cell.eventContentView setMessage:bo.messageText withColor:[self textColorCellIn]];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

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
            UIImage *brokenImage = [[SCAssetManager instance] imageForName:@"ico_broken_video"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
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
            [weakself showVideo:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
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
    
    [(SCVideoEventContentView*)cell.eventContentView setMessage:bo.messageText withColor:[self textColorCellIn]];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    cell.sentMediaActionBtn.hidden = NO;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        
        UIImage *image = [self previewImageForKey:mediaKey maxSize:[self maxVideoSize]];
        
        [cell presentContentForKey:mediaKey withPreviewImage:image];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [weakself setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
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
            UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_image"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
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
            [weakself showVideo:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
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
    __weak SCBoard20Controller *weakself = self;

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
            UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_voice_msg"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
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
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
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
    __weak SCBoard20Controller *weakself = self;

    cell.sentMediaActionBtn.hidden = NO;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        [cell presentContentForKey:mediaKey withPreviewImage:nil];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [weakself setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
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
            UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_voice_msg"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
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
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
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
    __weak SCBoard20Controller *weakself = self;

    cell.contentAction.hidden = NO;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:mediaKey];
    [cell retrieveLocation:loc];
    
    [cell setOpenLocationAction:^{
        if (loc.locationUrl) {
            NSString *name = [loc.place objectForKey:@"name"];
            [weakself openBrowserWithUrl:loc.locationUrl andTitle:name];
        }
    }];
    
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    [cell setTapAction:^{
        [weakself showLocation:mediaKey forUser:sendername];
    }];
    
    [cell setLongpressAction:^{
        [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
    }];
    
}

-(void) configureLocationCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    cell.sentMediaActionBtn.hidden = NO;
    
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:mediaKey];
    [cell retrieveLocation:loc];
    
    [cell setOpenLocationAction:^{
        if (loc.locationUrl) {
            NSString *name = [loc.place objectForKey:@"name"];
            [weakself openBrowserWithUrl:loc.locationUrl andTitle:name];
        }
    }];
    
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    [cell setTapAction:^{
        [weakself showLocation:mediaKey forUser:sendername];
    }];
    
    [cell setLongpressAction:^{
        [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
    }];
    
    
}

-(NSString *) metaKeyForKey:(NSString *) mediaKey
{
    return [mediaKey stringByReplacingOccurrencesOfString:@"://" withString:@"://meta-"];
}

-(NSString *) thumbKeyForKey:(NSString *) mediaKey
{
    return [mediaKey stringByReplacingOccurrencesOfString:@"://" withString:@"://thumb-"];
}

-(void) retrieveAdditionalDataForBoardObject:(SCBoardObjectCoreData *) bocd withKey:(NSString *) key
{
    if ([[C2CallPhone currentPhone] hasObjectForKey:key]) {
        return;
    }
    
    if ([[C2CallPhone currentPhone] downloadStatusForKey:key]) {
        return;
    }
    
    __weak SCBoard20Controller *weakself = self;
    [[C2CallPhone currentPhone] retrieveObjectForKey:key completion:^(BOOL finished) {
        
        if (finished && [[C2CallPhone currentPhone] hasObjectForKey:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [weakself.dataSource indexPathForBoardObject:bocd];
                
                NSArray<NSIndexPath *> *pathlist = [weakself.tableView indexPathsForVisibleRows];
                if (pathlist) {
                    for (NSIndexPath *ipath in pathlist) {
                        if ([ipath isEqual:indexPath]) {
                            [weakself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    }
                }
            });
        }
    }];
}

-(void) configureFileCellIn:(SCBoardObjectEventCellIn *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellIn:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellIn *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    BOOL failed = NO, hasFile = NO;
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];

    NSString *thumbKey = [self thumbKeyForKey:mediaKey];
    [self retrieveAdditionalDataForBoardObject:bo withKey:thumbKey];

    NSString *metaKey = [self metaKeyForKey:mediaKey];
    [self retrieveAdditionalDataForBoardObject:bo withKey:metaKey];

    cell.contentAction.hidden = NO;
    
    UIImage *thumb = [[C2CallPhone currentPhone] thumbnailForKey:mediaKey];

    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        hasFile = YES;
    } else {
        
        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            
            UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_video"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        }
    }
    
    if (!failed && hasFile) {
        [cell setTapAction:^{
            [weakself showDocument:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
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
    __weak SCBoard20Controller *weakself = self;

    cell.sentMediaActionBtn.hidden = NO;
    
    BOOL failed = NO, hasFile = NO;
    MOC2CallEvent *elem = bo.dataObject;
    NSString *mediaKey = [elem.text copy];


    UIImage *thumb = [[C2CallPhone currentPhone] thumbnailForKey:mediaKey];

    
    NSString *thumbKey = [self thumbKeyForKey:mediaKey];
    [self retrieveAdditionalDataForBoardObject:bo withKey:thumbKey];

    NSString *metaKey = [self metaKeyForKey:mediaKey];
    [self retrieveAdditionalDataForBoardObject:bo withKey:metaKey];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        
        
        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        
        int status = [elem.status intValue];
        if (status == 3) {
            
            NSString *userid = [elem.contact copy];
            [cell setLongpressAction:^{
                [weakself setRetransmitActionForCell:weakcell withMediaKey:mediaKey andUserid:userid];
            }];
            
            return;
        }
        
        cell.readStatus.image = nil;
        [cell monitorUploadForKey:mediaKey];
        return;
    }
    
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        hasFile = YES;
    } else {
        [cell presentContentForKey:mediaKey withPreviewImage:thumb];
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediaKey]) {
            [cell monitorDownloadForKey:mediaKey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediaKey]) {
            // We need a broken link image here and a download button
            UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_video"];
            [cell presentContentForKey:mediaKey withPreviewImage:brokenImage];
            
            [cell setLongpressAction:^{
                [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:mediaKey];
            }];
            failed = YES;
        }
    }
    
    if (!failed && hasFile) {
        [cell setTapAction:^{
            [weakself showDocument:mediaKey];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:mediaKey];
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
    __weak SCBoard20Controller *weakself = self;

    
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
                    UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_vcard"];
                    [cell presentContentForKey:vcard withPreviewImage:brokenImage];
                    
                    [cell setLongpressAction:^{
                        [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:vcard];
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
        
        NSError *error = nil;
        NSArray<CNContact *> *personArray = [CNContactVCardSerialization contactsWithData:data error:&error];
        CNContact *person = [personArray count] > 0?  personArray[0] : nil;
        
        NSString *compositName = person ? [CNContactFormatter stringFromContact:person style:CNContactFormatterStyleFullName] : nil;
#
        //(NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
        NSData *imageData = person.imageData;
        UIImage *vcardImage = nil;
        
        if (imageData != NULL) {
            vcardImage = [UIImage imageWithData:imageData];
        }
        [cell presentContentForKey:compositName withPreviewImage:vcardImage];
        
        [cell setTapAction:^{
            [weakself showContact:vcard];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:vcard];
        }];
        
        if ([cell.eventContentView isKindOfClass:[SCContactEventContentView class]]) {
            SCContactEventContentView *cv = (SCContactEventContentView *) cell.eventContentView;
            
            cv.saveAction = [C2BlockAction actionWithAction:^(id sender) {
                
                if (person) {
                    NSError *error = nil;
                    
                    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
                    [saveRequest addContact:[person mutableCopy] toContainerWithIdentifier:nil];
                    
                    CNContactStore *store = [[CNContactStore alloc] init];
                    [store executeSaveRequest:saveRequest error:&error];
                    
                    if (error == nil) {
                        [AlertUtil showContactSaved];
                    } else {
                        [AlertUtil showContactSavedError];
                    }
                }
            }];
            
            cv.messageAction =[C2BlockAction actionWithAction:^(id sender) {
                [weakself showContact:vcard];
            }];
            
        }
        
        
    }
    @catch (NSException *exception) {
        DLog(@"Exception:setVCard : %@", exception);
    }
    @finally {
    }
    
}

-(void) configureVCardCellOut:(SCBoardObjectEventCellOut *) cell forBoardObject:(SCBoardObjectCoreData *) bo atIndexPath:(NSIndexPath *) indexPath
{
    [self configureEventCellOut:cell forBoardObject:bo atIndexPath:indexPath];
    
    __weak SCBoardObjectEventCellOut *weakcell = cell;
    __weak SCBoard20Controller *weakself = self;

    
    BOOL failed = NO;
    
    cell.sentMediaActionBtn.hidden = NO;
    
    NSString *vcard = bo.dataObject.text;
    @try {
        
        NSData *data = nil;
        if ([vcard hasPrefix:@"vcard://"]) {
            if (![[C2CallPhone currentPhone] hasObjectForKey:vcard]) {
                if ([[C2CallPhone currentPhone] downloadStatusForKey:vcard]) {
                    [cell monitorDownloadForKey:vcard];
                } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:vcard]) {
                    // We need a broken link image here and a download button
                    UIImage *brokenImage =[[SCAssetManager instance] imageForName:@"ico_broken_vcard"];
                    [cell presentContentForKey:vcard withPreviewImage:brokenImage];
                    
                    [cell setLongpressAction:^{
                        [weakself setRetransmitDownloadActionForCell:weakcell withMediaKey:vcard];
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
        
        
        NSError *error = nil;
        NSArray<CNContact *> *personArray = [CNContactVCardSerialization contactsWithData:data error:&error];
        CNContact *person = [personArray count] > 0?  personArray[0] : nil;
        
        NSString *compositName = person ? [CNContactFormatter stringFromContact:person style:CNContactFormatterStyleFullName] : nil;
#
        //(NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
        UIImage *vcardImage = nil;
        if(person.imageDataAvailable)
        {
            NSData *imageData = person.imageData;
            
            if (imageData != NULL) {
                vcardImage = [UIImage imageWithData:imageData];
            }
        }
        else
        {
            NSLog(@"Image data not available");
        }
        
        [cell presentContentForKey:compositName withPreviewImage:vcardImage];
        
        [cell setTapAction:^{
            //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0x42/255. green:0x85/255. blue:0xf4/255. alpha:1.0]];
            
            [weakself showContact:vcard];
        }];
        
        [cell setLongpressAction:^{
            [weakself showLongpressMenuForCell:weakcell withMediaKey:vcard];
        }];
        
        if ([cell.eventContentView isKindOfClass:[SCContactEventContentView class]]) {
            SCContactEventContentView *cv = (SCContactEventContentView *) cell.eventContentView;
            
            cv.saveAction = [C2BlockAction actionWithAction:^(id sender) {
                if (person) {
                    NSError *error = nil;
                    
                    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
                    [saveRequest addContact:[person mutableCopy] toContainerWithIdentifier:nil];
                    
                    CNContactStore *store = [[CNContactStore alloc] init];
                    [store executeSaveRequest:saveRequest error:&error];
                    
                    if (error == nil) {
                        [AlertUtil showContactSaved];
                    } else {
                        [AlertUtil showContactSavedError];
                    }
                }
            }];
            
            cv.messageAction = [C2BlockAction actionWithAction:^(id sender) {
                [weakself showContact:vcard];
            }];
        }
        
    }
    @catch (NSException *exception) {
        DLog(@"Exception:setVCard : %@", exception);
    }
    @finally {
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

#pragma mark - Link Preview

-(void)processMetaData:(NSDictionary*)metaData forCell:(SCBoardObjectEventCell*)cell
{
    if([cell.linkPreview.stackView.arrangedSubviews count] == 0)
    {
        UINib *nib = [UINib nibWithNibName:@"SCLinkPreview" bundle:[NSBundle bundleForClass:[SCLinkPreview class]]];
        [nib instantiateWithOwner:cell.linkPreview options:nil];

        @try
        {
            NSString *urlString = [[metaData valueForKey:@"link"] stringByRemovingPercentEncoding];
            urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [cell.linkPreview.contentView prepareLinkPreviewWithData:metaData];
            [cell.linkPreview.stackView addArrangedSubview:cell.linkPreview.contentView];
            cell.linkPreview.hidden = NO;
            [cell.linkPreview setNeedsUpdateConstraints];
            [cell layoutIfNeeded];
        }
        @catch(NSException *e)
        {
            NSLog(@"Exception :: %@",e);
        }
    }
}

#pragma mark - UITableView

// save height
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.cellHeightsDictionary setObject:@(cell.frame.size.height) forKey:indexPath];
}

/*
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}
 */

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

-(UISwipeActionsConfiguration *) tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCBoardObject *bo = [self.dataSource boardObjectAtIndexPath:indexPath];

    if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
        SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) bo;
        
        if ([bocd.dataObject.eventType isEqualToString:@"MessageIn"]) {
            if (@available(iOS 11.0, *)) {
                UIContextualAction *replyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Reply" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                    [self.delegate presentReplyToForEventId:[bocd.dataObject.eventId copy]];
                    completionHandler(true);
                }];
                return [UISwipeActionsConfiguration configurationWithActions:@[replyAction]];
            } else {
                return nil;
            }
        }
    }
    
    return nil;
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

-(void) scrollToLastVisibleRow
{
    NSArray<NSIndexPath *> *visibleRows = [self.tableView indexPathsForVisibleRows];
    if (visibleRows && [visibleRows count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[visibleRows lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
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
        
        if (!indexPaths || [indexPaths count] == 0) {
            return;
        }
        
        NSIndexPath *topIndexPath = indexPaths[0];
        if (topIndexPath.row <= 10 && !self.loadingPreviousMessages) {
            self.loadingPreviousMessages = YES;
            self.lastContentOffset = scrollView.contentOffset.y;
            
            DLog(@"SCBoardTest: dataSourceDidReloadContent : %@ / %@", @(coffset), @(topIndexPath.row));
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
                    
                    DLog(@"SCBoardTest: dataSourceDidReloadContent : %@/%@ - %@/%@ - %@/%@", @(topIndexPath.row), @(newIndexPath.row), @(before.origin.y), @(after.origin.y), @(contentOffset.y), @(self.lastContentOffset));
                    
                    
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

-(void) updateCell:(UITableViewCell *) cell
{
    NSArray<UITableViewCell *> *visibleCells = [self.tableView visibleCells];
    if ([visibleCells containsObject:cell]) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self customPrepareForSegue:segue sender:sender];
}

#pragma mark SCBoardDataSourceDelegate

-(void) incrContentCountForSection:(NSInteger) section by:(NSInteger) num
{
    DLog(@"SCBoardTest:incrContentCountForSection: %@", @(num));
    NSInteger count = [contentCount[section] integerValue];
    count += num;
    contentCount[section] = @(num);
}

-(void) decrContentCountForSection:(NSInteger) section by:(NSInteger) num
{
    DLog(@"SCBoardTest:decrContentCountForSection: %@", @(num));
    NSInteger count = [contentCount[section] integerValue];
    count -= num;
    contentCount[section] = @(num);
}

- (void)dataSource:(nonnull SCBoardDataSource *)dataSource didChangeObject:(nullable id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(SCBoardDataSourceChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
{
    DLog(@"SCBoardTest:dataSource:didChangeObject: %@ - %@",@(type), indexPath? @(indexPath.row) : @(newIndexPath.row));
    
    @try {
        switch(type) {
            case SCBoardDataSourceChangeInsert:
            {
                NSUInteger rows = [self.tableView numberOfRowsInSection:newIndexPath.section];
                insertedObjects++;
                [self incrContentCountForSection:newIndexPath.section by:1];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
                
                // On append message, scroll to bottom
                if (newIndexPath.row == rows) {
                    self.scrollToBottom = YES;
                }
            }
                break;
                
            case NSFetchedResultsChangeDelete:
                deletedObjects++;
                [self decrContentCountForSection:newIndexPath.section by:1];
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
    isChangingContent = YES;
    
    insertedObjects = 0;
    deletedObjects = 0;
    
    for (int i = 0; i < [dataSource numberOfSections]; i++) {
        contentCount[i] = @([dataSource numberOfRowsInSection:i]);
    }
    
    [self.tableView beginUpdates];
    DLog(@"SCBoardTest:dataSource:dataSourceWillChangeContent");
    
}

- (void)dataSourceDidChangeContent:(nonnull SCBoardDataSource *)dataSource;
{
    isChangingContent = NO;
    
    DLog(@"SCBoardTest:dataSourceDidChangeContent: inserted/deleted - %@/%@", @(insertedObjects), @(deletedObjects));
    
    @try {
        [self.tableView endUpdates];
    } @catch (NSException *exception) {
        [self.tableView reloadData];
    } @finally {
        DLog(@"SCBoardTest:dataSource:dataSourceDidChangeContent");
        
        if (self.scrollToBottom) {
            [self performScrollToBottom:NO];
        }
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

-(void) contentAction:(SCBoardObjectEventCellIn *)cell
{
    if ([cell.boardObject isKindOfClass:[SCBoardObjectCoreData class]]) {
        SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) cell.boardObject;
        
        [self shareRichMessageForKey:bocd.dataObject.text];
    }
}

-(void) sentMediaAction:(SCBoardObjectEventCellOut *)cell
{
    if ([cell.boardObject isKindOfClass:[SCBoardObjectCoreData class]])
    {
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
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Forward to friend", @"Choice SubTitle") andIcon:[[SCAssetManager instance] imageForName:@"ico_forward"] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    if ([self canShareWithApps:key]) {
        [cv addChoiceWithName:NSLocalizedString(@"Share", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via App", @"Choice SubTitle") andIcon:[[SCAssetManager instance] imageForName:@"ico_action"] andCompletion:^(){
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
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Forward to friend", @"Choice SubTitle") andIcon:[[SCAssetManager instance] imageForName:@"ico_forward"] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    if ([self canShareWithApps:key]) {
        [cv addChoiceWithName:NSLocalizedString(@"Share", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via App", @"Choice SubTitle") andIcon:[[SCAssetManager instance] imageForName:@"ico_action"] andCompletion:^(){
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
                iconSubmitted.image =[[SCAssetManager instance] imageForName:@"ico_deliverd_white"];
            } else {
                iconSubmitted.image =[[SCAssetManager instance] imageForName:@"ico_deliverd"];
            }
            [iconSubmitted setHidden:NO];
            break;
        case 3:
            if (isImage) {
                iconSubmitted.image =[[SCAssetManager instance] imageForName:@"ico_notdeliverd_white"];
            } else {
                iconSubmitted.image =[[SCAssetManager instance] imageForName:@"ico_notdelivered"];
            }
            [iconSubmitted setHidden:NO];
            break;
        case 4:
            if (isImage) {
                iconSubmitted.image =[[SCAssetManager instance] imageForName:@"ico_read_white"];
            } else {
                iconSubmitted.image =[[SCAssetManager instance] imageForName:@"ico_read"];
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

    __weak SCBoard20Controller *weakself = self;

    NSString *eventId = nil;
    if ([cell.boardObject isKindOfClass:[SCBoardObjectCoreData class]]) {
        SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) cell.boardObject;
        eventId = bocd.eventId;
    }
    
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Reply", @"MenuItem") action:@selector(answerAction:)];
    [cell setAnswerAction:^{
        if (eventId && [weakself.delegate respondsToSelector:@selector(presentReplyToForEventId:)]) {
            [weakself.delegate presentReplyToForEventId:eventId];
        }
    }];
    
    [menulist addObject:item];
    
    item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share", @"MenuItem") action:@selector(shareAction:)];
    [cell setShareAction:^{
        [weakself shareRichMessageForKey:mediaKey];
    }];
    [menulist addObject:item];
    
    
    if (mt == SCMEDIATYPE_TEXT) {
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [weakself copyText:mediaKey];
        }];
        [menulist addObject:item];
        
    }
    
    if (mt == SCMEDIATYPE_IMAGE) {
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [weakself copyImageForKey:mediaKey];
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

-(void) scrollToMessageWithEventId:(NSString *_Nonnull) eventId;
{
    NSIndexPath *indexPath = [self.dataSource indexPathForEventId:eventId];
    if (indexPath) {
        scrolledToIndexPath = indexPath;
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && scrolledToIndexPath)
    {
        SCBoardObjectEventCell *cell = (SCBoardObjectEventCell*)[self.tableView cellForRowAtIndexPath:scrolledToIndexPath];
        
        UIColor *bubbleBgColor = cell.bubbleView.backgroundColor;
        
        [UIView animateKeyframesWithDuration:1.0 delay:0 options:0 animations:^{
            
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                cell.bubbleView.backgroundColor = [UIColor lightGrayColor];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.7 animations:^{
                cell.bubbleView.backgroundColor = bubbleBgColor;
            }];
            
        } completion:^(BOOL finished) {
            scrolledToIndexPath = nil;
        }];
    }
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

