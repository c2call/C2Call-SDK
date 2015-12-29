//
//  SCBubbleViewIn.h
//  C2CallPhone
//
//  Created by Michael Knecht on 20.03.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    SC_BUBBLE_IN_DEFAULT,
    SC_BUBBLE_IN_HANGOUT,
    SC_BUBBLE_IN_WHAZZUPP,
    SC_BUBBLE_IN_IOS7,
    SC_BUBBLE_IN_SIMPLE
} SCBubbleType_In;

/** This class renders the bubble for an inbound message in the SCBoardController.
 
 The bubble appearance can be influenced by iOS Appearance API. The current appearance options are influencing the blubble shape and the color.
 
 Currently the following bubble shapes are supported:
 
    - SC_BUBBLE_IN_DEFAULT : Standard bubble similar to the bubble shape used by Facebook iOS app
    - SC_BUBBLE_IN_HANGOUT : Bubble Shape similar to Google Hangout iOS App
    - SC_BUBBLE_IN_WHAZZUPP : Bubble Shape similar to a popular messenger
    - SC_BUBBLE_IN_IOS7 : iOS7 style bubble
 
 In order to set the base color or the bubble style, you can use UIAppearance API as follows:
 
    // Just do this once in your applicationDidFinishLaunching:withOptions:
    [[SCBubbleViewIn appearance] setBaseColor:[UIColor colorWithRed: 1 green: 0 blue: 0.434 alpha: 0.69]];
    [[SCBubbleViewIn appearance] setBubbleTypeIn:SC_BUBBLE_IN_IOS7];
 
 
 */
@interface SCBubbleViewIn : UIView

/** Base Color of the bubble
 */
@property(nonatomic, strong) UIColor        *baseColor UI_APPEARANCE_SELECTOR;

/** Chat Text of the bubble
 */
@property(nonatomic, strong) NSString       *chatText;

/** Text Font for Chat Text
 */
@property(nonatomic, strong) UIFont         *textFont UI_APPEARANCE_SELECTOR;

/** Text Color for Chat Text
 */
@property(nonatomic, strong) UIColor        *textColor UI_APPEARANCE_SELECTOR;

/** Draw the text with offset from top
 */
@property(nonatomic, strong) NSNumber       *textOffsetTop;

/** Bubble Style
 
 Available options:
    - SC_BUBBLE_IN_DEFAULT : Standard bubble similar to the bubble shape used by Facebook iOS app
    - SC_BUBBLE_IN_HANGOUT : Bubble Shape similar to Google Hangout iOS App
    - SC_BUBBLE_IN_WHAZZUPP : Bubble Shape similar to a popular messenger
    - SC_BUBBLE_IN_IOS7 : iOS7 style bubble
 
 */
@property(nonatomic) SCBubbleType_In        bubbleTypeIn UI_APPEARANCE_SELECTOR;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint      *left;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint      *top;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint      *width;

/** TextRect within the BubbleView
 
 @return The text rectangle
 */
-(CGRect) textRect;

+(CGRect) insetForBubbleType:(SCBubbleType_In) aBubbleType;

@end
