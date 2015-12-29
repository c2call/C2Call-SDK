//
//  SCAdListCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 10.05.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>

/** UITableViewCell subclass for SCOfferwallController AdList TableView.
 */
@interface SCAdListCell : UITableViewCell

/** @name Outlets */
/** Offer Title. */
@property(nonatomic, weak) IBOutlet UILabel           *labelTitle;

/** Offer Sub-Title. */
@property(nonatomic, weak) IBOutlet UILabel           *labelSubtitle;

/** Free Offer. */
@property(nonatomic, weak) IBOutlet UILabel           *labelFree;

/** Label Earn. */
@property(nonatomic, weak) IBOutlet UILabel           *labelEarn;

/** Label Offer Provider. */
@property(nonatomic, weak) IBOutlet UILabel           *labelProvider;

/** Offer Icon. */
@property(nonatomic, weak) IBOutlet UIImageView       *iconView;

/** Offer Type. */
@property(nonatomic, weak) IBOutlet UIImageView       *offerTypeImage;

/** Icon Loading Progress indicator */
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView     *activityView;

/** References to Offer. */
@property(nonatomic, strong) id                       currentAd;

@end
