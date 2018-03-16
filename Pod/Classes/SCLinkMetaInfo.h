//
//  SCLinkMetaInfo.h
//  C2Call-SDK
//
//  Created by Manish Kungwani on 23/02/18.
//

#import <Foundation/Foundation.h>

@interface SCLinkMetaInfo : NSObject

+ (instancetype)sharedInstance;

- (NSCache*)cache;

- (void)metadataForURL:(NSURL*)url completion:(void (^)(NSDictionary* data, NSString* errorMessage))handleCompletion;

@end
