//
//  SCAbstractGroupVideoController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 19.03.17.
//
//

#import <UIKit/UIKit.h>
#import "SocialCommunication.h"

@class EAGLViewController;

@interface SCAbstractGroupVideoController : UIViewController<VideoHandlerDelegate>

/** Current active Video ViewControllers */
@property(atomic, strong) NSMutableArray<EAGLViewController *>      *eaglController;

/** The own camera view. */
@property(nonatomic, weak) IBOutlet UIView                *previewView;

/** @name Other Methods */
/** Start Video Player. */
-(void) start;
-(void) dispose;

-(void) layoutVideoViews;
-(void) decodeLoopForEAGLController:(EAGLViewController *) eaglc;
-(void) willAddEAGLViewController:(EAGLViewController *) eaglc;
-(void) didAddEAGLViewController:(EAGLViewController *) eaglc;
-(void) willRemoveEAGLViewController:(EAGLViewController *) eaglc;
-(void) didRemoveEAGLViewController:(EAGLViewController *) eaglc;

-(void) deviceOrientationDidChange:(NSNotification *) notification;
-(void) applicationWillResignActive:(NSNotification *) notification;
-(void) applicationDidBecomeActive:(NSNotification *) notification;
-(void) connectionInfo:(NSNotification *) notification;

@end
