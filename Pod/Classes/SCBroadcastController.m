//
//  SCBroadcastController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 07/05/16.
//
//

#import "SCBroadcastController.h"
#import "SocialCommunication.h"
#import "MessageCell.h"
#import "MessageCellInStream.h"
#import "MessageCellOutStream.h"
#import "C2TapImageView.h"
#import "SCAssetManager.h"
#import "ImageUtil.h"

#import "debug.h"

@implementation SCBroadcastCellIn

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    //self.contentView.alpha = 1.0;
    
}

-(void) triggerFadeOut:(CGFloat) timer withCompleteHandler:(void (^)()) completion;
{
    //__weak UIView *weakview = self.contentView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timer * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
        
        /*
        [UIView animateWithDuration:0.5 animations:^{
            weakview.alpha = 0.;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
         */
    });
}

@end

@implementation SCBroadcastCellOut

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    //self.contentView.alpha = 1.0;
    
}

-(void) triggerFadeOut:(CGFloat) timer withCompleteHandler:(void (^)()) completion;
{
    //__weak UIView *weakview = self.contentView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timer * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
        
        /*
         [UIView animateWithDuration:0.5 animations:^{
         weakview.alpha = 0.;
         } completion:^(BOOL finished) {
         if (completion) {
         completion();
         }
         }];
         */
    });
}

@end


@interface SCBroadcastController () {
    BOOL            showPreviousMessageButton;
    BOOL            scrollToBottom;
    
    CFAbsoluteTime  lastContentChange;
}

@property (nonatomic, strong) UIFont                        *textFieldInFont, *textFieldOutFont;
@property (nonatomic, strong) UIFont                        *headerFieldInFont, *headerFieldOutFont;
@property (nonatomic, strong) SCBroadcastCellIn             *broadcastCellIn;
@property (nonatomic, strong) SCBroadcastCellOut            *broadcastCellOut;
@property (atomic, strong) NSMutableArray                   *chat;
@property (atomic, strong) NSString                         *lastEvent;

@property (nonatomic, strong) NSCache                       *smallImageCache;

@end

@implementation SCBroadcastController


-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized || !self.broadcastGroupId)
        return nil;
    
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = YES;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForEventHistory:nil sort:NO];
    
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"contact == %@ AND eventType contains[cd] %@", self.broadcastGroupId, @"message"];
    
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchLimit:8];
    
    /*
    [fetchRequest setFetchBatchSize:self.fetchLimit >= 0? self.fetchLimit:0];
    
    int offset = 0;
    if (self.fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:self.fetchLimit forFetchRequest:fetchRequest];
    }
    
    showPreviousMessageButton = offset > 0;
    */
    
    return fetchRequest;
}

-(id) copyCell:(id) cell
{
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:cell];
    cell = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    return cell;
}

-(void) refreshTable
{
    lastContentChange = CFAbsoluteTimeGetCurrent();
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (CFAbsoluteTimeGetCurrent() - lastContentChange > 0.15) {
            [self.tableView reloadData];
            
            if (scrollToBottom) {
                scrollToBottom = NO;
                [self scrollToBottom];
            }
        }
    });
}

-(void) scrollToBottom
{
    
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.tableView.numberOfSections > 0) {
            int section = (int)self.tableView.numberOfSections - 1;
            int row =  (int)[self.tableView numberOfRowsInSection:section] - 1;
            if (section >= 0 && row >= 0)
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    });
}

-(void) refetchResults
{
    NSFetchRequest *fetchRequest = [self.fetchedResultsController fetchRequest];
    [fetchRequest setFetchLimit:0];
    [fetchRequest setFetchOffset:0];
    
    int offset = 0;
    if (self.fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:self.fetchLimit forFetchRequest:fetchRequest];
    }
    
    [fetchRequest setFetchLimit:self.fetchLimit];
    [fetchRequest setFetchOffset:offset];
    
    showPreviousMessageButton = offset > 0;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        DLog(@"Error : %@", error);
    }
    
    //[self refreshTable];
}

-(void) resetLimits
{
    self.fetchLimit = 6;
    self.fetchSize = 6;
}

- (UIView *)findFirstResponder:(UIView *) startView
{
    if (startView.isFirstResponder) {
        return startView;
    }
    
    for (UIView *subView in startView.subviews) {
        UIView *firstResponder = [self findFirstResponder:subView];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}

- (UIView *)findBubbleView:(UIView *) startView
{
    if ([startView isKindOfClass:[SCBubbleViewIn class]] || [startView isKindOfClass:[SCBubbleViewOut class]]) {
        return startView;
    }
    
    for (UIView *subView in startView.subviews) {
        UIView *v = [self findBubbleView:subView];
        
        if (v != nil) {
            return v;
        }
    }
    
    return nil;
}


-(NSString *) identifierForElement:(MOC2CallEvent *) elem
{
    NSString *eventType = elem.eventType;
    NSString *text = elem.text;
    NSString *cellIdentifier = nil;
    
    DLog(@"EventType : %@", eventType);
    if ([eventType isEqualToString:@"CallIn"]) {
        cellIdentifier = @"CallCellInStream";
    } else if ([eventType isEqualToString:@"CallOut"]) {
        cellIdentifier = @"CallCellOutStream";
    } else if ([eventType isEqualToString:@"MessageOut"] || [eventType isEqualToString:@"MessageSubmit"]) {
        cellIdentifier = @"SCBroadcastCellOut";
        
        if ([text hasPrefix:@"image://"]) {
            cellIdentifier = @"ImageCellOutStream";
        }
        if ([text hasPrefix:@"video://"]) {
            cellIdentifier = @"VideoCellOutStream";
        }
        if ([text hasPrefix:@"audio://"]) {
            cellIdentifier = @"AudioCellOutStream";
        }
        if ([text hasPrefix:@"file://"]) {
            cellIdentifier = @"FileCellOutStream";
        }
        if ([text hasPrefix:@"loc://"]) {
            cellIdentifier = @"LocationCellOutStream";
        }
        if ([text hasPrefix:@"BEGIN:VCARD"]) {
            cellIdentifier = @"ContactCellOutStream";
        }
        if ([text hasPrefix:@"vcard://"]) {
            cellIdentifier = @"ContactCellOutStream";
        }
        if ([text hasPrefix:@"friend://"]) {
            cellIdentifier = @"FriendCellOutStream";
        }
    } else {
        cellIdentifier = @"SCBroadcastCellIn";
        
        if ([text hasPrefix:@"image://"]) {
            cellIdentifier = @"ImageCellInStream";
        }
        if ([text hasPrefix:@"video://"]) {
            cellIdentifier = @"VideoCellInStream";
        }
        if ([text hasPrefix:@"audio://"]) {
            cellIdentifier = @"AudioCellInStream";
        }
        if ([text hasPrefix:@"file://"]) {
            cellIdentifier = @"FileCellInStream";
        }
        if ([text hasPrefix:@"loc://"]) {
            cellIdentifier = @"LocationCellInStream";
        }
        if ([text hasPrefix:@"BEGIN:VCARD"]) {
            cellIdentifier = @"ContactCellInStream";
        }
        if ([text hasPrefix:@"vcard://"]) {
            cellIdentifier = @"ContactCellInStream";
        }
        if ([text hasPrefix:@"friend://"]) {
            cellIdentifier = @"FriendCellInStream";
        }
    }
    
    return cellIdentifier;
}

-(void)startObservingContentSizeChanges
{
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentSize"] && object == self.tableView)
    {
        // difference between content and table heights. +1 accounts for last row separator
        CGFloat height = MAX(self.tableView.frame.size.height - self.tableView.contentSize.height, 0) + 1;
        
        self.tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
        
        // "scroll" to top taking inset into account
        [self.tableView setContentOffset:CGPointMake(0, -height) animated:NO];
        
    }
}

-(UIImage *) imageForElement:(MOC2CallEvent *) elem
{
    UIImage *image = [self.smallImageCache objectForKey:elem.contact];
    if (image)
        return image;
    
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    image = [[C2CallPhone currentPhone] userimageForUserid:elem.contact];
    if (image) {
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
    }
    
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:elem.contact];
    if ([user.userType intValue] == 2) {
        image = [UIImage imageNamed:@"btn_ico_avatar_group" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
        
    }
    
    image = [UIImage imageNamed:@"btn_ico_avatar" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
    image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
    [self.smallImageCache setObject:image forKey:elem.contact];
    return image;
}

-(UIImage *) ownUserImage
{
    UIImage *image = [self.smallImageCache objectForKey:[SCUserProfile currentUser].userid];
    if (image)
        return image;
    
    image = [[C2CallPhone currentPhone] userimageForUserid:[SCUserProfile currentUser].userid];
    if (image) {
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
        [self.smallImageCache setObject:image forKey:[SCUserProfile currentUser].userid];
        return image;
    }
    
    NSBundle *frameWorkBundle = [SCAssetManager instance].imageBundle;
    image = [UIImage imageNamed:@"btn_ico_avatar" inBundle:frameWorkBundle compatibleWithTraitCollection:nil];
    image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:3.];
    [self.smallImageCache setObject:image forKey:[SCUserProfile currentUser].userid];
    return image;
}

-(void) handleNotificationEvent:(NSNotification *) notification
{
    DLog(@"C2MessageController:handleEvent : %@:%@", [notification name], [notification userInfo]);
    
    @try {
        if ([[notification name] isEqualToString:@"C2Call:LogoutUser"]) {
            self.fetchedResultsController.delegate = nil;
            self.fetchedResultsController = nil;
            [self refreshTable];
        }
        
        if ([[notification name] isEqualToString:@"UserImageUpdate"]) {
            [self.smallImageCache removeAllObjects];
            [self refreshTable];
        }
        
        if ([[notification name] isEqualToString:@"TransferCompleted"]) {
            [self refreshTable];
        }
        
    }
    @catch (NSException * e) {
        DLog(@"SCBoardController : %@", e);
    }
    
}


-(void) awakeFromNib
{
    [super awakeFromNib];
    
    [self resetLimits];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DLog(@"SCBroadcastController:viewDidLoad : %@", self.broadcastGroupId);
    
    self.tableView.estimatedRowHeight = 76;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.chat = [NSMutableArray arrayWithCapacity:10];
    
    self.broadcastCellIn = [self.tableView dequeueReusableCellWithIdentifier:@"SCBroadcastCellIn"];
    self.broadcastCellOut = [self.tableView dequeueReusableCellWithIdentifier:@"SCBroadcastCellOut"];
    
    // Initialize Font for TextBubble
    MessageCell *cell = (MessageCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MessageCellInStream"];
    self.textFieldInFont = cell.textfield.font;
    self.headerFieldInFont = cell.headline.font;

    DLog(@"textFieldInFont : %@", self.textFieldInFont);
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCellOutStream"];
    self.textFieldOutFont = cell.textfield.font;
    self.headerFieldOutFont = cell.headline.font;

    DLog(@"textFieldOutFont : %@", self.textFieldOutFont);
    
    
    if (!self.smallImageCache) {
        self.smallImageCache = [[NSCache alloc] init];
    }
    
    self.cellLBM = NSLineBreakByWordWrapping;
    
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_kork"]];
    
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    scrollToBottom = YES;
    
    [self resetLimits];
    if (!self.fetchedResultsController && [SCDataManager instance].isDataInitialized) {
        [self refreshTable];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"UserImageUpdate" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"C2Call:LogoutUser" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"TransferCompleted" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    
    [self startObservingContentSizeChanges];
    
//    [self.previousMessagesButton setTitle:NSLocalizedString(@"Show previous messages", @"Button") forState:UIControlStateNormal];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottom];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIView *firstResponder = [self findFirstResponder:self.view];
    [firstResponder resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"willDisplayCell : %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    
    UIView *bv = [self findBubbleView:cell];
    [bv setNeedsLayout];
    
}

-(void) configureMessageCellIn:(__weak SCBroadcastCellIn *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    cell.userImage.image = [self imageForElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.senderName.text = sendername;
    cell.messageText.text = text;

    // Cell re-use for new content
    if (!cell.eventId || ![cell.eventId isEqualToString:elem.eventId]) {
        cell.eventId = [elem.eventId copy];
        cell.contentView.alpha = 1.0;
        
        __weak SCBroadcastController *weakself = self;
        [cell triggerFadeOut:6. withCompleteHandler:^{
            [weakself.tableView beginUpdates];
            NSUInteger idx = [weakself.chat indexOfObject:cell];
            [weakself.chat removeObject:cell];
            
            if([weakself.chat count] > 0)
            {
                [weakself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                [weakself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                //[weakself.tableView  deleteSections:[NSIndexSet indexSetWithIndex:0]
                //          withRowAnimation:UITableViewRowAnimationFade];
            }
            [weakself.tableView endUpdates];
            
        }];
    }
}

-(void) configureMessageCellOut:(__weak SCBroadcastCellOut *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    cell.userImage.image = [self ownUserImage];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    sendername = [NSString stringWithFormat:@"@%@",  sendername];
    cell.senderName.text = sendername;
    cell.messageText.text = text;
    
    // Cell re-use for new content
    if (!cell.eventId || ![cell.eventId isEqualToString:elem.eventId]) {
        cell.eventId = [elem.eventId copy];
        cell.contentView.alpha = 1.0;
        
        __weak SCBroadcastController *weakself = self;
        [cell triggerFadeOut:6. withCompleteHandler:^{
            [weakself.tableView beginUpdates];
            NSUInteger idx = [weakself.chat indexOfObject:cell];
            [weakself.chat removeObject:cell];
            
            if([weakself.chat count] > 0)
            {
                [weakself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                [weakself.tableView  deleteSections:[NSIndexSet indexSetWithIndex:0]                                   withRowAnimation:UITableViewRowAnimationFade];
            }
            [weakself.tableView endUpdates];
        }];
    }

}

-(void) configureCell:(MessageCell *) cell atIndexPath:(NSIndexPath *) indexPath
{
    // Set up the cell...
    MOC2CallEvent *elem = nil;
    @try {
        elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        return;
    }
    
    if ([cell isKindOfClass:[SCBroadcastCellIn class]]) {
        [self configureMessageCellIn:(SCBroadcastCellIn *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[SCBroadcastCellOut class]]) {
        [self configureMessageCellOut:(SCBroadcastCellOut *) cell forEvent:elem atIndexPath:indexPath];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chat count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"cellForRowAtIndexPath : %ld, %ld", (long)indexPath.section, (long)indexPath.row);
 
    id obj = [self.chat objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[MOC2CallEvent class]]) {
        MOC2CallEvent *elem = obj;
        if ([elem.eventType isEqualToString:@"MessageIn"]) {
            SCBroadcastCellIn *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SCBroadcastCellIn" forIndexPath:[NSIndexPath indexPathForRow:[self.chat count] inSection:0]];
            [self configureMessageCellIn:cell forEvent:elem atIndexPath:nil];
            [self.chat replaceObjectAtIndex:indexPath.row withObject:cell];
            return cell;
        } else {
            SCBroadcastCellOut *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SCBroadcastCellOut" forIndexPath:[NSIndexPath indexPathForRow:[self.chat count] inSection:0]];
            [self configureMessageCellOut:cell forEvent:elem atIndexPath:nil];
            [self.chat replaceObjectAtIndex:indexPath.row withObject:cell];
            return cell;
        }
    } else {
        UITableViewCell *cell = obj;
        
        return cell;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //    if (!isVisible)
    //        return;
    [super controllerDidChangeContent:controller];
    
    if (!self.lastEvent || [self.chat count] == 0) {
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            [self.tableView beginUpdates];
            MOC2CallEvent *elem = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
            [self.chat insertObject:elem atIndex:[self.chat count]];
            self.lastEvent = [elem.eventId copy];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];

        }
    } else {
        [self.tableView beginUpdates];
        NSArray *list = [[self.fetchedResultsController fetchedObjects] copy];
        NSMutableArray *addlist = [NSMutableArray arrayWithCapacity:10];
        for (MOC2CallEvent *elem in list) {
            if ([elem.eventId isEqualToString:self.lastEvent]) {
                break;
            }
            [addlist insertObject:elem atIndex:[addlist count]];
        }
        
        NSMutableArray *addrows = [NSMutableArray arrayWithCapacity:10];
        for (MOC2CallEvent *elem in addlist) {
            [addrows addObject:[NSIndexPath indexPathForRow:[self.chat count] inSection:0]];
            [self.chat insertObject:elem atIndex:[self.chat count]];
            
            self.lastEvent = [elem.eventId copy];
        }
        [self.tableView insertRowsAtIndexPaths:addrows withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        
    }
    
    //[self scrollToBottom];
    
}


@end
