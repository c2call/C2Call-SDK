//
//  CallCellOutStream.h
//  C2CallPhone
//
//  Created by Michael Knecht on 31.05.12.
//  Copyright (c) 2012 C2Call GmbH. All rights reserved.
//

#import "CallCellOut.h"

@class C2ActionButton;

@interface CallCellOutStream : CallCellOut

@property(nonatomic, weak) IBOutlet C2ActionButton *btnCall, *btnVideoCall, *btnChat;
@property(nonatomic, weak) IBOutlet UIImageView   *iconCallStatus;

@end
