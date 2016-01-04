//
//  VCCallHistoryController.h
//  SDK-VideoChat Sample
//
//  Created by Michael Knecht on 20.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>


@interface VCCallHistoryCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *textLabel, *timeLabel, *missedEvents;
@property(nonatomic, weak) IBOutlet UIImageView *userImage;

@end

@interface VCCallHistoryController : SCDataTableViewController

-(IBAction)toggleEditing:(id)sender;

@end
