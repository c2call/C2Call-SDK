//
//  SCFlatButton.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.10.13.
//
//

#import <UIKit/UIKit.h>

@interface SCFlatButton : UIButton

@property(nonatomic, strong) UIColor    *borderColor UI_APPEARANCE_SELECTOR;
@property(nonatomic) CGFloat            borderWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic) CGFloat            cornerRadius UI_APPEARANCE_SELECTOR;

@end
