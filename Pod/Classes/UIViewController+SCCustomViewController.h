//
//  UIViewController+SCCustomViewController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 08.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "C2CallPhone.h"

@protocol SCCountrySelectionDelegate;

/** This UIViewController category provides convenience methods for instantiation and launch of C2Call SDK GUI component.
 
 The C2Call SDK provides feature rich components for rich media content handling and social media communication features.
 The basic concept of this SDK is, to combine convenience and ease of use with great flexibility for all provided components.
 The UIViewController+SCCustomViewController category provides easy access to those components, whether they will be used as standard components from SCStoryboard or as customized components from the MainStoryboard of the developed application.
 
 In iOS Storyboard an UIViewController represents one screen of content and the transitions between two UIViewControllers will be defined by an UIStoryboardSegue.
 In C2Call SDK the UIViewController based GUI components will be also presented via UIStoryboardSegue, so that the developer can define the transition in his MainStoryboard. Several components require one or more parameters, which typically have to be set in method prepareForSegue:sender. 
 The UIViewController+SCCustomViewController provides convenience methods to present C2Call SDK GUI components with a one or two lines of code and ensures that required parameter will be correctly set in the presented ViewController.
 
 
 The following GUI components are supported:

    Presenting Rich Media Content
    - SCComposeMessageController (Composes and submit a new Instant Message, 
      Rich Media Message or SMS/Text Message to a user or phone number)
    - SCPhotoViewerController (Presents photos)
    - SCVideoPlayerController (Presents a Video Player)
    - SCLocationViewerController (Presents a location in a map view)
    - SCAudioPlayerController (Presents an Audio Player for VoiceMails)
    
    Capture Rich Media Content:
    - UIImagePickerController (Captures an Image or Video from Camera or Photo Album with Quality)
    - SCAudioRecorderController (Records and submits a VoiceMail)
    - SCLocationSubmitController (Picks and submits the current location or nearby Google places)
    
    Show Friends, Groups and Chat History:
    - SCChatController (Presents a Chat History with a specific contact)
    - SCFriendDetailController (Presents the details of a connected friend)
    - SCGroupDetailController (Presents the details of a connected group)
 
    Others:
    - SCBrowserViewController (Opens an URL in a Browser View)
 
 In case the developer connects the above components in his MainStoryboard via UIStoryboardSegue the segues have to be named with a specific name convention in order to handle the parameters setup in prepareForSegue:sender correctly. Each connected UIStoryboardSegue has to be named like the target ViewControllers original class name, for example:

    Target UIViewController Class           Segue Name
    SCComposeMessageController      ->      SCComposeMessageControllerSegue
    SCPhotoViewerController         ->      SCPhotoViewerControllerSegue
    SCVideoPlayerController         ->      SCVideoPlayerControllerSegue
    SCLocationViewerController      ->      SCLocationViewerControllerSegue
    etc.
 
 In addition to this naming convention, the developer needs to call customPrepareForSegue:sender in his prepareForSegue:sender method:
 
    -(void) prepareForSegue:(UIStoryboardSegue*) segue sender:(id) sender
    {
        [self customPrepareForSegue:segue sendersender];
 
        // Do your own setup
        ...
    }
 
 All ViewControllers covered by this UIViewController category can be also presented without UIStoryboardSegue connections.
 In this case the component will be instantiated from MainStoryboard and if not found there, from SCStoryboard. 
 It'll push the component if the current ViewController is embedded in a UINavigationController and present modal else.
 We recommend to use UIStoryboardSegue if the developers wants to have full control on this behavior.
 
 */
@interface UIViewController (SCCustomViewController) 

-(void) pushRightBarButtonItem:(UIBarButtonItem *) barButton;
-(void) pushLeftBarButtonItem:(UIBarButtonItem *) barButton;

-(void) popRightBarButtonItem;
-(void) popLeftBarButtonItem;

-(BOOL) hasLeftBarButtonStack;
-(BOOL) hasRightBarButtonStack;
- (UIView *)findFirstResponder:(UIView *) startView;

-(BOOL) addCloseButtonIfNeeded;
-(BOOL) addCancelButtonIfNeeded;
-(IBAction)closeViewControllerWithAnimation:(id)sender;
-(IBAction)closeViewControllerWithoutAnimation:(id)sender;

/** @name Instantiate SDK ViewControllers */
/** Instantiates a C2Call SDK GUI Component.
 
 The C2Call SDK provides various standard components for all its communication features.
 These components may be used as is or can be modified by the application developer.
 To do so, copy the GUI Component from the SCStoryboard, to the application MainStoryboard and modify it.
 
 instantiateViewControllerWithIdentifier first seeks the component in the MainStoryboard and then in the SCStoryboard to instantiate the component.
 This ensures that that the developer version takes precedence over the standard version.
 
 @param vcname - Storyboard Name of the ViewController
 */
-(UIViewController *) instantiateViewControllerForName:(NSString *) vcname;

/** @name Segue Handling */
/** Handels the parameter setup for SDK GUI Components connected via UIStoryboardSegue.
     
    Please see the above description.
 
 @param segue - The StoryboardSegue
 @param sender - The sender
 */
-(void) customPrepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

/** @name Compose Message */
/** Presents the standard SCComposeMessageController.
 
 @param messageOrNil - Preset the message text (optional)
 @param keyOrNil - Preset the Rich Media Content item (optional)
 */
-(void) composeMessage:(NSString *) messageOrNil richMessageKey:(NSString *) keyOrNil;

/** Presents the standard SCComposeMessageController with the last communication contact pre-selected as target.
 
 @param messageOrNil - Preset the message text (optional)
 @param keyOrNil - Preset the Rich Media Content item (optional)
 @param answer - YES - Use the last contact as pre-selected receiver / NO - Shows the receiver selection first
 */
-(void) composeMessage:(NSString *) messageOrNil richMessageKey:(NSString *) keyOrNil answerLastContact:(BOOL) answer;

/** @name Present Rich Media Items */
/** Presents a photo using the SCPhotoViewerController component.
 
 @param imageKey - Rich Media Key of an image
*/
-(void) showPhoto:(NSString *) imageKey;

/** Presents a list of photos using the SCPhotoViewerController component.

 @param imageList - List of Rich Media Image keys
 @param imageKey - Rich Media Key of first image to present
 */
-(void) showPhotos:(NSArray *) imageList currentPhoto:(NSString *) imageKey;

/** Presents a video using the SCVideoPlayerController component.
 
 @param videoKey - Rich Media Key of a video
 */
-(void) showVideo:(NSString *) videoKey;

/** Presents a location using the SCLocationViewerController component.
 
 @param locationKey - Rich Media Key of a location
 @param user - Name of the user in that location
 */
-(void) showLocation:(NSString *) locationKey forUser:(NSString *) user;

/** Presents a VoiceMail using the SCAudioPlayerController component.
 
 @param voiceMailKey - Rich Media Key of a VoiceMail
 */
-(void) showVoiceMail:(NSString *) voiceMailKey;

/** Presents a Document Preview using the SCDocumentViewerController component.
 
 @param documentKey - Rich Media Key of a Document
 */
-(void) showDocument:(NSString *) documentKey;

/** Presents a VCard using the SCPersonController component.
 
 @param vcard - Rich Media Key of a VCARD
 */
-(void) showContact:(NSString *) vcard;

/** @name Show Object Details */
/** Presents a Chat History using the SCChatController component.
 
 @param userid - Userid of a Friend
 */
-(void) showChatForUserid:(NSString *) userid;

/** Presents a Chat History using the SCChatController component.
 
 @param userid - Userid of a Friend
 @param startEdit - YES - Set the firstResponder to the Chat input to start edit
 */
-(void) showChatForUserid:(NSString *) userid startEdit:(BOOL)startEdit;

/** @name Show Object Details */
/** Presents a Chat History using the SCGroupChatController component.
 
 The group chat controller component shows the actual sender name on a message
 
 @param userid - Userid of a Friend
 */
-(void) showGroupChatForUserid:(NSString *) userid;

/** Presents a Chat History using the SCGroupChatController component.

 The group chat controller component shows the actual sender name on a message

 @param userid - Userid of a Friend
 @param startEdit - YES - Set the firstResponder to the Chat input to start edit
 */
-(void) showGroupChatForUserid:(NSString *) userid startEdit:(BOOL) startEdit;


/** Presents Group Details using the SCGroupDetailController component.
 
 @param groupid - Userid of a Group
 */
-(void) showGroupDetailForGroupid:(NSString *) groupid;

/** Presents Friend Details using the SCFriendDetailController component.
 
 @param userid - Userid of a Friend
 */
-(void) showFriendDetailForUserid:(NSString *) userid;

/** Presents the User Image as large image using the SCUserImageController component.
 
 @param userid - Userid of a Friend
 */
-(void) showUserImageForUserid:(NSString *) userid;


/** @name Open Browser View */
/** Presents a Browser View with URL and Title using SCBrowserViewController.
 
 @param url - URL to present
 @param browserTitle - Title of the Browser View
 */
-(void) openBrowserWithUrl:(NSString *) url andTitle:(NSString *) browserTitle;

/** @name Open Country Selection */
/** Present a Country Selection Controller for choosing country codes
 
 @param delegate - SCCountrySelectionDelegate
 */
-(void) showCountrySelectionWithDelegate:(id<SCCountrySelectionDelegate>) delegate;

/** @name Capture Rich Media Items */
/** Records a VoiceMail for submission using SCAudioRecorderController.
 
 @param completion - Completion Handler, will be called with the Rich Media Key of the recorded voicemail when done
 */
-(void) recordVoiceMail:(void (^)(NSString *key)) completion;

/** Picks a Location or nearby Google Places for submission using SCLocationSubmitController.
 
 @param completion - Completion Handler, will be called with the Rich Media Key of the location or place when done
 */
-(void) requestLocation:(void (^)(NSString *key)) completion;

/** Captures an Image from Album for submission using UIImagePickerController.
 
 @param quality - The requested Image Quality. If the original image has a higher resolution, it'll be scaled down automatically
 @param completion - Completion Handler, will be called with the Rich Media Key of the image when done
 */
-(void) captureImageFromAlbumWithQuality:(UIImagePickerControllerQualityType)quality andCompleteAction:(void (^)(NSString *key)) completion;

/** Captures an Image from Album for submission using UIImagePickerController.
 
 @param quality - The requested Image Quality. If the original image has a higher resolution, it'll be scaled down automatically
 @param completion - Completion Handler, will be called with the Rich Media Key of the image when done
 @param useEffects - Choose to applay a photo effect, after capturing the image
 */

-(void) captureImageFromAlbumWithQuality:(UIImagePickerControllerQualityType)quality andCompleteAction:(void (^)(NSString *key)) completion usingPhotoEffects:(SCPhotoEffects) useEffects;

/** Captures an Image from Camera for submission using UIImagePickerController.
 
 @param quality - The requested Image Quality to capture the image.
 @param completion - Completion Handler, will be called with the Rich Media Key of the image when done
 */
-(void) captureImageFromCameraWithQuality:(UIImagePickerControllerQualityType)quality andCompleteAction:(void (^)(NSString *key)) completion;

/** Captures an Image from Camera for submission using UIImagePickerController.
 
 @param quality - The requested Image Quality to capture the image.
 @param completion - Completion Handler, will be called with the Rich Media Key of the image when done
 @param useEffects - Choose to applay a photo effect, after capturing the image
 */
-(void) captureImageFromCameraWithQuality:(UIImagePickerControllerQualityType)quality andCompleteAction:(void (^)(NSString *key)) completion usingPhotoEffects:(SCPhotoEffects) useEffects;

/** Captures a Video from Album for submission using UIImagePickerController.
 
 @param quality - The requested Video Quality. If the original video has a higher resolution, it will be scaled down automatically
 @param completion - Completion Handler will be called with the Rich Media Key of the video when done
 */
-(void) captureVideoFromAlbumWithQuality:(UIImagePickerControllerQualityType)quality andCompleteAction:(void (^)(NSString *key)) completion;

/** Captures a Video from Camera for submission using UIImagePickerController.
 
 @param quality - The requested Video Quality to record the video.
 @param completion - Completion Handler, will be called with the Rich Media Key of the video when done
 */
-(void) captureVideoFromCameraWithQuality:(UIImagePickerControllerQualityType)quality andCompleteAction:(void (^)(NSString *key)) completion;


/** Captures an Image or Video from UIImagePickerController.
 
 This method gets you full control on the ImagePicker setup.
 
 @param imagePicker - The imagePicker to capture from
 @param completion - Completion Handler, will be called with the Rich Media Key of the video or image when done
 */
-(void) captureMediaFromImagePicker:(UIImagePickerController *) imagePicker andCompleteAction:(void (^)(NSString *key)) completion;

/** Captures an Image or Video from UIImagePickerController.
 
 This method gets you full control on the ImagePicker setup.
 
 @param imagePicker - The imagePicker to capture from
 @param completion - Completion Handler, will be called with the Rich Media Key of the video or image when done
 @param useEffects - Choose to applay a photo effect, after capturing the image
 */
-(void) captureMediaFromImagePicker:(UIImagePickerController *) imagePicker andCompleteAction:(void (^)(NSString *key)) completion usingPhotoEffects:(SCPhotoEffects) useEffects;

@end
