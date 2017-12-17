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

@implementation SCEventContentView

-(void) prepareForReuse
{
    // Just Empty
}

-(void) showTransferProgress;
{
    // Just Empty
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    // Just Empty
}

-(void) hideTransferProgress;
{
    // Just Empty
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    // Just Empty
}

@end

@implementation SCTextEventContentView

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    self.contentText.text = nil;
    self.contentText.attributedText = nil;
}

-(void) presentTextContent:(NSString *_Nullable) messageText withTextColor:(UIColor *) textColor andDataDetector:(NSDictionary<NSString*, NSArray *> *_Nullable) dataDetector;
{
    if (dataDetector) {
        NSMutableAttributedString *atext = [[NSMutableAttributedString alloc] initWithString:messageText];
        
        
        NSArray<NSURL *> *urls = dataDetector[@"url"];
        for (NSURL *url in urls) {
            NSRange r = [messageText rangeOfString:[url absoluteString]];
            if (r.location != NSNotFound) {
                [atext addAttribute:NSLinkAttributeName value:[url absoluteString] range:r];
            }
        }

        NSArray<NSString *> *numbers = dataDetector[@"phone"];
        for (NSString *phone in numbers) {
            NSRange r = [messageText rangeOfString:phone];
            if (r.location != NSNotFound) {
                [atext addAttribute:NSLinkAttributeName value:phone range:r];
            }
        }

        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"transparent60x13"];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [atext insertAttributedString:attrStringWithImage atIndex:[messageText length]];

        self.contentText.attributedText = atext;
    } else {
        NSMutableAttributedString *atext = [[NSMutableAttributedString alloc] initWithString:messageText];

        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"transparent60x13"];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [atext insertAttributedString:attrStringWithImage atIndex:[messageText length]];
        
        self.contentText.attributedText = atext;
    }
    self.contentText.textColor = textColor;
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

-(void) showTransferProgress;
{
    [self.activityView startAnimating];

    
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    
}

-(void) hideTransferProgress;
{
    [self.activityView stopAnimating];
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

-(void) showTransferProgress;
{
    [super showTransferProgress];
    
    self.progress.hidden = NO;
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    self.progress.progress = progress;
}

-(void) hideTransferProgress;
{
    [super hideTransferProgress];
    self.progress.hidden = YES;
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

-(void) showTransferProgress;
{
    [super showTransferProgress];
    [self.activityView startAnimating];
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    self.progress.progress = progress;
}

-(void) hideTransferProgress;
{
    [super hideTransferProgress];
    self.progress.progress = 0;
    [self.activityView stopAnimating];
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
    self.fileInfoView.hidden = YES;
    self.progress.hidden = YES;
    self.contentImage.hidden = YES;
}

-(void) showTransferProgress;
{
    [super showTransferProgress];
    [self.activityView startAnimating];
}

-(void) updateTransferProgress:(CGFloat) progress;
{
    if (self.progress.hidden) {
        self.progress.hidden = NO;
    }

    self.progress.progress = progress;
}

-(void) hideTransferProgress;
{
    [super hideTransferProgress];
    self.progress.hidden = YES;
}


-(NSString *) filenameForKey:(NSString *) mediaKey
{
    NSString *filename = [[[C2CallPhone currentPhone] metaInfoForKey:mediaKey] objectForKey:@"name"];
    if (!filename) {
        NSRange r = [mediaKey rangeOfString:@"."];
        if (r.location != NSNotFound) {
            filename = [[mediaKey substringFromIndex:r.location + 1] uppercaseString];
        }
    }
    if (!filename) {
        filename = @"";
    }
    
    return filename;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    _filename = [self filenameForKey:mediaKey];

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
    self.contactImage.image = nil;
    self.contactImage.hidden = YES;
}

-(void) presentContentForKey:(NSString *) mediaKey withPreviewImage:(UIImage *) previewImage
{
    if (previewImage) {
        self.contactImage.image = previewImage;
        self.contactImage.hidden = NO;
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
