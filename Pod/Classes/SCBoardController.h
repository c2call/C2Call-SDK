//
//  SCBoardController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 19.02.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCDataTableViewController.h"

typedef enum {
    SCBoardMessageFilter_NONE,
    SCBoardMessageFilter_IMAGE,
    SCBoardMessageFilter_VIDEO,
    SCBoardMessageFilter_VOICEMAIL,
    SCBoardMessageFilter_LOCATION,
    SCBoardMessageFilter_CALL,
    SCBoardMessageFilter_MISSED
} SCBoardMessageFilterType;


@class MOC2CallUser, MessageCell, MOC2CallEvent, C2TapImageView;


/** Presents the standard C2Call SDK Message Board Controller.
 
The BoardController shows MOC2CallEvent Items (Chat History and Call History) in the typical style of message bubbles. The BoardController is highly customizable and the developer is free to design the look&feel of the board. It also comes with several filter options to filter the content shown in the board. Available Filter are:
 
    SCBoardMessageFilter_IMAGE - Show only Images
    SCBoardMessageFilter_VIDEO - Show only Videos
    SCBoardMessageFilter_VOICEMAIL - Show only VoiceMails
    SCBoardMessageFilter_LOCATION - Show only Locations
    SCBoardMessageFilter_CALL - Show only Call History
    SCBoardMessageFilter_MISSED - Show only missed events
 
 */

@interface SCBoardController : SCDataTableViewController

/** @name Outlets */
/** Show previous messages button.
 
 Default, the board shows only the last 25 events. Tapping the previous messages button 50, 75, 100 and so on events will be shown.
 */
@property(nonatomic, strong) IBOutlet UIButton              *previousMessagesButton;

/** The Filter Button shows the filter menu; sets the button state selected when a filter is set. */
@property(nonatomic, strong) IBOutlet UIButton              *filterButton;

/** UIView references to the first section header. */
@property(nonatomic, strong) IBOutlet UIView                *headerView;

/** UIView references to the first section header (new Version). */
@property(nonatomic, strong) IBOutlet UIView                *headerViewEmbed;

/** UIView references to the filter info view. */
@property(nonatomic, strong) IBOutlet UIView                *filterInfoView;

/** UIView references for the timestamp header. */
@property(nonatomic, strong) IBOutlet UIView                *timestampHeader;

/** UIView references to the first timestamp header. */
@property(nonatomic, strong) IBOutlet UIView                *firstHeaderView;

/** FirstTimeStamp Header Timestamp Label. */
@property(nonatomic, strong) IBOutlet UILabel               *firstHeaderLabel;

/** TimestampHeader Timestamp Label. */
@property(nonatomic, strong) IBOutlet UILabel               *timestampLabel;

/** Filter Info Label. */
@property(nonatomic, strong) IBOutlet UILabel               *labelFilterInfo;

/** @name Properties */
/** Targetuserid (can be userId of phone number).

 Shows only messages of the defined friend or phone number contact.
 Can be nil.
 
 */
@property (nonatomic, strong) NSString *targetUserid;

/** Suppress Call Events in Event History
 
 SCChatController will set this to YES, to suppress Call Events
 in a person to person chat.
 */
@property (nonatomic) BOOL dontShowCallEvents;

/** Current Active Filters in Human Readable Format. */
@property(nonatomic, strong) NSString                       *activeFilterInfo;

/** Sets one of the following filters:
 
    SCBoardMessageFilter_IMAGE - Show only Images
    SCBoardMessageFilter_VIDEO - Show only Videos
    SCBoardMessageFilter_VOICEMAIL - Show only VoiceMails
    SCBoardMessageFilter_LOCATION - Show only Locations
    SCBoardMessageFilter_CALL - Show only Call History
    SCBoardMessageFilter_MISSED - Show only missed events

 @param filter - The filter type
 */
-(void) setMessageFilter:(SCBoardMessageFilterType) filter;

/** Sets a Fulltext Filter on all Board Messages
 
 @param text - Filter text.
 */
-(void) setTextFilterForText:(NSString *) text;

/** Removes the current text filter. */
-(void) removeTextFilter;

/** Forwards the given message text.
 
 In case the message text is a rich media key, the rich media object will be forwarded.
 
 @param message - Text to forward
 */
-(void) forwardMessage:(NSString *)message;

/** Shares Rich Media Item as email.
 
 @param key - Rich Media Key
 */
-(void) shareEmail:(NSString *) key;

/** Copies message text to clipboard.
 
 @param text - The message text
 */
-(void) copyText:(NSString *) text;

/** Copies Image to clipboard.
 
 @param key - Rich Media Key of the image to copy
 */
-(void) copyImageForKey:(NSString *) key;

/** Copies Location to clipboard.
 
 @param key - Rich Media Key of the location to copy
 */
-(void) copyLocationForKey:(NSString *) key;

/** Copies Videop to clipboard.
 
 @param key - Rich Media Key of the Video to copy
 */
-(void) copyMovieForKey:(NSString *) key;

/** Shows the standard share message popup for a Rich Media Item.
 
 Default Implementation:
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via FriendCaller", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward"] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    [cv addChoiceWithName:NSLocalizedString(@"Email", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via Email", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_email"] andCompletion:^(){
        [self shareEmail:key];
    }];
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
 
 @param key - Rich Media Key
 */
-(void) shareRichMessageForKey:(NSString *) key;

/** @name Actions */
/** Removes all filters.
 
 @param sender - The initiator of the action
 
 */
-(IBAction)removeAllFilter:(id)sender;

/** Shows previous messages action.
 
 @param sender - The initiator of the action

 */
-(IBAction)previousMessages:(id)sender;

/** Shows the filter menu.
 
 Default Implementation:
     SCPopupMenu *popup = [SCPopupMenu popupMenu:self];
    
    [popup addChoiceWithName:NSLocalizedString(@"Remove Filter", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self removeAllFilter:nil];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Images", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_IMAGE];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Videos", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_VIDEO];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Voice Mails", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_VOICEMAIL];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Locations", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_LOCATION];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Calls", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_CALL];
    }];

    [popup addChoiceWithName:NSLocalizedString(@"Missed", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_MISSED];
    }];

    [popup addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [popup showMenu];

 
 @param sender - The initiator of the action
 
 */
-(IBAction)filterMenu:(id)sender;

/** Answers the last message.
 
 Uses the SCComposeMessageController to answer the last message as follows:
 
    [self composeMessage:nil richMessageKey:nil answerLastContact:YES];

 @param sender - The initiator of the action
 */
-(IBAction)answerMessage:(id)sender;


/** Opens the Compose Message Controller.
 
 Default Implementation:
    [self composeMessage:nil richMessageKey:nil];
 
 @param sender - The initiator of the action
 */
-(IBAction)composeAction:(id)sender;

/** Returns the Image of the current user as thumbnail
 @return userimage
 */
-(UIImage *) ownUserImage;

/** Returns the Image of the current contact
 @return contact image or avatar image
 */
-(UIImage *) imageForElement:(MOC2CallEvent *) elem;

/** Set a specific action for a touch on the user image
 
 This method will be called by configure cell methods
 Overwrite this method if you want to set a specific action for a touch on the user image
 
 @param imageView - The Userimage view
 @param elem - The corresponding MOC2CallEvent
 */
-(void) setUserImageAction:(C2TapImageView *) imageView forElement:(MOC2CallEvent *) elem;

/** Set the subitted status icon
 
 This method will be called by configure cell methods
 Overwrite this method if you want to set a specific submitted status icon
 
 @param cell - The current cell to configure
 @param messageStatus - The submission status
 */
-(void) setSubmittedStatusIcon:(MessageCell *) cell forStatus:(int) messageStatus;

/** Set the retransmit action
 
 This method will be called by configure cell methods
 Overwrite this method if you want to set a specific retransmit action
 
 @param cell - The current cell to configure
 @param key - The Rich Media Key
 @param userid - The target userid
 */
-(void) setRetransmitActionForCell:(MessageCell *) cell withKey:(NSString *) key andUserid:(NSString *) userid;

@end
