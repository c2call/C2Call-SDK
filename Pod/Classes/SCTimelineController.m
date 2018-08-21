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
#import "SCBroadcastPlaybackController.h"
#import "SCBroadcastChatController.h"
#import "SCVideoPlayerView.h"
#import "MOTimelineEvent.h"
#import "MOTag.h"
#import "C2CallPhone.h"
#import "SCPTTPlayer.h"
#import "SCTimeline.h"
#import "ImageUtil.h"
#import "FCLocation.h"
#import "C2BlockAction.h"
#import "SCBroadcast.h"

#define __C2DEBUG

#import "debug.h"

// We need only one instance
static NSDateFormatter  *dateTime = nil;
static NSCache          *imageCache = nil;
static NSCache          *assetCache = nil;


@interface SCTimelineBaseCell ()

@property(nonatomic, strong) C2BlockAction                      *tapAction;
@property(nonatomic, strong) C2BlockAction                      *longpressAction;

@property (nonatomic, strong) UITapGestureRecognizer            *tapRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer      *longpressRecognizer;

@end

@implementation SCTimelineBaseCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.userName.text = @"";
    self.userImage.image = nil;
    
    self.timeLabel.text = @"";
    
    self.textView.text = @"";
    
    self.likesLabel.text = @"";
    self.mediaKey = nil;
    self.eventId = nil;
    self.campaignId = nil;
    self.featured = NO;
    [self.likeButton removeTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    NSString *name = event.senderName;
    if ([name isEqualToString:event.contact]) {
        if ([[C2CallPhone currentPhone] getUserInfoForUserid:event.contact] != nil) {
            name = [[C2CallPhone currentPhone] nameForUserid:event.contact];
        }
    }
    
    self.controller = controller;
    self.eventId = [event.eventId copy];
    self.userName.text = ![name isEqualToString:event.contact] ? name : NSLocalizedString(@"Unknown User", @"Name Label");
    self.featured = [event.featured boolValue];
    self.mediaKey = [event.mediaUrl copy];
    self.contact = [event.contact copy];
    
    if ([event.reward hasPrefix:@"deal://"]) {
        self.campaignId = [event.reward substringFromIndex:[@"deal://" length]];
    }
    
    if ([event.tags count] > 0) {
        NSMutableArray *tags = [NSMutableArray arrayWithCapacity:[event.tags count]];
        for (MOTag *tag in event.tags) {
            BOOL tagFeatured = [tag.featured boolValue];
            [tags addObject:@{@"tag": [tag.tag copy], @"referenceUrl": tag.referenceUrl?[tag.referenceUrl copy]: @"", @"reward":tag.reward? [tag.reward copy]: @"", @"description" : tag.infoText? [tag.infoText copy]: @"", @"featured" : tagFeatured? @"true" : @"false"}];
        }
        self.tags = tags;
    }
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:event.contact];
    if (image) {
        self.userImage.image = image;
    } else {
        self.userImage.image = [UIImage imageNamed:@"ico_timeline_user"];
    }
    
    self.timeLabel.text = [self timeAgo:event.timeStamp];
    
    if (event.text) {
        self.textView.text = event.text;
    } else {
        self.textView.text = @"";
    }
    
    if ([event.like intValue] > 0) {
        self.likesLabel.text = [NSString stringWithFormat:@"(%d)", [event.like intValue]];
    } else {
        self.likesLabel.text = @"";
    }
    
    [self.likeButton addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    self.likeButton.enabled = [[SCTimeline instance] canLikeEvent:event.eventId];
}

-(NSString*)timeAgo:(NSDate*)fromDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay;
    //NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDate *now = [NSDate date];
    NSDate *earliest = [now earlierDate:fromDate];
    NSDate *latest = (earliest == now) ? fromDate : now;
    
    NSDateComponents *components = [calendar components:units fromDate:earliest toDate:latest options:0];
    
    if (components.day > 5) {
        return [dateTime stringFromDate:fromDate];
    }
    else if (components.day >= 2) {
        return [[NSString alloc] initWithFormat:@"%d days ago",(int)components.day];
    }
    else if (components.day >= 1) {
        return @"Yesterday";
    }
    else if (components.hour >= 2) {
        return [[NSString alloc] initWithFormat:@"%d hours ago",(int)components.hour];
    }
    else if (components.hour >= 1) {
        return @"An hour ago";
    }
    else if (components.minute >= 2) {
        return [[NSString alloc] initWithFormat:@"%d minutes ago",(int)components.minute];
    }
    else if (components.minute >= 1) {
        return @"A minute ago";
    }
    else {
        return @"Just now";
    }
}

-(CGFloat) previewHeightForMediaSize:(CGSize) sz
{
    CGSize szview = self.contentView.frame.size;
    
    if (sz.height == 0)
        return 0;
    
    CGFloat aspect = sz.width / sz.height;
    CGFloat height = floor(szview.width / aspect);
    
    SCTimelineController *tc = self.controller;
    
    if (height > tc.maxPreviewHeight) {
        height = tc.maxPreviewHeight;
    }
    
    return height;
}

-(IBAction)like:(id)sender
{
    [[SCTimeline instance] likeEvent:self.eventId];
    [self notifyCellUpdate:YES];
}

-(IBAction)share:(id)sender
{
    [self.controller sharePostWithText:self.textView.text andMediaKey:self.mediaKey];
}

-(IBAction)menuExtra:(id)sender
{
    [self.controller showMenuExtraForItem:[self.eventId stringValue] withCampaign:self.campaignId withText:self.textView.text andMediaKey:self.mediaKey featured:self.featured];
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

-(IBAction) openProfile:(id)sender
{
    // That's me
    if ([self.contact isEqualToString:[SCUserProfile currentUser].userid]) {
        return;
    }
    
    [self.controller openProfile:self.contact];
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
            [self.controller updateCellIfNeeded:self];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"SCTimelineCellUpdate" object:self];
        }
        
    });
}

@end

@implementation SCTimelineVideoCell

-(void) prepareForReuse
{
    if (self.videoView.urlAsset && self.mediaKey) {
        [assetCache setObject:self.videoView.urlAsset forKey:self.mediaKey];
        
        //[self.videoView setMediaAsset:nil];
        self.videoView.mediaUrl = nil;
    }
    
    [super prepareForReuse];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    self.videoView.layer.frame = self.videoView.bounds;
    
}

-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
    NSString *mediaKey = [event.mediaUrl copy];
    __weak SCTimelineVideoCell *weakself = self;
    
    AVURLAsset *asset = [assetCache objectForKey:mediaKey];
    if (asset) {
        // Check Status Loaded
        NSError *error;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        if (status == AVKeyValueStatusLoaded) {
            [self.videoView setMediaAsset:asset];
            return;
        }
    }
    
    self.videoView.mediaUrl = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url =  [[C2CallPhone currentPhone] mediaUrlForKey:mediaKey];
        
        if ([weakself.mediaKey isEqualToString:mediaKey]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.videoView.mediaUrl = url;
            });
        }
    });
}

@end

@interface SCTimelineBroadcastCell () {
    BOOL _isLife;
}

@end

@implementation SCTimelineBroadcastCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isLife = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(broadcastStateChanged:) name:@"SCBroadcastStateChanged" object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _isLife = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(broadcastStateChanged:) name:@"SCBroadcastStateChanged" object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isLife = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(broadcastStateChanged:) name:@"SCBroadcastStateChanged" object:nil];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isLife = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(broadcastStateChanged:) name:@"SCBroadcastStateChanged" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) broadcastStateChanged:(NSNotification *) notification
{
    if (!self.bcastId)
        return;
    
    NSArray *idlist = [notification userInfo][@"liveBC"];
    if ([idlist containsObject:self.bcastId]) {
        [self isLife:YES];
    } else {
        [self isLife:NO];
    }
}

-(void) isLife:(BOOL) isLife
{
    if (_isLife != isLife) {
        _isLife = isLife;
        
        [self notifyCellUpdate:NO];
    }
}

-(void) onlineUsers:(NSInteger) onlineUsers
{
    
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.eventImage.image = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _isLife = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(broadcastStateChanged:) name:@"SCBroadcastStateChanged" object:nil];
}

-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
    NSString *bcast = event.mediaUrl;
    
    NSString *bcastId = [bcast substringFromIndex:@"bcast://".length];
    self.bcastId = bcastId;
    
    NSString *imageKey = [[C2CallPhone currentPhone] userimageKeyForUserid:bcastId];
    
    self.bcastImageKey = [imageKey copy];
    
    self.textView.text = event.text? [event.text copy] : @"";
    self.broadcastInfo.text = @"";
    
    NSLog(@"Get Broadcast Info: %@", bcastId);
    
    __weak SCTimelineBroadcastCell *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SCBroadcast *broadcast = [[SCBroadcast alloc] initWithBroadcastGroupid:bcastId retrieveFromServer:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Broadcast Info Received: %@", bcastId);
            
            if (![broadcast.groupid isEqualToString:weakself.bcastId]) {
                NSLog(@"Not longer valid!");
                return;
            }
            
            [weakself broadcastDataLoaded:broadcast];
        });
    });
    
    
    
    UIImage *img = [imageCache objectForKey:imageKey];
    
    if (!img) {
        UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
        
        
        if (img) {
            img = [ImageUtil fixImage:img withQuality:UIImagePickerControllerQualityTypeLow];
            [imageCache setObject:img forKey:imageKey];
            
            self.eventImage.image = img;
        } else {
            [[C2CallPhone currentPhone] retrieveObjectForKey:imageKey completion:^(BOOL finished) {
                if (finished && [self.bcastImageKey isEqualToString:imageKey]) {
                    UIImage *img = [[C2CallPhone currentPhone] imageForKey:imageKey];
                    if (img) {
                        img = [ImageUtil fixImage:img withQuality:UIImagePickerControllerQualityTypeLow];
                        [imageCache setObject:img forKey:imageKey];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.eventImage.image = img;
                            [self.eventImage setNeedsDisplay];
                            [self notifyCellUpdate:NO];
                        });
                    }
                    
                }
            }];
        }
    } else {
        self.eventImage.image = img;
    }
    
}

-(void) broadcastDataLoaded:(SCBroadcast *) broadcast
{
    NSString *broadcastText = @"";
    if ([broadcast.groupName length] > 0 && [broadcast.groupDescription length] > 0) {
        broadcastText = [NSString stringWithFormat:@"%@\n%@", broadcast.groupName, broadcast.groupDescription];
    } else if ([broadcast.groupName length] > 0) {
        broadcastText = broadcast.groupName;
    } else if ([broadcast.groupDescription length] > 0) {
        broadcastText = broadcast.groupDescription;
    }
    
    if ([broadcast isLive]) {
        [self isLife:YES];
        [self onlineUsers:broadcast.onlineUsers];
        self.broadcastInfo.text = @"Live Broadcast";
        self.textView.text = broadcastText;
        [[SCTimeline instance] startLiveBroadcastMonitoring];
    } else {
        if (broadcast.startDate || broadcast.endDate) {
            
            [self isLife:NO];
            [self onlineUsers:broadcast.onlineUsers];
            
            self.textView.text = broadcastText;
            if (broadcast.endDate) {
                self.broadcastInfo.text = [NSString stringWithFormat:@"Broadcast Ended at %@", [dateTime stringFromDate:broadcast.endDate]];
            } else {
                self.broadcastInfo.text = [NSString stringWithFormat:@"Broadcast Started at %@", [dateTime stringFromDate:broadcast.startDate]];
            }
        }
        
    }
    
}

@end

@implementation SCTimelineImageCell

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.eventImage.image = nil;
}


-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.eventImage.image = img;
                            [self.eventImage setNeedsDisplay];
                            
                            [self notifyCellUpdate:NO];
                        });
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

-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
    __weak SCTimelineAudioCell  *weakself = self;
    
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlayPause:)];
        [self.innerContentView addGestureRecognizer:self.tapGesture];
        self.innerContentView.userInteractionEnabled = YES;
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

-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
    
}

@end

@implementation SCTimelineEventCell

-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
    
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


-(void) configureCell:(MOTimelineEvent *) event controller:(SCTimelineController *)controller
{
    [super configureCell:event controller:controller];
    
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
                    self.locationTitle.text = addr[0];
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
    BOOL            initialRefresh;
    
    CFAbsoluteTime  lastContentChange;
    CFAbsoluteTime  lastCellUpdate;
}

@property(strong, nonatomic) NSMutableDictionary *cellHeightsDictionary;

@end

@implementation SCTimelineController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maxPreviewHeight = floor([[UIScreen mainScreen] bounds].size.height * 0.6);
    self.cellHeightsDictionary = [NSMutableDictionary dictionary];

    initialRefresh = NO;
    didLoad = NO;
    scrollToBottom = NO;
    scrollToTop = NO;
    lastContentChange = 0;
    
    self.tableView.estimatedRowHeight = 280;
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
    
    if (!assetCache) {
        assetCache = [[NSCache alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellUpdate:) name:@"SCTimelineCellUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:@"C2CallHandler:LoginSuccess" object:nil];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([SCDataManager instance].isDataInitialized) {
        [[SCTimeline instance] refreshTimeline];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateFetchRequest
{
    [super updateFetchRequest];
    
    if (!initialRefresh && [SCDataManager instance].isDataInitialized) {
        initialRefresh = YES;
        NSLog(@"Refresh Timeline!");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SCTimeline instance] refreshTimeline];
            NSLog(@"Refresh Timeline - Done!");
        });
        
    }
    
}


-(void) loginSuccess:(NSNotification *) notification
{
    __weak SCTimelineController *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.tableView reloadData];
    });
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


-(void) updateCellIfNeeded:(UITableViewCell *) cell
{
    
    if ([[self.tableView visibleCells] containsObject:cell]) {
        [UIView animateWithDuration:0.3 animations:^{
            [cell.contentView layoutIfNeeded];
        }];
        
        lastCellUpdate = CFAbsoluteTimeGetCurrent();
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (CFAbsoluteTimeGetCurrent() - lastCellUpdate >= 0.25) {
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }
        });
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
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityFriendJoined]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityVideoWatched]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityContentShared]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityLike]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityFriendsInvited]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityBroadcastAttended]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityUserStatusChanged]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityContentInfoRequest]]) {
        return @"SCTimelineEventCell";
    }
    
    if ([event.eventType isEqualToString:[SCTimeline eventTypeForType:SCTimeLineEvent_ActivityProfilePictureChanged]]) {
        return @"SCTimelineEventCell";
    }
    
    return self.cellIdentifier;
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SCTimelineBaseCell class]]) {
        SCTimelineBaseCell *bcell = (SCTimelineBaseCell *)cell;
        [bcell configureCell:event controller:self];
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
    
    // Additional Setup for location cell
    if ([cell isKindOfClass:[SCTimelineBroadcastCell class]]) {
        NSString *bcast = event.mediaUrl;
        NSString *bcastId = [bcast substringFromIndex:@"bcast://".length];
        
        C2BlockAction *action = [C2BlockAction actionWithAction:^(id sender) {
            SCBroadcast *broadcast = [[SCBroadcast alloc] initWithBroadcastGroupid:bcastId retrieveFromServer:NO];
            if (broadcast.isLive) {
                [weakself performSegueWithIdentifier:@"SCBroadcastChatControllerSegue" sender:broadcast];
            } else {
                [weakself performSegueWithIdentifier:@"SCBroadcastPlaybackControllerSegue" sender:broadcast];
            }
        }];
        
        SCTimelineBroadcastCell *bcell = (SCTimelineBroadcastCell *)cell;
        [bcell addTapAction:action];
    }
    
}

/*
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
*/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return NO;
    }
    
    @try {
        MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([event.contact isEqualToString:[SCUserProfile currentUser].userid]) {
            return YES;
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Commit Editing for : %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    @try {
        MOTimelineEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[SCTimeline instance] deleteTimelineEvent:event.eventId];
    }
    @catch (NSException *exception) {
        DLog(@"Exception : %@", exception);
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
    
    DLog(@"controllerDidChangeContent: %ld", [[self.fetchedResultsController fetchedObjects] count]);
    if (scrollToTop) {
        scrollToTop = NO;
        [self scrollToTop];
    }
    //[self.tableView reloadData];
}

-(void) openProfile:(NSString *) userid
{
    [self showFriendDetailForUserid:userid];
}

-(void) showMenuExtraForItem:(NSString *) eventId withCampaign:(NSString *) campaignId withText:(NSString *) text andMediaKey:(NSString *) mediaKey featured:(BOOL)featured
{
    
}

-(void) sharePostWithText:(NSString *) textToShare andMediaKey:(NSString *) mediaKey
{
    SCRichMediaType mediaType = [[C2CallPhone currentPhone] mediaTypeForKey:mediaKey];
    
    if (mediaType == SCMEDIATYPE_TEXT && [textToShare length] == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *mediaUrl = nil;
        
        switch (mediaType) {
            case SCMEDIATYPE_IMAGE:
            case SCMEDIATYPE_USERIMAGE:
            case SCMEDIATYPE_VIDEO:
            case SCMEDIATYPE_VOICEMAIL:
            case SCMEDIATYPE_FILE:
            {
                mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:mediaKey];
            }
                break;
            case SCMEDIATYPE_BROADCAST:
            {
                NSString *bcastId = [mediaKey substringFromIndex:@"bcast://".length];
                mediaUrl = [[C2CallPhone currentPhone] mediaUrlForKey:[NSString stringWithFormat:@"video://bcast-%@.webm", bcastId]];
            }
                break;
            case SCMEDIATYPE_LOCATION:{
                FCLocation *loc = [[FCLocation alloc] initWithKey:mediaKey];
                mediaUrl = [loc storeLocationAsVCard];
            }
                break;
            default:
                break;
        }
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:2];
        if ([textToShare length] > 0) {
            [items addObject:textToShare];
        }
        
        
        if (mediaUrl) {
            [items addObject:mediaUrl];
        }
        
        if ([items count] == 0) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
            //activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList]; //Exclude whichever aren't relevant
            [self presentViewController:activityVC animated:YES completion:nil];
        });
        
    });
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self customPrepareForSegue:segue sender:sender];
    
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastPlaybackController class]] && [sender isKindOfClass:[SCBroadcast class]]) {
        SCBroadcastPlaybackController *bcc = (SCBroadcastPlaybackController *) segue.destinationViewController;
        
        SCBroadcast *broadcast = (SCBroadcast *) sender;
        bcc.broadcast = broadcast;
    }
    
    if ([segue.destinationViewController isKindOfClass:[SCBroadcastChatController class]] && [sender isKindOfClass:[SCBroadcast class]]) {
        SCBroadcastChatController *bchat = (SCBroadcastChatController *) segue.destinationViewController;
        SCBroadcast *broadcast = (SCBroadcast *) sender;
        
        NSString *bid = broadcast.groupid;
        bchat.broadcastGroupId = bid;
    }
    
}


@end

