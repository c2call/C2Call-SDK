               //
//  SCEventContentView.m
//  C2CallPhone
//
//  Created by Michael Knecht on 22.11.17.
//

#import "SCEventContentView.h"
#import "FCLocation.h"
#import "C2CallPhone.h"
#import "C2BlockAction.h"
#import "SCAssetManager.h"
#import "NSBundle+SDKBundle.h"
#import "SCLinkMetaInfo.h"


@implementation SCEventContentView

-(void) prepareForReuse
{
    // Just Empty
}

-(BOOL) showTransferProgress;
{
    return NO;
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    // Just Empty
}

-(BOOL) hideTransferProgress;
{
    return NO;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    // Just Empty
}

@end

@interface SCTextEventContentView()<UIGestureRecognizerDelegate>
@property(assign, nonatomic) CGFloat sizeForPureEmojis;
@property(assign, nonatomic) BOOL isPureEmoji;
@end

@implementation SCTextEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.contentText.text = nil;
    _isPureEmoji = NO;
    if(_sizeForPureEmojis == 0.0)
    {
        _sizeForPureEmojis = self.contentText.font.pointSize * 3.0;
    }
    else
    {
        [self.contentText setFont:[UIFont fontWithName:self.contentText.font.fontName size:_sizeForPureEmojis/3.0]];
    }
    
    self.contentText.attributedText = nil;
    dataTapAction = nil;
    dataLongPressAction = nil;
    self.dataDetectors = nil;
    
    if (self.tapDataDetectorGR) {
        [self.contentText removeGestureRecognizer:self.tapDataDetectorGR];
        self.tapDataDetectorGR = nil;
    }
    
    if (self.longPressDataDetectorGR) {
        [self.contentText removeGestureRecognizer:self.longPressDataDetectorGR];
        self.longPressDataDetectorGR = nil;
    }
}

-(void) presentTextContent:(NSString *_Nullable) messageText withTextColor:(UIColor *) textColor andDataDetector:(NSDictionary<NSString*, NSArray *> *_Nullable) dataDetector;
{
    NSString *fontName = self.contentText.font.fontName;
    NSString *appendText = @"XXXXXX";
    
    if([self isPureEmojiString:messageText])
    {
        [self.contentText setFont:[UIFont fontWithName:fontName size:_sizeForPureEmojis]];
        appendText = @"\n";
        _isPureEmoji = YES;
    }
    
    messageText = [NSString stringWithFormat:@"%@%@", messageText, appendText];
    
    if (dataDetector) {
        
        NSMutableAttributedString *atext = [[NSMutableAttributedString alloc] init];
        [atext appendAttributedString:[[NSAttributedString alloc] initWithString:messageText]];

        if (textColor) {
            NSRange fullRange = NSMakeRange(0, [messageText length]);
            [atext addAttribute:NSForegroundColorAttributeName value:textColor range:fullRange];
        }
        
        NSRange appendTextRange = NSMakeRange(messageText.length - appendText.length, appendText.length);
        [atext addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:appendTextRange];
        
        NSArray<NSURL *> *urls = dataDetector[@"url"];
        atext = [self addUrlDataDetectors:urls attributedText:atext messageText:messageText];
        
        NSArray<NSString *> *numbers = dataDetector[@"phone"];
        atext = [self addPhoneDataDetectors:numbers attributedText:atext messageText:messageText];
        
        NSArray<NSDictionary<NSString *, NSObject *> *> *users = dataDetector[@"users"];
        atext = [self addUserDataDetectors:users attributedText:atext messageText:messageText];
        
        /*
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"transparent60x13"];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [atext insertAttributedString:attrStringWithImage atIndex:[messageText length]];
         */
        
        [self applyNonBreakableSpaces:messageText attributedText:atext];
        
        self.contentText.attributedText = atext;
        
        if (self.tapDataDetectorGR) {
            [self.contentText removeGestureRecognizer:self.tapDataDetectorGR];
            self.tapDataDetectorGR = nil;
        }
        
        if (self.longPressDataDetectorGR) {
            [self.contentText removeGestureRecognizer:self.longPressDataDetectorGR];
            self.longPressDataDetectorGR = nil;
        }

        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGR.delegate = self;
        [self.contentText addGestureRecognizer:tapGR];
        self.contentText.userInteractionEnabled = YES;
        self.tapDataDetectorGR = tapGR;
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGR.delegate = self;
        [self.contentText addGestureRecognizer:longPressGR];
        self.contentText.userInteractionEnabled = YES;
        self.longPressDataDetectorGR = longPressGR;
        
    } else {
        NSMutableAttributedString *atext = [[NSMutableAttributedString alloc] initWithString:messageText];
        if (textColor) {
            NSRange fullRange = NSMakeRange(0, [messageText length]);
            [atext addAttribute:NSForegroundColorAttributeName value:textColor range:fullRange];
        }
        
        NSRange appendTextRange = NSMakeRange(messageText.length - appendText.length, appendText.length);
        [atext addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:appendTextRange];
        
        if(_isPureEmoji)
        {
            [atext addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:3.0] range:appendTextRange];
        }
        
        self.contentText.attributedText = atext;

        /*
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"transparent60x13"];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [atext insertAttributedString:attrStringWithImage atIndex:[messageText length]];
        
        self.contentText.attributedText = atext;
         */
    }
}

-(void) applyNonBreakableSpaces:(NSString *) messageText attributedText:(NSMutableAttributedString *) atext
{
    for (NSDictionary<NSString *, NSObject*> *dataDetector in self.dataDetectors) {
        NSString *type = (NSString *)dataDetector[@"type"];
        if ([type isEqualToString:@"user"]) {
            NSValue *rangeValue = (NSValue *) dataDetector[@"range"];
            if (rangeValue) {
                NSRange r = [rangeValue rangeValue];
                NSRange spaceRange = [messageText rangeOfString:@" " options:0 range:r];
                if (spaceRange.location != NSNotFound) {
                    [atext replaceCharactersInRange:spaceRange withString:@"\u00a0"];
                }
            }
        }
    }
}

-(NSMutableAttributedString *) addPhoneDataDetectors:(NSArray<NSString *> *) numbers attributedText:(NSMutableAttributedString *)atext messageText:(NSString *) messageText
{
    for (NSString *phone in numbers) {
        NSRange r = [messageText rangeOfString:phone];
        if (r.location != NSNotFound) {
            [atext addAttribute:NSLinkAttributeName value:phone range:r];
            [self addDataDetectorType:@"phone" forData:phone andRange:r];
        }
    }

    return atext;
}

-(NSMutableAttributedString *) addUrlDataDetectors:(NSArray<NSURL *> *) urls attributedText:(NSMutableAttributedString *)atext messageText:(NSString *) messageText
{
    for (NSURL *url in urls)
    {
        NSString *urlString = [[url absoluteString] stringByRemovingPercentEncoding];
        urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSRange r = [messageText rangeOfString:urlString];
        if (r.location != NSNotFound)
        {
            //colorFromHex 4285f4
            [atext addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] range:r];
            
            [atext addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:r];
            
            [self addDataDetectorType:@"url" forData:url andRange:r];
        }
    }
    
    return atext;
}

-(NSMutableAttributedString *) addUserDataDetectors:(NSArray<NSDictionary<NSString *, NSObject *> *> *) users attributedText:(NSMutableAttributedString *)atext messageText:(NSString *) messageText
{
    for (NSDictionary *user in users) {
        NSString *name = user[@"name"];
        NSString *userid = user[@"userid"];
        UIColor *color = user[@"color"];
        
        if ([name length] == 0 || [userid length] == 0) {
            continue;
        }
        NSString *atName = [NSString stringWithFormat:@"@%@", name];
        NSRange r = [messageText rangeOfString:atName];

        if (r.location == NSNotFound) {
            continue;
        }
        
        if (!color) {
            color = [UIColor blueColor];
        }
        
        NSRange textRange = NSMakeRange(r.location + 1, r.length - 1);
        NSRange atRange = NSMakeRange(r.location, 1);

        
        [atext addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:atRange];
        [atext addAttribute:NSForegroundColorAttributeName value:color range:textRange];
        [self addDataDetectorType:@"user" forData:user andRange:r];
    }
    return atext;
}

-(void) addDataDetectorType:(NSString *) type forData:(NSObject *) dataObject andRange:(NSRange) r
{
    if (!self.dataDetectors) {
        self.dataDetectors = [NSMutableArray array];
    }
    
    NSMutableDictionary<NSString *, NSObject*> *dataDetector = [NSMutableDictionary dictionaryWithCapacity:4];
    dataDetector[@"type"] = type;
    dataDetector[@"data"] = dataObject;
    dataDetector[@"range"] = [NSValue valueWithRange:r];
    
    [self.dataDetectors addObject:dataDetector];
}


-(void) didTapOnDataDetector:(NSString *)type forData:(NSObject *) dataObject
{
    
    
    if (dataTapAction) {
        dataTapAction(type, dataObject);
    }
}

-(void) didLongPressOnDataDetector:(NSString *)type forData:(NSObject *) dataObject
{
    if (dataLongPressAction) {
        dataLongPressAction(type, dataObject);
    }
}

-(void) setDataTapAction:(void (^_Nullable)(NSString * _Nonnull type, NSObject * _Nullable dataObject)) action;
{
    dataTapAction = action;
}

-(void) setDataLongPressAction:(void (^_Nullable)(NSString * _Nonnull type, NSObject * _Nullable dataObject)) action;
{
    dataLongPressAction = action;
}

-(IBAction)handleTap:(UIGestureRecognizer *)sender
{
    NSLog(@"handleTap: %@", @(sender.state));
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    for (NSDictionary<NSString *, NSObject*> *dataDetector in self.dataDetectors) {
        NSValue *rangeValue = (NSValue *)dataDetector[@"range"];
        
        if ([self gestureRecognizer:self.tapDataDetectorGR didTapInRange:[rangeValue rangeValue]]) {
            NSMutableAttributedString *atext = [self.contentText.attributedText mutableCopy];
            [atext removeAttribute:NSBackgroundColorAttributeName range:[rangeValue rangeValue]];
            self.contentText.attributedText = atext;

            NSString *type = (NSString *)dataDetector[@"type"];
            NSObject *dataObject = dataDetector[@"data"];
            [self didTapOnDataDetector:type forData:dataObject];
            return;
        }
    }
}

-(IBAction)handleLongPress:(id)sender
{
    if (self.longPressDataDetectorGR.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    for (NSDictionary<NSString *, NSObject*> *dataDetector in self.dataDetectors) {
        NSValue *rangeValue = (NSValue *)dataDetector[@"range"];
        
        if ([self gestureRecognizer:self.longPressDataDetectorGR didTapInRange:[rangeValue rangeValue]]) {
            NSMutableAttributedString *atext = [self.contentText.attributedText mutableCopy];
            [atext removeAttribute:NSBackgroundColorAttributeName range:[rangeValue rangeValue]];
            self.contentText.attributedText = atext;
            
            NSString *type = (NSString *)dataDetector[@"type"];
            NSObject *dataObject = dataDetector[@"data"];
            [self didLongPressOnDataDetector:type forData:dataObject];
            return;
        }
    }

}



-(BOOL) gestureRecognizer:(UIGestureRecognizer *) gr didTapInRange:(NSRange) r
{
    UILabel *textLabel = self.contentText;
    CGPoint tapLocation = [gr locationInView:textLabel];
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textLabel.attributedText];
    
    UIFont *font = textLabel.font;
    if (font) {
        [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textStorage.length)];
    }
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    CGRect textRect = textLabel.frame;
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textRect.size.width, textRect.size.height) ];
    textContainer.lineFragmentPadding  = 0;
    textContainer.maximumNumberOfLines = textLabel.numberOfLines;
    textContainer.lineBreakMode        = textLabel.lineBreakMode;
    
    [layoutManager addTextContainer:textContainer];
    [layoutManager ensureLayoutForTextContainer:textContainer];
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:tapLocation
                                                      inTextContainer:textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];
    
    return NSLocationInRange(characterIndex, r);
}

-(BOOL) touch:(UITouch *) touch didTapInRange:(NSRange) r
{
    UILabel *textLabel = self.contentText;
    CGPoint tapLocation = [touch locationInView:textLabel];
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textLabel.attributedText];
    
    UIFont *font = textLabel.font;
    if (font) {
        [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textStorage.length)];
    }
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    CGRect textRect = textLabel.frame;
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textRect.size.width, textRect.size.height) ];
    textContainer.lineFragmentPadding  = 0;
    textContainer.maximumNumberOfLines = textLabel.numberOfLines;
    textContainer.lineBreakMode        = textLabel.lineBreakMode;
    
    [layoutManager addTextContainer:textContainer];
    [layoutManager ensureLayoutForTextContainer:textContainer];
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:tapLocation
                                                      inTextContainer:textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];
    
    return NSLocationInRange(characterIndex, r);
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    for (NSDictionary<NSString *, NSObject*> *dataDetector in self.dataDetectors) {
        NSValue *rangeValue = (NSValue *)dataDetector[@"range"];
        
        if ([self touch:touch didTapInRange:[rangeValue rangeValue]]) {
            
            NSMutableAttributedString *atext = [self.contentText.attributedText mutableCopy];
            
            [atext addAttribute:NSBackgroundColorAttributeName value:[[UIColor blackColor] colorWithAlphaComponent:0.15] range:[rangeValue rangeValue]];
        
            self.contentText.attributedText = atext;
            
            return YES;
        }
    }
    
    return NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;{
    return NO;
}

- (BOOL)isPureEmojiString:(NSString*)string
{
    if (string.length == 0) {
        return NO;
    }
    
    __block BOOL isPureEmojiString = YES;
    
    [string enumerateSubstringsInRange:NSMakeRange(0,
                                                 [string length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring,
                                       NSRange substringRange,
                                       NSRange enclosingRange,
                                       BOOL *stop)
     {
         BOOL containsEmoji = NO;
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs &&
             hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc &&
                     uc <= 0x1f9c0)
                 {
                     containsEmoji = YES;
                 }
             }
         }
         else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3 ||
                 ls == 0xfe0f ||
                 ls == 0xd83c)
             {
                 containsEmoji = YES;
             }
         }
         else
         {
             // non surrogate
             if (0x2100 <= hs &&
                 hs <= 0x27ff)
             {
                 containsEmoji = YES;
             }
             else if (0x2B05 <= hs &&
                      hs <= 0x2b07)
             {
                 containsEmoji = YES;
             }
             else if (0x2934 <= hs &&
                      hs <= 0x2935)
             {
                 containsEmoji = YES;
             }
             else if (0x3297 <= hs &&
                      hs <= 0x3299)
             {
                 containsEmoji = YES;
             }
             else if (hs == 0xa9 ||
                      hs == 0xae ||
                      hs == 0x303d ||
                      hs == 0x3030 ||
                      hs == 0x2b55 ||
                      hs == 0x2b1c ||
                      hs == 0x2b1b ||
                      hs == 0x2b50)
             {
                 containsEmoji = YES;
             }
         }
         
         if (!containsEmoji)
         {
             isPureEmojiString = NO;
             *stop = YES;
         }
     }];
    
    return isPureEmojiString;
}

@end

@implementation SCCallEventContentView
@end

@implementation SCPictureEventContentView

-(void) prepareForReuse
{
    self.contentImage.image = nil;
    [self.activityView stopAnimating];
}

-(BOOL) showTransferProgress;
{
    if (!self.activityView.animating) {
        [self.activityView startAnimating];
        return YES;
    }
    
    return NO;
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    
}

-(BOOL) hideTransferProgress;
{
    if (self.activityView.animating) {
        [self.activityView stopAnimating];
        return YES;
    }
    
    return NO;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    self.contentImage.image = previewImage;
    NSLog(@"SCBoardTest: presentContentForKey: %@ / %@x%@", mediaKey, @(previewImage.size.width), @(previewImage.size.height));
}

@end

@implementation SCVideoEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.progress.progress = 0.;
    self.progress.hidden = YES;
}

-(BOOL) showTransferProgress;
{
    [super showTransferProgress];
    
    if (!self.progress.hidden) {
        self.progress.hidden = NO;
        return YES;
    }
    
    return NO;
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    self.progress.progress = progress;
}

-(BOOL) hideTransferProgress;
{
    [super hideTransferProgress];
    
    if (self.progress.hidden) {
        self.progress.hidden = YES;
        return YES;
    }
    
    return NO;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    self.contentImage.image = previewImage;
    self.duration.text = [[C2CallPhone currentPhone] durationForKey:mediaKey];
    NSLog(@"SCBoardTest: presentContentForKey: %@ / %@x%@", mediaKey, @(previewImage.size.width), @(previewImage.size.height));

}

@end

@implementation SCAudioEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.progress.progress = 0.;
    self.duration.text = nil;
    self.elapsed.text = nil;
    self.play.highlighted = NO;
    [self.activityView stopAnimating];
    self.pttPlayer = nil;
}

-(BOOL) showTransferProgress;
{
    [super showTransferProgress];

    if (!self.activityView.animating) {
        [self.activityView startAnimating];
        return YES;
    }
    
    return NO;
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    self.progress.progress = progress;
}

-(BOOL) hideTransferProgress;
{
    [super hideTransferProgress];

    self.progress.progress = 0;

    if (self.activityView.animating) {
        [self.activityView stopAnimating];
        return YES;
    }
    
    return NO;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    self.duration.text = [[C2CallPhone currentPhone] durationForKey:mediaKey];
    self.elapsed.text = nil;
}

@end

@implementation SCLocationEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.locationInfoView.hidden = YES;
    self.locationInfo.text = nil;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    self.contentImage.image = previewImage;
}

-(void) presentContentForLocation:(FCLocation *) loc withPreviewImage:(UIImage *) previewImage
{
    self.contentImage.image = previewImage;

    if (loc.place) {
        self.locationInfoView.hidden = NO;
         NSString *name = [loc.place objectForKey:@"name"];
        self.locationInfo.text = name;
    }
}

@end

@implementation SCFileEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.fileInfo.text = nil;
    self.fileIcon.image = nil;
    self.fileInfoView.hidden = YES;
    self.progressView.hidden = YES;
    self.progress.progress = 0.;
    self.contentImage.hidden = YES;
    self.typeInfo.text = @"--";
    self.sizeInfo.text = @"--";
    
    [self.activityView stopAnimating];

}

-(BOOL) showTransferProgress;
{
    [super showTransferProgress];
    
    if (!self.progressView.hidden) {
        self.progressView.hidden = NO;
        [self.activityView startAnimating];
        return YES;
    }
    
    return NO;
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    if (self.progressView.hidden) {
        self.progressView.hidden = NO;
    }

    self.progress.progress = progress;
}

-(BOOL) hideTransferProgress;
{
    [super hideTransferProgress];

    if (!self.progressView.hidden) {
        self.progressView.hidden = YES;
        [self.activityView stopAnimating];
        return YES;
    }

    return NO;
}


-(NSString *) filenameForKey:(NSString *) mediaKey
{
    NSString *filename = [[[C2CallPhone currentPhone] metaInfoForKey:mediaKey] objectForKey:@"name"];
    if (!filename) {
        filename = [[self extensionForKey:mediaKey] uppercaseString];
    }
    if (!filename) {
        filename = @"";
    }
    
    return filename;
}

-(NSString *) extensionForKey:(NSString *) mediaKey
{
    NSString *ext = @"";
    NSRange r = [mediaKey rangeOfString:@"." options:NSBackwardsSearch];

    if (r.location != NSNotFound) {
        ext = [[mediaKey substringFromIndex:r.location + 1] lowercaseString];
    }

    return ext;
}

-(NSString *) fileSizeForKey:(NSString *) mediaKey
{
    NSNumber *fsize = [[[C2CallPhone currentPhone] metaInfoForKey:mediaKey] objectForKey:@"size"];
    if (fsize) {
        double sz = [fsize doubleValue];
        double kb = sz / 1024.;
        double mb = kb / 1024.;
        
        NSInteger sfz = (NSInteger) mb;
        if (sfz > 0) {
            return [NSString stringWithFormat:@"%@ MB", @(sfz)];
        }
        
        sfz = (NSInteger) kb;
        if (sfz > 0) {
            return [NSString stringWithFormat:@"%@ KB", @(sfz)];
        }
        
        sfz = (NSInteger) sz;
        if (sfz > 0) {
            return [NSString stringWithFormat:@"%@ Bytes", @(sfz)];
        }

        
    }

    return nil;
}

-(UIImage *) iconForFileType:(NSString *) fileType
{
    if ([[fileType lowercaseString] hasSuffix:@"pdf"]) {
        return [[SCAssetManager instance] imageForName:@"ico_pdf"];
    }
    
    if ([[fileType lowercaseString] hasSuffix:@"doc"]) {
        return [[SCAssetManager instance] imageForName:@"ico_doc"];
    }
    
    if ([[fileType lowercaseString] hasSuffix:@"docx"]) {
        return [[SCAssetManager instance] imageForName:@"ico_doc"];
    }
    
    if ([[fileType lowercaseString] hasSuffix:@"xls"]) {
        return [[SCAssetManager instance] imageForName:@"ico_xls"];
    }
    
    if ([[fileType lowercaseString] hasSuffix:@"xlsx"]) {
        return [[SCAssetManager instance] imageForName:@"ico_xls"];
    }
    
    if ([[fileType lowercaseString] hasSuffix:@"ppt"]) {
        return [[SCAssetManager instance] imageForName:@"ico_ppt"];
    }
    
    if ([[fileType lowercaseString] hasSuffix:@"pptx"]) {
        return [[SCAssetManager instance] imageForName:@"ico_ppt"];
    }

    if ([[fileType lowercaseString] hasSuffix:@"txt"]) {
        return [[SCAssetManager instance] imageForName:@"ico_txt"];
    }

    if ([[fileType lowercaseString] hasSuffix:@"rtf"]) {
        return [[SCAssetManager instance] imageForName:@"ico_txt"];
    }

    if ([[fileType lowercaseString] hasSuffix:@"numbers"]) {
        return [[SCAssetManager instance] imageForName:@"ico_xls"];
    }

    if ([[fileType lowercaseString] hasSuffix:@"keynote"]) {
        return [[SCAssetManager instance] imageForName:@"ico_ppt"];
    }

    if ([[fileType lowercaseString] hasSuffix:@"pages"]) {
        return [[SCAssetManager instance] imageForName:@"ico_doc"];
    }

    
    return nil;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    _filename = [self filenameForKey:mediaKey];
    
    NSString *fileType = [self extensionForKey:mediaKey];
    self.typeInfo.text = fileType;
    self.sizeInfo.text = [self fileSizeForKey:mediaKey];
    
    UIImage *icon = [self iconForFileType:fileType];
    self.fileIcon.image = icon;
    
    if (self.filename) {
        self.fileInfo.text = self.filename;
        self.fileInfoView.hidden = NO;
    }
    
    if (previewImage) {
        self.contentImage.image = previewImage;
        self.contentImage.hidden = NO;
    }
}


@end

@implementation SCContactEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.contactName.text = nil;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    if (previewImage) {
        self.contactImage.image = previewImage;
    }
    self.contactName.text = mediaKey;
}

-(IBAction)saveContact:(id)sender
{
    [self.saveAction fireAction:self];
}

-(IBAction)messageContact:(id)sender
{
    [self.messageAction fireAction:self];
}

@end
