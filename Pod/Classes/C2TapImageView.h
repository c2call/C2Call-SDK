//
//  UITapImageView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 28.04.12.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Implements an UIImageView subclass with support for tap and long press gesture.
 
 The C2TabImageView has usually round corners with corner radius 5 and has also support for a badge label.
 
 */
@interface C2TapImageView : UIImageView

/** @name Properties */
/** Corner Radius of the image view. */
@property(nonatomic) CGFloat    cornerRadius;

/** Badge Value. */
@property(nonatomic, strong) NSString   *badgeValue;

/** @name Other Methods */

/** Sets the Tap-Action Block.
 
 @param tapAction - The Tap Action
 */
-(void) setTapAction:(void (^)()) tapAction;

/** Sets the Longpress-Action Block.
 
 @param longpressAction - The Longpress Action
 */
-(void) setLongpressAction:(void (^)()) longpressAction;

/** Releases all Action Blocks.
 */
-(void) dispose;

@end
