//
//  SCLinkPreviewContentView.m
//  AWSCore
//
//  Created by Manish Kungwani on 14/02/18.
//

#import "SCLinkPreviewContentView.h"
#import "SocialCommunication.h"


@implementation SCLinkPreviewContentView

-(void) removeFromSuperview
{
    [super removeFromSuperview];
}

-(void) willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

-(void)prepareLinkPreviewWithData:(NSDictionary*)metadata
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    _linkTitleLbl.text = [metadata valueForKey:@"title"];
    
    _linkDescriptionLbl.text = [metadata valueForKey:@"description"];
    
    _linkSiteNameLbl.text = [metadata valueForKey:@"site_name"];
    
    NSURL *imageURL = [NSURL URLWithString:[metadata valueForKey:@"image"]];
    
    __weak SCLinkPreviewContentView *weakself = self;
    
    [self downloadImageWithURL:imageURL cache:NSURLRequestReturnCacheDataElseLoad completionBlock:^(BOOL succeeded, UIImage *image)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if(image)
             {
                 weakself.linkIconWidth.constant = 50.0;
                 weakself.linkIconView.image = image;
             }
             else
             {
                 weakself.linkIconWidth.constant = 0.0;
                 weakself.linkIconView.image = nil;
             }
         });
     }];
    
    /*
    NSString *mediaKey = nil;
    NSArray *tempArr = [[imageURL absoluteString] componentsSeparatedByString:@"://"];
    
    if([tempArr lastObject])
    {
        mediaKey = [@"image://" stringByAppendingString:[tempArr lastObject]];
        [[C2CallPhone currentPhone] retrieveObjectForKey:mediaKey completion:^(BOOL finished)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([[C2CallPhone currentPhone] hasObjectForKey:mediaKey])
                 {
                     UIImage *image = [[C2CallPhone currentPhone] imageForKey:[imageURL absoluteString]];
                     if(image)
                     {
                         weakself.linkIconWidth.constant = 50.0;
                         weakself.linkIconView.image = image;
                     }
                     else
                     {
                         weakself.linkIconWidth.constant = 0.0;
                         weakself.linkIconView.image = nil;
                     }
                 }
                 else
                 {
                     weakself.linkIconWidth.constant = 0.0;
                     weakself.linkIconView.image = nil;
                 }
             });
         }];
    }
    */
    
    
}

-(void)downloadImageWithURL:(NSURL *)url cache:(NSURLRequestCachePolicy)cachePlicy completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePlicy timeoutInterval:60.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error )
        {
            completionBlock(YES,[[UIImage alloc] initWithData:data]);
        }
        else
        {
            NSLog(@"Error while downloaading Image : %@",error);
            completionBlock(NO,nil);
        }
        
    }] resume];
}

@end
