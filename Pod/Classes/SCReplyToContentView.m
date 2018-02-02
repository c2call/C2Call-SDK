//
//  SCReplyToContentView.m
//  C2CallPhone
//
//  Created by Michael Knecht on 24.11.17.
//

#import "SCReplyToContentView.h"
#import <SocialCommunication.h>
#import <Contacts/Contacts.h>

@implementation SCReplyToContentView

-(void) removeFromSuperview
{
    [super removeFromSuperview];
}

-(void) willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

-(UIImage *) vcardImageForKey:(NSString *) mediaKey
{
    NSData *data = nil;
    
    if ([mediaKey hasPrefix:@"vcard://"]) {
        if (![[C2CallPhone currentPhone] hasObjectForKey:mediaKey]) {
            return nil;
        }
        
        NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:mediaKey];
        if (!url) {
            return nil;
        }
        
        data = [NSData dataWithContentsOfURL:url];
    } else {
        data = [mediaKey dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([data length] == 0) {
        return nil;
    }
    
    NSError *error = nil;
    NSArray<CNContact *> *personArray = [CNContactVCardSerialization contactsWithData:data error:&error];
    CNContact *person = [personArray count] > 0?  personArray[0] : nil;
    
    NSString *compositName = person ? [CNContactFormatter stringFromContact:person style:CNContactFormatterStyleFullName] : nil;
#
    //(NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
    NSData *imageData = person.imageData;
    UIImage *vcardImage = nil;
    
    if (imageData != NULL) {
        vcardImage = [UIImage imageWithData:imageData];
    }
    
    return vcardImage;
}

-(UIImage *) previewImageForKey:(NSString *) mediaKey
{
    UIImage *img = [[C2CallPhone currentPhone] thumbnailForKey:mediaKey];
    
    return img;
}

-(BOOL) presentReplyToContentFor:(NSString *)eventId
{
    if (!eventId) {
        return NO;
    }
    
    MOC2CallEvent *elem = [[SCDataManager instance] eventForEventId:eventId];
    
    if (!elem) {
        return NO;
    }
    
    NSString *sendername = nil;
    if ([elem.eventType isEqualToString:@"MessageOut"]) {
        self.replyToUserid = [SCUserProfile currentUser].userid;
        sendername = [SCUserProfile currentUser].displayname;
    } else {
        self.replyToUserid = elem.originalSender? [elem.originalSender copy] : [elem.contact copy];
        sendername = [[C2CallPhone currentPhone] nameForUserid:self.replyToUserid];
    }
    
    if ([sendername isEqualToString:self.replyToUserid]) {
        sendername = elem.senderName;
    }
    
    self.replyToName.text = sendername;
    
    SCRichMediaType rt = [[C2CallPhone currentPhone] mediaTypeForKey:elem.text];
    
    self.replyToIcon.hidden = NO;
    self.replyToPreviewImage.hidden = NO;
    
    switch (rt) {
        case SCMEDIATYPE_TEXT:
            self.replyToText.text = elem.text;
            self.replyToIcon.hidden = YES;
            self.replyToPreviewImage.hidden = YES;
            break;
        case SCMEDIATYPE_FILE:
            self.replyToText.text = @"Attachment";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_video"];
            self.replyToPreviewImage.hidden = YES;
            break;
        case SCMEDIATYPE_VCARD: {
            self.replyToText.text = @"Contact";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_vcard"];
            
            UIImage *vcardImage = [self vcardImageForKey:elem.text];
            if (vcardImage) {
                self.replyToPreviewImage.image = vcardImage;
            } else {
                self.replyToPreviewImage.hidden = YES;
            }
            break;
        }
        case SCMEDIATYPE_IMAGE: {
            self.replyToText.text = @"Picture";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_image"];
            
            UIImage *image = [self previewImageForKey:elem.text];
            if (image) {
                self.replyToPreviewImage.image = image;
            } else {
                self.replyToPreviewImage.hidden = YES;
            }
            break;
            
        }
            break;
        case SCMEDIATYPE_VIDEO: {
            self.replyToText.text = @"Video";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_video"];
            
            UIImage *image = [self previewImageForKey:elem.text];
            if (image) {
                self.replyToPreviewImage.image = image;
            } else {
                self.replyToPreviewImage.hidden = YES;
            }
        }
            break;
        case SCMEDIATYPE_VOICEMAIL: {
            self.replyToText.text = @"Voicemail";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_voice_msg"];
            self.replyToPreviewImage.hidden = YES;
        }
            
            break;
        case SCMEDIATYPE_FRIEND: {
            self.replyToText.text = @"Friend";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_friend_30x30"];
            
            self.replyToPreviewImage.hidden = YES;
        }
            
            break;
        case SCMEDIATYPE_LOCATION:
        {
            self.replyToText.text = @"Location";
            self.replyToIcon.image = [[SCAssetManager instance] imageForName:@"ico_geolocation-24x24"];
            
            UIImage *image = [self previewImageForKey:elem.text];
            if (image) {
                self.replyToPreviewImage.image = image;
            } else {
                self.replyToPreviewImage.hidden = YES;
            }
        }
            break;
        default:
            self.replyToText.text = elem.text;
            self.replyToIcon.hidden = YES;
            self.replyToPreviewImage.hidden = YES;
            break;
    }
    
    self.replyToIcon.superview.hidden = self.replyToIcon.hidden;
    return YES;
}

-(void) setReplyToColor:(UIColor *)color
{
    self.replyToName.textColor = color;
    self.replyToSideBar.backgroundColor = color;
}

@end


