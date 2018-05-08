//
//  SCMediaLoader.h
//  C2CallPhone
//
//  Created by Michael Knecht on 16.03.18.
//

#import <Foundation/Foundation.h>

@class AVURLAsset;

@interface SCMediaLoader : NSObject

-(BOOL) uploadImage:(nonnull UIImage *) originalImage withPrefix:(nullable NSString *) prefix andQuality:(UIImagePickerControllerQualityType) imageQuality completion:(nullable void (^)(NSString * _Nullable key, NSDictionary * _Nullable mediaInfo)) completion;
    
-(BOOL) uploadVideo:(nonnull NSURL *) videoUrl withPrefix:(nullable NSString *) prefix  teaserImage:(UIImage *_Nullable) teaserImage completion:(nullable void (^)(NSString * _Nullable key, NSDictionary * _Nullable mediaInfo, NSError *_Nullable)) completion;

-(CGSize) videoSizeForAsset:(AVURLAsset *_Nonnull) asset;
-(CGSize) mediaSizeForMediaKey:(NSString *_Nonnull) mediaKey;

+(instancetype _Nonnull ) instance;

@end
