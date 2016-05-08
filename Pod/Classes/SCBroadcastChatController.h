//
//  SCBroadcastChatController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 08/05/16.
//
//

#import <UIKit/UIKit.h>

@class SCBroadcastController;

@interface SCBroadcastChatController : UIViewController

@property (weak, nonatomic) IBOutlet UIView                 *innerView;
@property (weak, nonatomic) IBOutlet UITextView             *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton               *submitButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *innerViewBottomContraint;

@property (weak, nonatomic) SCBroadcastController   *broadcast;

@property (nonatomic, strong) NSString *broadcastGroupId;


@end
