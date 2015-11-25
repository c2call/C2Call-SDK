//
//  SCPhotoViewerController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 09.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "C2ExpandViewController.h"

/** Presents the standard C2Call SDK Photo Viewer Controller.
 */
@interface SCPhotoViewerController :  C2ExpandViewController  

/** @name Outlets */
/** PhotoViewer ScollView. */
@property(nonatomic, weak) IBOutlet UIScrollView *pagingScrollView;

/** Activity View presented when loading photos. */
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

/** Title of the Photo. */
@property(nonatomic, weak) IBOutlet UILabel     *labelTitle;

/** Sub-Title of the Photo. */
@property(nonatomic, weak) IBOutlet UILabel     *labelSubtitle;

/** Attached message to the Photo. */
@property(nonatomic, weak) IBOutlet UILabel     *labelMessage;

/** View Containing the message label.
    
 This view will be hidden if no message is attached to the photo.
 */
@property(nonatomic, weak) IBOutlet UIView      *messageView;

/** View containing photo action controls.
 
 This view will be hidden on touch or re-displayed.
 */
@property(nonatomic, weak) IBOutlet UIView      *controlsView;

/** Button to toggle the full-screen mode.
 
 The Photo Viewer is sub classing C2ExpandViewController to provide a full-screen view for the photos with expand and collapse animations.
 */
@property(nonatomic, weak) IBOutlet UIButton    *expandCollapseButton;

/** @name Other Methods */
/** Sets the list of images to present and the current image which is presented first.
 
 The list of images requires to be an NSArray of NSDictionary objects with the following values:
 
    image - Rich Media Key of the image
    eventType - See MOC2CallEvent.eventType (optional)
    senderName - The sender of the image (assigned to labelTitle). See MOC2CallEvent.senderName (optional)
    timeStamp - Assigned to labelSubTitle. See MOC2CallEvent.timeStamp (optional)
    
 
 @param images - The list of images to present
 @param imageKey - Rich Media Key of the first image to show
 */
-(void)setImages:(NSArray *) images currentImage:(NSString *) imageKey;

/** Scrolls to image with index.
 
 @param index - Image index
 @param animate - YES / NO
 */
-(void) scrollToPage:(int)index animate:(BOOL) animate;

/** Number of images.
 
 @return Number of images
 */
-(NSUInteger) imageCount;

/** Gets the image at index.
 
 @param index - Index of the requested image
 @return The image
 */
-(UIImage *) imageAtIndex:(NSUInteger)index;

/** Gets the Rich Media Key for the current visible image.
 
 @return The image key
 */
-(NSString *) imageKeyForVisibleImage;

/** @name Actions */
/** Copies the current visible image to ClipBoard.
 
 @param sender - The initiator of the action
 */
-(IBAction) copyImage:(id) sender;

/** Saves the current visible image to the photo album.
 
 @param sender - The initiator of the action
 */
-(IBAction) saveToAlbum:(id)sender;

/** Forwards the current visible image.
 
 @param sender - The initiator of the action
 */
-(IBAction) forwardMessage:(id) sender;

/** Shares the current visible image as email.
 
 @param sender - The initiator of the action
 */
-(IBAction) shareEmail:(id) sender;

/** Shows the default content menu using SCPopupMenu.
 
 Default Implementation:
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via FriendCaller", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward"] andCompletion:^(){
        [self forwardMessage:nil];
    }];
    
    if ([MFMailComposeViewController canSendMail]) {
        [cv addChoiceWithName:NSLocalizedString(@"Email", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via Email", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_email"] andCompletion:^(){
            [self shareEmail:nil];
        }];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [cv addChoiceWithName:NSLocalizedString(@"Copy", @"MenuItem") andSubTitle:NSLocalizedString(@"Copy to Clipboard", @"Button") andIcon:[UIImage imageNamed:@"ico_copy"] andCompletion:^{
            [self copyImage:nil];
        }];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [cv addChoiceWithName:NSLocalizedString(@"Save", @"Choice Title") andSubTitle:NSLocalizedString(@"Save to your Camera Roll", @"Button") andIcon:[UIImage imageNamed:@"ico_image"] andCompletion:^{
            [self saveToAlbum:nil];
        }];
    }
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
        
    }];
    
    [cv showMenu];
 
 
 @param sender - The initiator of the action
 */
-(IBAction) contentAction:(id)sender;

/** Magnifies or Shrink the current visible image.
 */
-(IBAction) magnifyImage:(id)sender;

/** Shows the previous image.
 */
-(IBAction) arrowLeft:(id)sender;

/** Shows the next image.
 */
-(IBAction) arrowRight:(id)sender;

@end
