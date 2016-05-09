//
//  SCIntrinsicTableView.m
//  C2CallPhone
//
//  Created by Michael Knecht on 09/05/16.
//
//

#import "SCIntrinsicTableView.h"

@implementation SCIntrinsicTableView

- (CGSize)intrinsicContentSize {
    //[self layoutIfNeeded]; // force my contentSize to be updated immediately
    return CGSizeMake(UIViewNoIntrinsicMetric, self.contentSize.height);
}

-(void) endUpdates
{
    [super endUpdates];
    
    [self invalidateIntrinsicContentSize];
}

-(void) reloadData
{
    [super reloadData];
    
    [self invalidateIntrinsicContentSize];
}

@end
