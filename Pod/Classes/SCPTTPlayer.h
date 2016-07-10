//
//  PTTPlayer.h
//  MarsApp
//
//  Created by Michael Knecht on 27/04/16.
//  Copyright © 2016 Mars General Services Pld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SCPTTPlayer : NSObject

@property(nonatomic, strong) NSString *mediaKey;
@property(nonatomic, strong) UIProgressView *progress;
@property(nonatomic, strong) UIImageView *playButton;

- (instancetype)initWithMediaKey:(NSString *) mediaKey;


-(BOOL) isPlaying;

-(BOOL) play;
-(void) pause;
-(void) stop;

@end
