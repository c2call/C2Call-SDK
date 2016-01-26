//
//  ImageUtil.h
//  C2CallPhone
//
//  Created by Michael Knecht on 2/29/12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FCLocation, AVAsset;

@interface ImageUtil : NSObject

+(UIImage *) thumbnailFromImage:(UIImage *) image;
+(UIImage *) thumbnailFromImage:(UIImage *) image withSize:(CGFloat) sz;
+(UIImage *) thumbnailFromImage:(UIImage *) image withSize:(CGFloat) sz andCornerRadius:(CGFloat) radius;
+(UIImage *) smallImageFromImage:(UIImage *) image;
+(UIImage *) thumbnailFromVideo:(NSURL*) videoUrl;
+(UIImage *) thumbnailFromAsset:(AVAsset *) mediaAsset;
+(UIImage*) thumbnailFromLocation:(FCLocation *) loc;
+(UIImage*) imageFromLocation:(FCLocation *) loc;
+(UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect;
+(UIImage*) fixImage:(UIImage*)img withQuality:(UIImagePickerControllerQualityType) quality;
+(UIImage*) imageFromRGBAData:(NSData*) rgba withSize:(CGSize) sz;
+(UIImage*) imageFromRGBAData:(NSData*) rgba withSize:(CGSize) sz orientation:(UIInterfaceOrientation) orientation;
+(UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees;

@end
