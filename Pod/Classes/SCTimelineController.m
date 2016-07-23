//
//  SCTimelineController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 06.07.16.
//
//

#import "UIViewController+SCCustomViewController.h"
#import "SCTimelineController.h"
#import "SCVLCVideoPlayerView.h"
#import "SCVideoPlayerView.h"
#import "MOTimelineEvent.h"
#import "C2CallPhone.h"
#import "SCPTTPlayer.h"
#import "SCTimeline.h"
#import "ImageUtil.h"
#import "FCLocation.h"
#import "C2BlockAction.h"

#import "debug.h"

// We need only one instance
static NSDateFormatter  *dateTime = nil;
static NSCache          *imageCache = nil;

@interface SCTimelineBaseCell ()

@property(nonatomic, strong) C2BlockAction                      *tapAction;
@property(nonatomic, strong) C2BlockAction                      *longpressAction;

@property (nonatomic, strong) UITapGestureRecognizer            *tapRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer      *longpressRecognizer;

@end

@implementation SCTimelineBaseCell

-(void) prepareForReuse
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.userName.text = @"";
    self.userImage.image = nil;
    
    self.timeLabel.text = @"";
    
    self.textView.text = @"";
    
    self.likesLabel.text = @"";
    self.mediaKey = nil;
    self.eventId = nil;
    [self.likeButton removeTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) configureCell:(MOTimelineEvent *) event
{
    self.eventId = [event.eventId copy];
    self.userName.text = event.senderName;
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:event.contact];
    if (image) {
        self.userImage.image = image;
    }
    
    self.timeLabel.text = [dateTime stringFromDate:event.timeStamp];
    
    self.textView.text = event.text;
    
    if ([event.like intValue] > 0) {
        self.likesLabel.text = [NSString stringWithFormat:@"(%d)", [event.like intValue]];
    } else {
        self.likesLabel.text = @"";
    }
    
    [self.likeButton addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    self.likeButton.enabled = [[SCTimeline instance] canLikeEvent:event.eventId];
}

-(IBAction)like:(id)sender
{
    [[SCTimeline instance] likeEvent:self.eventId];
    [self notifyCellUpdate:YES];
}

-(void) monitorUploadForKey:(NSString *) key
{
    if ([key rangeOfString:@"(null)"].location != NSNotFound) {
        return;
    }
    
    self.mediaKey = key;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNotification:) name:key object:nil];
}

-(void) monitorDownloadForKey:(NSString *) key
{
    if ([key rangeOfString:@"(null)"].location != NSNotFound) {
        return;
    }
    
    self.mediaKey = key;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgressNotification:) name:key object:nil];
}

-(void) uploadProgressNotification:(NSNotification *) notification
{
    if (self.mediaKey && [[notification name] isEqualToString:self.mediaKey]) {
        
        NSNumber *p = [notification.userInfo objectForKey:@"progress"];
        if (p) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadProgress:p];
            });
        }
        
        NSNumber *finished = [notification.userInfo objectForKey:@"finished"];
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadCompleted:[finished boolValue]];
            });
        }
    }
}

-(void) downloadProgressNotification:(NSNotification *) notification
{
    if (self.mediaKey && [[notification name] isEqualToString:self.mediaKey]) {
        
        NSNumber *p = [notification.userInfo objectForKey:@"progress"];
        if (p) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self downloadProgress:p];
            });
        }
        
        NSNumber *finished = [notification.userInfo objectForKey:@"finished"];
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self downloadCompleted:[finished boolValue]];
            });
        }
    }
    
}

-(void) uploadProgress:(NSNumber *) progress
{
    
}

-(void) downloadProgress:(NSNumber *) progress
{
    
}

-(void) uploadCompleted:(BOOL) success
{
    
}

-(void) downloadCompleted:(BOOL) success
{
    
}

-(IBAction)handleTap:(id)sender
{
    [self.tapAction fireAction:sender];
}

-(IBAction)handleLongpress:(id)sender
{
    [self.longpressAction fireAction:sender];
}

-(void) addTapAction:(C2BlockAction *)tapAction
{
    if (self.tapRecognizer) {
        [self.innerContentView removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.innerContentView addGestureRecognizer:tap];
    self.tapRecognizer = tap;
    
    self.tapAction = tapAction;
}

-(void) addLongpressAction:(C2BlockAction *)longpressAction
{
    if (self.longpressRecognizer) {
        [self.innerContentView removeGestureRecognizer:self.longpressRecognizer];
        self.longpressRecognizer = nil;
    }
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongpress:)];
    [self.innerContentView addGestureRecognizer:press];
    
    self.longpressRecognizer = press;
    
    self.longpressAction = longpressAction;
}

-(void) notifyCellUpdate
{
    [self notifyCellUpdate:NO];
}

-(void) notifyCellUpdate:(BOOL) forceReload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (forceReload) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SCTimelineCellUpdate" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(YES), @"reloadData", nil]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SCTimelineCellUpdate" object:self];
        }
        
    });
}

@end

@implementation SCTimelineVideoCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    //[self.videoView resetPlayer];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    self.videoView.layer.frame = self.videoView.bounds;
    
}

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    self.videoView.mediaUrl =  [[C2CallPhone currentPhone] mediaUrlForKey:event.mediaUrl];
}

@end

@implementation SCTimelineBroadcastCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.eventImage.image = nil;
}

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    NSString *bcast = event.mediaUrl;
    
    NSString *bcastId = [bcast substringFromIndex:@"bcast://".length];
    NSString *imageKey = [[C2CallPhone currentPhone] userimageKeyForUserid:bcastId];
    
    self.mediaKey = [imageKey copy];
    
    UIImage *img = [imageCache objectForKey:imageKey];
    
    if (!img) {
        UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
        
        if (img) {
            img = [ImageUtil fixImage:img withQuality:UIImagePickerControllerQualityTypeLow];
            [imageCache setObject:img forKey:imageKey];
            
            self.eventImage.image = img;
        } else {
            [[C2CallPhone currentPhone] retrieveObjectForKey:imageKey completion:^(BOOL finished) {
                if (finished && [self.mediaKey isEqualToString:imageKey]) {
                    UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
                    if (img) {
                        img = [ImageUtil fixImage:img withQuality:UIImagePickerControllerQualityTypeLow];
                        [imageCache setObject:img forKey:imageKey];
                        self.eventImage.image = img;
                        [self.eventImage setNeedsDisplay];
                        [self notifyCellUpdate:YES];
                    }
                    
                }
            }];
        }
    } else {
        self.eventImage.image = img;
    }

}

@end

@implementation SCTimelineImageCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.eventImage.image = nil;
}


-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    NSString *imageKey = event.mediaUrl;
    self.mediaKey = [imageKey copy];
    
    UIImage *img = [imageCache objectForKey:imageKey];
    
    if (!img) {
        UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
        
        if (img) {
            img = [ImageUtil fixImage:img withQuality:UIImagePickerControllerQualityTypeLow];
            [imageCache setObject:img forKey:imageKey];
            
            self.eventImage.image = img;
        } else {
            [[C2CallPhone currentPhone] retrieveObjectForKey:imageKey completion:^(BOOL finished) {
                if (finished && [self.mediaKey isEqualToString:imageKey]) {
                    UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
                    if (img) {
                        img = [ImageUtil fixImage:img withQuality:UIImagePickerControllerQualityTypeLow];
                        [imageCache setObject:img forKey:imageKey];
                        self.eventImage.image = img;
                        [self.eventImage setNeedsDisplay];
                        [self notifyCellUpdate:YES];
                    }
                    
                }
            }];
        }
    } else {
        self.eventImage.image = img;
    }
    
}

@end

@implementation SCTimelineAudioCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    [self.activity stopAnimating];
    [self.progress setProgress:0.0];
    
    if ([self.player isPlaying]) {
        [self.player pause];
    }
    self.player = nil;
    
}
- (void)dealloc
{
    if (self.tapGesture) {
        [self.innerContentView removeGestureRecognizer:self.tapGesture];
    }
}

-(IBAction)togglePlayPause:(id)sender
{
    [self.action fireAction:self];
}

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    __weak SCTimelineAudioCell  *weakself = self;
    
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlayPause:)];
        [self.innerContentView addGestureRecognizer:self.tapGesture];
        self.innerContentView.userInteractionEnabled;
    }
    
    NSString *mediakey = [event.mediaUrl copy];
    if ([[C2CallPhone currentPhone] hasObjectForKey:mediakey]) {
        NSString *duration = [[C2CallPhone currentPhone] durationForKey:mediakey];
        if ([duration length] == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *duration = [[C2CallPhone currentPhone] durationForKey:mediakey];
                DLog(@"Duration : %@", duration);
                self.durationLabel.text = duration;
            });
        } else {
            DLog(@"Duration : %@", duration);
            self.durationLabel.text = duration;
        }
        self.durationLabel.hidden = NO;
        
        [self.progress setHidden:NO];
        [self.progress setProgress:0];
        if ([self.player.mediaKey isEqualToString:mediakey]) {
            self.player.progress = self.progress;
            self.player.playButton = self.playButton;
        }
        
        self.action = [C2BlockAction actionWithAction:^(id sender) {
            if (weakself.player) {
                if ([weakself.player.mediaKey isEqualToString:mediakey]) {
                    if ([weakself.player isPlaying]) {
                        [weakself.player pause];
                    } else {
                        [weakself.player play];
                    }
                } else {
                    if ([weakself.player isPlaying]) {
                        [weakself.player pause];
                    }
                    weakself.player = nil;
                    weakself.player = [[SCPTTPlayer alloc] initWithMediaKey:mediakey];
                    weakself.player.progress = weakself.progress;
                    weakself.player.playButton = weakself.playButton;
                    [weakself.player play];
                }
            } else {
                weakself.player = nil;
                weakself.player = [[SCPTTPlayer alloc] initWithMediaKey:mediakey];
                weakself.player.progress = weakself.progress;
                weakself.player.playButton = weakself.playButton;
                [weakself.player play];
            }
        }];
    } else {
        self.mediaKey = mediakey;
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:mediakey]) {
            [self monitorDownloadForKey:mediakey];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:mediakey]) {
            // We need a broken link image here and a download button
            self.playButton.image = [UIImage imageNamed:@"ico_broken_voice_msg.png"];
            self.playButton.contentMode = UIViewContentModeScaleAspectFit;
            
            self.action = [C2BlockAction actionWithAction:^(id sender) {
                [weakself monitorDownloadForKey:mediakey];
                [[C2CallPhone currentPhone] retrieveObjectForKey:mediakey completion:^(BOOL finished) {
                    
                }];
            }];
        } else {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [self monitorDownloadForKey:mediakey];
                [[C2CallPhone currentPhone] retrieveObjectForKey:mediakey completion:^(BOOL finished) {
                    
                }];
            }
            
        }
    }
    
}

-(void) monitorDownloadForKey:(NSString *) key
{
    [super monitorDownloadForKey:key];
    
    [self.activity startAnimating];
}

-(void) downloadProgress:(NSNumber *) progress
{
    [self.progress setProgress:[progress floatValue] / 100.];
}

-(void) downloadCompleted:(BOOL) success
{
    [self.activity stopAnimating];
    [self.progress setProgress:0.];
    self.player = nil;
    self.player = [[SCPTTPlayer alloc] initWithMediaKey:self.mediaKey];
    self.player.progress = self.progress;
    self.player.playButton = self.playButton;
    [self.player play];
}

@end

@implementation SCTimelineMessageCell

-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    
}

@end


@implementation SCTimelineLocationCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    [self.activity stopAnimating];
    self.locationMapImage.image = nil;
    self.locationTitle.text = @"";
}


-(void) configureCell:(MOTimelineEvent *) event
{
    [super configureCell:event];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:event.mediaUrl];
    [self retrieveLocation:loc];
}

-(void) retrieveLocation:(FCLocation *) loc
{
    self.mediaKey = loc.locationKey;
    
    
    __weak SCTimelineLocationCell *weakself = self;
    if (loc.place) {
        NSString *name = [loc.place objectForKey:@"name"];
        self.locationTitle.text = name;
    } else if (loc.address) {
        NSArray *addr = [loc.address componentsSeparatedByString:@","];
        if ([addr count] > 0) {
            self.locationTitle.text = addr[0];
        }
    } else if (loc.reference && !loc.place) {
        [loc retrievePlacesInfoWithCompleteHandler:^(NSDictionary *place) {
            if ([weakself.mediaKey isEqualToString:loc.locationKey]) {
                NSString *name = [place objectForKey:@"name"];
                self.locationTitle.text = name;
            }
        }];
    } else {
        [loc retrieveAddressWithCompletionHandler:^(NSDictionary *location, NSString *address) {
            if ([weakself.mediaKey isEqualToString:loc.locationKey]) {
                NSArray *addr = [loc.address componentsSeparatedByString:@","];
                if ([addr count] > 0) {
                    self.locationTitle = addr[0];
                }
            }
        }];
    }
    
    UIImage *locImage = [imageCache objectForKey:self.mediaKey];
    if (locImage) {
        self.locationMapImage.image = locImage;
    } else {
        [self.activity startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *locImage = [ImageUtil imageFromLocation:loc];
            [imageCache setObject:locImage forKey:loc.locationKey];
            if (locImage && [weakself.mediaKey isEqualToString:loc.locationKey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activity stopAnimating];
                    self.locationMapImage.image = locImage;
                });
            }
        });
    }
    
}


@end

@interface SCTimelineController () {
    BOOL            showPreviousMessageButton;
    BOOL            scrollToBottom, scrollToTop;
    BOOL            didLoad;
    
    CFAbsoluteTime  lastContentChange;
}

@end

@implementation SCTimelineController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 160;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.cellIdentifier = @"SCTimelineBaseCell";
    self.emptyResultCellIdentifier = @"SCNoTimelineEventsCell";
    
    if (!dateTime) {
        dateTime = [[NSDateFormatter alloc] init];
        [dateTime setDateStyle:NSDateFormatterShortStyle];
        [dateTime setTimeStyle:NSDateFormatterShortStyle];
    }
    
    if (!imageCache) {
        imageCache = [[NSCache alloc] init];
    }
    
    [[SCTimeline instance] refreshTimeline];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellUpdate:) name:@"SCTimelineCellUpdate" object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cellUpdate:(NSNotification *) notification
{
    UITableViewCell *cell = [notification object];
    
    if (notification.userInfo[@"reloadData"]) {
        [self.tableView reloadData];
        return;
    }
    
    if (cell) {
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [UIView animateWithDuration:0.3 animations:^{
            [cell.contentView layoutIfNeeded];
        }];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = NO;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForTimeline:NO];
    
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchLimit:25];
    
    return fetchRequest;
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
            if (scrollToTop) {
                scrollToTop = NO;
                [self scrollToTop];
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

-(void) scrollToTop
{
    
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    });
}

-(void) scrollToTopOnUpdate
{
    scrollToTop = YES;
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
    
    scrollToTop = YES;
    //[self refreshTable];
}

-(void) resetLimits
{
    self.fetchLimit = 25;
    self.fetchSize = 25;
}

-(NSString *) reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseid = [super reuseIdentifierForIndexPath:indexPath];
    if ([reuseid isEqualToString:self.emptyResultCellIdentifier]) {
        return reuseid;
    }
    
    MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Picture]]) {
        return @"SCTimelineImageCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Video]]) {
        return @"SCTimelineVideoCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Audio]]) {
        return @"SCTimelineAudioCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_Location]]) {
        return @"SCTimelineLocationCell";
    }

    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityBroadcastEvent]]) {
        return @"SCTimelineBroadcastCell";
    }

    return self.cellIdentifier;
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SCTimelineBaseCell class]]) {
        SCTimelineBaseCell *bcell = (SCTimelineBaseCell *)cell;
        
        [bcell configureCell:event];
    }
    
    __weak SCTimelineController *weakself = self;
    
    // Additional Setup for image cell
    if ([cell isKindOfClass:[SCTimelineImageCell class]]) {
        C2BlockAction *action = [C2BlockAction actionWithAction:^(id sender) {
            [weakself showPhoto:event.mediaUrl];
        }];
        
        SCTimelineBaseCell *bcell = (SCTimelineBaseCell *)cell;
        [bcell addTapAction:action];
    }
    
    // Additional Setup for video cell
    if ([cell isKindOfClass:[SCTimelineVideoCell class]]) {
        __block CFAbsoluteTime didAction = 0;
        C2BlockAction *action = [C2BlockAction actionWithAction:^(id sender) {
            if (CFAbsoluteTimeGetCurrent() - didAction > 1.0) {
                didAction = CFAbsoluteTimeGetCurrent(); // For some reason this longpress action is called twice
                [weakself showVideo:event.mediaUrl];
            }
        }];
        
        SCTimelineBaseCell *bcell = (SCTimelineBaseCell *)cell;
        [bcell addLongpressAction:action];
    }
    
    // Additional Setup for location cell
    if ([cell isKindOfClass:[SCTimelineLocationCell class]]) {
        C2BlockAction *action = [C2BlockAction actionWithAction:^(id sender) {
            [weakself showLocation:event.mediaUrl forUser:event.senderName];
        }];
        
        SCTimelineBaseCell *bcell = (SCTimelineBaseCell *)cell;
        [bcell addTapAction:action];
    }
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.delegate) {
        [self.delegate timelineControllerDidScroll:scrollView];
    }
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    
    DLog(@"controllerDidChangeContent: %d", [[self.fetchedResultsController fetchedObjects] count]);
    if (scrollToTop) {
        scrollToTop = NO;
        [self scrollToTop];
    }
    //[self.tableView reloadData];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
