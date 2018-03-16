//
//  OGURL.m
//  AWSCore
//
//  Created by Manish Kungwani on 09/02/18.
//

#import "OGURL.h"

@implementation OGURL

//@synthesize delegate;

-(instancetype)initWithString:(NSString *)URLString
{
    self = [super initWithString:URLString];
    if(!self)
    {
        return nil;
    }
    return self;
}

/*
-(void)getPreviewMetadata
{
    _openGraphMetaData = nil;
    _openGraphMetaData = [[NSMutableArray alloc] init];
   
    [self performSelectorInBackground:@selector(getHTML) withObject:nil];
}


-(void)getHTML
{
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *htmlString = [[NSString alloc] initWithContentsOfURL:self
                                                      usedEncoding:&encoding
                                                             error:&error];
    
    if(error && error.code == 264)
    {
        NSData * urlData = [NSData dataWithContentsOfURL:self];
        
        htmlString = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
        
        if (!htmlString) {
            htmlString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        }
        if (!htmlString) {
            htmlString = [[NSString alloc] initWithData:urlData encoding:NSWindowsCP1252StringEncoding];
        }
    }
    
    if(htmlString)
    {
        NSLog(@"%@ :: Scanning HTML for Open Graph metadata ...", self);
        [self scan:htmlString];
        
        NSString *toSearch = @"og:title";
        
        NSArray *filtered = [_openGraphMetaData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",toSearch]];
        
        if([filtered count] == 0)
        {
            NSString *title =  [self grabTitleFrom:htmlString];
            
            if(title)
            {
                [_openGraphMetaData addObject:[NSString stringWithFormat:@"property=\"og:title\" content=\"%@\"",title]];
            }
        }
        
        NSLog(@"%@ :: Parsing Meta Data ...",self);
        NSDictionary *parsedData = [self parse:_openGraphMetaData];
        
        if([parsedData count] > 0)
        {
            NSMutableDictionary *parsedDict = [[NSMutableDictionary alloc] initWithDictionary:parsedData];
            
            if(![parsedData valueForKey:@"site_name"])
            {
                NSString *link;
                if([parsedData valueForKey:@"url"])
                {
                    link = [self baseLink:[parsedData valueForKey:@"url"]];
                }
                else
                {
                    link = [self baseLink:[self absoluteString]];
                }
                
                [parsedDict setObject:link forKey:@"site_name"];
            }
            
            if([parsedData valueForKey:@"title"])
            {
                NSString *decodedTitle = [self decodeHtmlStringValue:[parsedData valueForKey:@"title"]];
                [parsedDict setObject:decodedTitle forKey:@"title"];
            }
            
            if([parsedData valueForKey:@"description"])
            {
                NSString *decodedDesc = [self decodeHtmlStringValue:[parsedData valueForKey:@"description"]];
                [parsedDict setObject:decodedDesc forKey:@"description"];
            }
            
            [parsedDict setObject:[self absoluteString] forKey:@"link"];
            
            [[NSCache sharedCache] setObject:parsedDict forKey:[self absoluteString]];
            
            [self fireDelegate:parsedDict andError:nil];
        }
        else
        {
            [self fireDelegate:nil andError:@"OGURL :: Metadata not found"];
        }
    }
    else
    {
        [self fireDelegate:nil andError:[NSString stringWithFormat:@"%@ :: Error %ld - %@ ...", self, (long)error.code, [error localizedDescription]]];
    }
}
 
 -(void)fireDelegate:(NSDictionary*)dictionary andError:(NSString*)error
 {
     if([[self delegate] respondsToSelector:@selector(OGURLDidFinishParsingWithMetaData:error:)])
     {
         dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] OGURLDidFinishParsingWithMetaData:dictionary error:error];
         });
     }
     else
     {
        NSLog(@"%@ :: Please implement delegate method OGURLDidFinishParsingWithMetaData to get data",[self classForCoder]);
     }
 }
*/


-(void)metadataForPreviewCompletion:(void (^)(NSDictionary* data))completion;
{
    _openGraphMetaData = [[NSMutableArray alloc] init];
    
    if(_task != nil)
    {
        NSLog(@"Cancelling task ...");
        [_task cancel];
    }
    
    _task = [[NSURLSession sharedSession] dataTaskWithURL:self completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
             {
                 @try
                 {
                     NSString *htmlString;
                     
                     [NSString stringEncodingForData:data encodingOptions:nil convertedString:&htmlString usedLossyConversion:nil];
                     
                     if (!htmlString) {
                         htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     }
                     if (!htmlString) {
                         htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                     }
                     if (!htmlString) {
                         htmlString = [[NSString alloc] initWithData:data encoding:NSWindowsCP1252StringEncoding];
                     }
                     
                     htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<meta  " withString:@"<meta "];
                     [self scan:htmlString];
                     
                     NSString *toSearch = @"og:title";
                     NSArray *filtered = [self.openGraphMetaData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",toSearch]];
                     
                     if([filtered count] == 0)
                     {
                         NSString *title =  [self grabTitleFrom:htmlString];
                         
                         if(title)
                         {
                             [self.openGraphMetaData addObject:[NSString stringWithFormat:@"property=\"og:title\" content=\"%@\"",title]];
                         }
                     }
                     
                     NSString *toSearch2 = @"og:image";
                     NSArray *filtered2 = [self.openGraphMetaData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",toSearch2]];
                     if([filtered2 count] == 0)
                     {
                         NSString *imageStr =  [self grabImageFrom:htmlString];
                         if(imageStr)
                         {
                             [self.openGraphMetaData addObject:[NSString stringWithFormat:@"property=\"og:image\" content=\"%@\"",imageStr]];
                         }
                     }
                     
                     //Parsing
                     NSLog(@"%@ :: Parsing Meta Data ...",self);
                     NSDictionary *parsedData = [self parse:self.openGraphMetaData];
                     
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
                                 NSString *link = [self baseLink:[self absoluteString]];
                                 [parsedDict setObject:link forKey:@"site_name"];
                             }
                         }
                         
                         
                         
                         
                         if([parsedData valueForKey:@"title"])
                         {
                             NSString *decodedTitle = [self decodeHtmlStringValue:[parsedData valueForKey:@"title"]];
                             [parsedDict setObject:decodedTitle forKey:@"title"];
                         }
                         
                         if([parsedData valueForKey:@"description"])
                         {
                             NSString *decodedStr = [self decodeHtmlStringValue:[parsedData valueForKey:@"description"]];
                             [parsedDict setObject:decodedStr forKey:@"description"];
                         }
                         /*
                         if(![parsedData valueForKey:@"image"])
                         {
                             NSString *link = [parsedDict valueForKey:@"site_name"];
                             NSString *statvooImg = [NSString stringWithFormat:@"http://api.statvoo.com/favicon/?url=%@",link];
                             [parsedDict setObject:statvooImg forKey:@"image"];
                         }
                          */
                         
                         [parsedDict setObject:[self absoluteString] forKey:@"link"];
                         
                         //[[NSCache sharedCache] setObject:parsedDict forKey:[self absoluteString]];
                         completion(parsedData);
                     }
                     else
                     {
                         completion(nil);
                     }
                 }
                 @catch(NSException *e)
                 {
                     NSLog(@"Exception :: %@",e);
                 }
             }];
    
    [_task resume];
}

-(void)scan:(NSString*)htmlString
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
            [_openGraphMetaData addObject:tagData];
        }
        else if([tagData containsString:@"description"])
        {
            [_openGraphMetaData addObject:tagData];
        }
        
        NSString *metaString = [[@"<meta " stringByAppendingString:tagData] stringByAppendingString:@">"];
        
        if([htmlString containsString:metaString])
        {
            NSString *newString = [htmlString stringByReplacingOccurrencesOfString:metaString withString:@""];
            newString = [newString stringByReplacingOccurrencesOfString:@"<meta  " withString:@"<meta "];
            [self scan:newString];
        }
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

- (NSString *)decodeHtmlStringValue:(NSString*)htmlStr
{
    NSData *encodedString = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
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
    NSString *character = [string substringFromIndex:[string length] - 1];
    if([character isEqualToString:@"\""] || [character isEqualToString:@"'"])
    {
        return [string substringToIndex:[string length] - 1];
    }
    
    return string;
}

@end
