//
//  SCBroadcastPlaybackController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 24/07/16.
//
//

#import "SCBroadcastPlaybackController.h"
#import "SCVLCVideoPlayerView.h"
#import "SCBroadcast.h"
#import "C2CallPhone.h"
#import "SCDataManager.h"
#import "SCActivity.h"

@interface SCBroadcastPlaybackController ()<SCVLCVideoPlayerViewDelegate> {
}

@property(nonatomic) BOOL isPlaying;
@property(nonatomic) BOOL started;

@end

@implementation SCBroadcastPlaybackController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.videoView.delegate = self;
    self.isPlaying = NO;
    self.started = NO;
    
    [self configureView];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoView pause:nil];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        if (self.started) {
            self.started = NO;
            [SCActivity reportBroadcastVideoEnd:self.broadcast.groupid];
        }
    }
}


-(void) playerDidStart;
{
    if (!self.started) {
        self.started = YES;
        [SCActivity reportBroadcastVideoStart:self.broadcast.groupid];
    }
    self.isPlaying = YES;
}

-(void) playerDidStop;
{
    self.isPlaying = NO;
}

-(void) playerDidReachEnd
{
    self.isPlaying = NO;
    self.started = NO;

    [SCActivity reportBroadcastVideoEnd:self.broadcast.groupid];
}

-(void) playerProgress:(NSUInteger)progress
{
    //if (progress % 5 == 0) {
        [SCActivity reportBroadcastVideo:self.broadcast.groupid progress:progress];
    //}
}

-(void) configureView
{
    //self.broadcastName.text = bcast.groupName;
    self.playButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.playButton.layer.borderWidth = 2.0;
    
    NSString *bcastid = self.broadcast.groupid;
    
    NSString *owner = [self.broadcast.groupOwner copy];
    //NSString *locationName = self.broadcast.locationName? [self.broadcast.locationName copy]: @"";
    
    
    if (self.broadcast.startDate || self.broadcast.endDate) {
        NSDateFormatter *dateTime = [[NSDateFormatter alloc] init];
        [dateTime setDateStyle:NSDateFormatterShortStyle];
        [dateTime setTimeStyle:NSDateFormatterShortStyle];
        
        if (self.broadcast.endDate) {
            self.timeInfo.text = [NSString stringWithFormat:@"Ended at %@", [dateTime stringFromDate:self.broadcast.endDate]];
        } else {
            self.timeInfo.text = [NSString stringWithFormat:@"Started at %@", [dateTime stringFromDate:self.broadcast.startDate]];
        }
    }
    
    NSString *bcastVideoKey = self.broadcast.mediaUrl;
    if (!bcastVideoKey || ![[C2CallPhone currentPhone] hasObjectForKey:bcastVideoKey]) {
        bcastVideoKey = [NSString stringWithFormat:@"video://bcast-%@.webm", bcastid];
    }
    
    [self.videoView setMediaKey:bcastVideoKey];
    
    UIImage *bcastImage = [[C2CallPhone currentPhone] userimageForUserid:bcastid];
    if (bcastImage) {
        self.videoView.layer.contents = (id)[bcastImage CGImage];
        self.videoView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:owner];
    if (image) {
        self.userImage.image = image;
    }
    
    __weak SCBroadcastPlaybackController *weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *userInfo =[[C2CallPhone currentPhone] getUserInfoForUserid:owner];
        NSString *imagekey = userInfo[@"ImageLarge"];
        NSString *bcastImageKey = [[C2CallPhone currentPhone] userimageKeyForUserid:bcastid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MOC2CallUser *c2user = [[SCDataManager instance] userForUserid:owner];
            if ([bcastid isEqualToString:bcastid]) {
                
                NSString *displayName = @"";
                NSString *firstname = userInfo[@"Firstname"];
                NSString *name = userInfo[@"Lastname"];
                
                if ([c2user.displayName length] > 0) {
                    displayName = c2user.displayName;
                } else if ([firstname length] > 0 &&  [name length] > 0) {
                    displayName = [NSString stringWithFormat:@"%@ %@", firstname, name];
                } else if ([firstname length] > 0) {
                    displayName = firstname;
                } else if ([name length] > 0) {
                    displayName = name;
                }
                self.userName.text = displayName;
            }
        });
        
        if (!bcastImage && bcastImageKey) {
            
            if ([[C2CallPhone currentPhone] hasObjectForKey:bcastImageKey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *img = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
                    if (img) {
                        weakself.videoView.layer.contents = (id)[img CGImage];
                        weakself.videoView.contentMode = UIViewContentModeScaleAspectFill;
                    }
                });
            } if ([[C2CallPhone currentPhone] downloadStatusForKey:bcastImageKey]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:bcastImageKey object:nil];
            }  else {
                [[C2CallPhone currentPhone] retrieveObjectForKey:bcastImageKey completion:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *img = [[C2CallPhone currentPhone] imageForKey:bcastImageKey];
                        if (img) {
                            weakself.videoView.layer.contents = (id)[img CGImage];
                            weakself.videoView.contentMode = UIViewContentModeScaleAspectFill;
                        }
                    });
                }];
            }
        }
        
        if (!image && imagekey) {
            if ([[C2CallPhone currentPhone] hasObjectForKey:imagekey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.userImage.image = [[C2CallPhone currentPhone] imageForKey:imagekey];
                });
            } if ([[C2CallPhone currentPhone] downloadStatusForKey:imagekey]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:imagekey object:nil];
            } else {
                [[C2CallPhone currentPhone] retrieveObjectForKey:imagekey completion:^(BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakself.userImage.image = [[C2CallPhone currentPhone] imageForKey:imagekey];
                    });
                }];
            }
        }
    });
    
}
@end
