//
//  UDConnectionCell.h
//  C2CallPhone
//
//  Created by Michael Knecht on 06.05.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDConnectionCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIButton      *btnCallVoice, *btnCallVideo, *btnChat;

@end
