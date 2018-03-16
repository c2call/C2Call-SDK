//
//  OGURL.h
//  AWSCore
//
//  Created by Manish Kungwani on 09/02/18.
//

#import <Foundation/Foundation.h>

/*
@protocol OGURLDelegate <NSObject>

- (void)OGURLDidFinishParsingWithMetaData:(NSDictionary*)metadata error:(NSString*)errorMessage;

@end
*/

@interface OGURL : NSURL

//@property (nonatomic, weak) id <OGURLDelegate> delegate;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableArray *openGraphMetaData;

-(instancetype)initWithString:(NSString *)URLString;
//-(void)getPreviewMetadata;

-(void)metadataForPreviewCompletion:(void (^)(NSDictionary* data))completion;

@end


