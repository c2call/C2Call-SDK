//
//  SCHorizontalLineView.h
//  C2CallPhone
//
//  Created by Michael Knecht on 12.10.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    SCHorizontalLinePositionTop,
    SCHorizontalLinePositionCenter,
    SCHorizontalLinePositionBottom
} SCHorizontalLinePosition;

@interface SCHorizontalLineView : UIView

@property(nonatomic, strong) UIColor *lineColor; UI_APPEARANCE_SELECTOR;
@property(nonatomic) CGFloat lineWidth; UI_APPEARANCE_SELECTOR;
@property(nonatomic) SCHorizontalLinePosition  linePosition; UI_APPEARANCE_SELECTOR;

@end
