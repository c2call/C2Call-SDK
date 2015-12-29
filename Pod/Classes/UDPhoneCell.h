//
//  UDPhoneCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.05.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDPhoneCell : UITableViewCell


@property(nonatomic, weak) IBOutlet UILabel		*numberType, *number, *priceInfo;
@property(nonatomic, weak) IBOutlet UITextField   *editNumber;
@property(nonatomic, weak) IBOutlet UIButton		*smsButton;
@property(nonatomic, strong) NSString               *queryNumber;

-(void) queryPriceForNumber:(NSString *) _number;

@end
