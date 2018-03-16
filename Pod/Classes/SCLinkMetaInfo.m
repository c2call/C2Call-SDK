//
//  SCLinkMetaInfo.m
//  C2Call-SDK
//
//  Created by Manish Kungwani on 23/02/18.
//

#import "SCLinkMetaInfo.h"

@implementation SCLinkMetaInfo
{
    NSMutableArray *urlsInProgress;
}

+ (instancetype)sharedInstance
{
    static SCLinkMetaInfo *_sharedObject = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _sharedObject = [SCLinkMetaInfo new];
    });
    
    return _sharedObject;
}

-(NSCache *)cache
{
    static NSCache *_cacheObject = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _cacheObject = [NSCache new];
    });
    
    return _cacheObject;
}

- (void)metadataForURL:(NSURL*)url completion:(void (^)(NSDictionary* data, NSString* errorMessage))handleCompletion
{
    NSDictionary *cachedData = [[[SCLinkMetaInfo sharedInstance] cache] objectForKey:[url absoluteString]];
    
    if(cachedData)
    {
        handleCompletion(cachedData,nil);
    }
    else
    {
        if(!urlsInProgress) { urlsInProgress = [[NSMutableArray alloc] init]; }
        
        if(![urlsInProgress containsObject:url])
        {
            [urlsInProgress addObject:url];
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
             {
                 if(error)
                 {
                     [urlsInProgress removeObject:url];
                     handleCompletion(nil,[NSString stringWithFormat:@"ERROR - %@ for : %@",error.localizedDescription, url]);
                 }
                 else
                 {
                     @try
                     {
                         NSString *htmlString;
                         NSStringEncoding encoding = [NSString stringEncodingForData:data encodingOptions:nil convertedString:&htmlString usedLossyConversion:nil];
                         
                         if (!htmlString) {
                             htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                             encoding = NSUTF8StringEncoding;
                         }
                         if (!htmlString) {
                             htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                             encoding = NSASCIIStringEncoding;
                         }
                         if (!htmlString) {
                             htmlString = [[NSString alloc] initWithData:data encoding:NSWindowsCP1252StringEncoding];
                             encoding = NSWindowsCP1252StringEncoding;
                         }
                         
                         if(!htmlString)
                         {
                             [urlsInProgress removeObject:url];
                             handleCompletion(nil,[NSString stringWithFormat:@"SOURCE CODE not found for : %@",url]);
                         }
                         else
                         {
                             htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<meta  " withString:@"<meta "];
                             
                             
                             //1.
                             NSLog(@"SCLinkMetaInfo : Scanning ...");
                             NSMutableArray *metaData = [NSMutableArray arrayWithArray:[self scanForMetaData:htmlString inArray:[NSMutableArray new]]];
                             
                             if([metaData count] == 0)
                             {
                                 [urlsInProgress removeObject:url];
                                 handleCompletion(nil,[NSString stringWithFormat:@"METADATA not found for : %@",url]);
                             }
                             else
                             {
                                 NSString *toSearch = @"og:title";
                                 NSArray *filtered = [metaData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",toSearch]];
                                 
                                 if([filtered count] == 0)
                                 {
                                     NSString *title =  [self grabTitleFrom:htmlString];
                                     
                                     if(title)
                                     {
                                         [metaData addObject:[NSString stringWithFormat:@"property=\"og:title\" content=\"%@\"",title]];
                                     }
                                 }
                                 
                                 NSString *toSearch2 = @"og:image";
                                 NSArray *filtered2 = [metaData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",toSearch2]];
                                 if([filtered2 count] == 0)
                                 {
                                     NSString *imageStr =  [self grabImageFrom:htmlString];
                                     if(imageStr)
                                     {
                                         [metaData addObject:[NSString stringWithFormat:@"property=\"og:image\" content=\"%@\"",imageStr]];
                                     }
                                 }
                                 
                                 //2.
                                 NSLog(@"SCLinkMetaInfo : Parsing ...");
                                 NSDictionary *parsedData = [self parse:metaData];
                                 
                                 if([parsedData count] > 0)
                                 {
                                     NSMutableDictionary *parsedDict = [[NSMutableDictionary alloc] initWithDictionary:parsedData];
                                     
                                     if(![parsedData valueForKey:@"site_name"])
                                     {
                                         if([parsedData valueForKey:@"url"])
                                         {
                                             [parsedDict setObject:[parsedData valueForKey:@"url"] forKey:@"site_name"];
                                         }
                                         else
                                         {
                                             NSString *link = [self baseLink:[url absoluteString]];
                                             [parsedDict setObject:link forKey:@"site_name"];
                                         }
                                     }
                                     
                                     if([parsedData valueForKey:@"title"])
                                     {
                                         NSString *decodedTitle = [self decodeHtmlStringValue:[parsedData valueForKey:@"title"] encoding:encoding];
                                         [parsedDict setObject:decodedTitle forKey:@"title"];
                                     }
                                     
                                     if([parsedData valueForKey:@"description"])
                                     {
                                         NSString *decodedStr = [self decodeHtmlStringValue:[parsedData valueForKey:@"description"] encoding:encoding];
                                         [parsedDict setObject:decodedStr forKey:@"description"];
                                     }
                                     
                                     [parsedDict setObject:[url absoluteString] forKey:@"link"];
                                     
                                     [[[SCLinkMetaInfo sharedInstance] cache] setObject:parsedDict forKey:[url absoluteString]];
                                     [urlsInProgress removeObject:url];
                                     handleCompletion(parsedDict, nil);
                                 }
                                 else
                                 {
                                     [urlsInProgress removeObject:url];
                                     handleCompletion(nil,[NSString stringWithFormat:@"PREVIEW DATA not found for : %@",url]);
                                 }
                             }
                         }
                     }
                     @catch(NSException *e)
                     {
                         [urlsInProgress removeObject:url];
                         handleCompletion(nil,[NSString stringWithFormat:@"EXCEPTION - %@ for : %@",e.description, url]);
                     }
                 }
             }] resume];
        }
    }
}

-(NSArray*)scanForMetaData:(NSString*)htmlString inArray:(NSMutableArray*)array
{
    if([htmlString containsString:@"<meta "])
    {
        NSScanner *scanner = [NSScanner scannerWithString:htmlString];
        NSString __autoreleasing *tagData;
        [scanner scanUpToString:@"<meta " intoString:NULL];
        [scanner scanString:@"<meta " intoString:NULL];
        [scanner scanUpToString:@">" intoString:&tagData];
        
        if([tagData containsString:@"og:"])
        {
            [array addObject:tagData];
        }
        else if([tagData containsString:@"description"])
        {
            [array addObject:tagData];
        }
        
        NSString *metaString = [[@"<meta " stringByAppendingString:tagData] stringByAppendingString:@">"];
        
        if([htmlString containsString:metaString])
        {
            NSString *newString = [htmlString stringByReplacingOccurrencesOfString:metaString withString:@""];
            newString = [newString stringByReplacingOccurrencesOfString:@"<meta  " withString:@"<meta "];
            return [self scanForMetaData:newString inArray:array];
        }
        else
        {
            return array;
        }
    }
    else
    {
        return array;
    }
}


-(NSDictionary*)parse:(NSArray*)openGraph
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for(NSString *metaStr in openGraph)
    {
        NSString *metaString = [metaStr stringByReplacingOccurrencesOfString:@"\" " withString:@"\"#####"];
        
        NSArray *tempArr = [metaString componentsSeparatedByString:@"#####"];
        if([tempArr count] >= 2)
        {
            NSString *key, *value;
            
            for(NSString *str in tempArr)
            {
                if([str containsString:@"property"])
                {
                    NSString * tempStr = [str stringByReplacingOccurrencesOfString:@"property=" withString:@""];
                    tempStr = [tempStr substringFromIndex:1];
                    tempStr = [tempStr substringToIndex:[tempStr length] - 1];
                    key = [tempStr stringByReplacingOccurrencesOfString:@"og:" withString:@""];
                }
                else if([str containsString:@"name"])
                {
                    NSString * tempStr = [str stringByReplacingOccurrencesOfString:@"name=" withString:@""];
                    tempStr = [tempStr substringFromIndex:1];
                    tempStr = [tempStr substringToIndex:[tempStr length] - 1];
                    key = tempStr;
                }
                else if([str containsString:@"content"])
                {
                    NSString *tempStr = [str stringByReplacingOccurrencesOfString:@"content=" withString:@""];
                    tempStr = [tempStr substringFromIndex:1];
                    tempStr = [tempStr substringToIndex:[tempStr length] - 1];
                    value = tempStr;
                }
            }
            
            if(key != nil && value != nil)
            {
                NSString *val = [value precomposedStringWithCompatibilityMapping];
                val = [self trimQuoteMarkFrom:val];
                [dict setValue:val forKey:key];
            }
        }
    }
    
    return dict;
}

-(NSString*)grabTitleFrom:(NSString*)htmlString
{
    NSString *title;
    if([htmlString containsString:@"<title"])
    {
        NSScanner *scanner = [NSScanner scannerWithString:htmlString];
        [scanner scanUpToString:@"<title" intoString:NULL];
        [scanner scanString:@"<title" intoString:NULL];
        [scanner scanUpToString:@"</title>" intoString:&title];
    }
    
    NSString *mainTitle = [title substringFromIndex:[title rangeOfString:@">"].location + 1];
    
    return mainTitle;
}

-(NSString*)grabImageFrom:(NSString*)htmlString
{
    NSString *searchStr = nil;
    if([htmlString containsString:@"<link rel=\"icon\""])
    {
        searchStr = @"<link rel=\"icon\"";
    }
    else if([htmlString containsString:@"<link rel='icon'"])
    {
        searchStr = @"<link rel='icon'";
    }
    else if([htmlString containsString:@"<link rel=\"shortcut icon\""])
    {
        searchStr = @"<link rel=\"shortcut icon\"";
    }
    else if([htmlString containsString:@"<link rel='shortcut icon'"])
    {
        searchStr = @"<link rel='shortcut icon'";
    }
    else if([htmlString containsString:@"<link rel=\"apple-touch-icon\""])
    {
        searchStr = @"<link rel=\"apple-touch-icon\"";
    }
    else if([htmlString containsString:@"<link rel='apple-touch-icon'"])
    {
        searchStr = @"<link rel='apple-touch-icon";
    }
    
    if(searchStr)
    {
        NSString *imageStr = nil;
        NSScanner *scanner = [NSScanner scannerWithString:htmlString];
        [scanner scanUpToString:searchStr intoString:NULL];
        [scanner scanString:searchStr intoString:NULL];
        [scanner scanUpToString:@">" intoString:&imageStr];
        scanner = nil;
        if(imageStr)
        {
            NSString *hrefStr = nil;
            NSString *endChar = nil;
            if([imageStr containsString:@"href=\""])
            {
                hrefStr = @"href=\"";
                endChar = @"\"";
            }
            else if([imageStr containsString:@"href='"])
            {
                hrefStr = @"href='";
                endChar = @"'";
            }
            
            if(hrefStr)
            {
                NSString *imageURL = nil;
                scanner = [NSScanner scannerWithString:imageStr];
                [scanner scanUpToString:hrefStr intoString:NULL];
                [scanner scanString:hrefStr intoString:NULL];
                [scanner scanUpToString:endChar intoString:&imageURL];
                return imageURL;
            }
        }
    }
    
    return nil;
}

- (NSString *)decodeHtmlStringValue:(NSString*)htmlStr encoding:(NSStringEncoding)encoding
{
    NSData *encodedString = [htmlStr dataUsingEncoding:encoding];
    NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:encodedString
                                                                      options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    return [htmlString string];
}

- (NSString *)baseLink:(NSString*)link
{
    if (link == nil)
    {
        return nil;
    }
    
    if(![link containsString:@"://"])
    {
        return link;
    }
    NSString *baseLink;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:link];
    [scanner scanUpToString:@"://" intoString:NULL];
    [scanner scanString:@"://" intoString:NULL];
    [scanner scanUpToString:@"/" intoString:&baseLink];
    
    return baseLink;
}

-(NSString *)trimQuoteMarkFrom:(NSString*)string
{
    if([string length] > 0)
    {
        NSString *character = [string substringFromIndex:[string length] - 1];
        if([character isEqualToString:@"\""] || [character isEqualToString:@"'"])
        {
            return [string substringToIndex:[string length] - 1];
        }
    }

    return string;
}


@end
