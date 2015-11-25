//
//  FriendCellIn.h
//  C2CallPhone
//
//  Created by Michael Knecht on 24.04.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import "MessageCell.h"

@interface FriendCellIn : MessageCell

@property(nonatomic, weak) IBOutlet UILabel       *confirmedLabel;

-(void) setFriend:(NSString *) key;
-(IBAction)addFriend:(id)sender;

@end
