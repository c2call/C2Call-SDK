//
//  EditCellController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 19.01.09.
//  Copyright 2009 Actai Networks GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditCell : UITableViewCell {
}

@property(nonatomic, weak) IBOutlet UILabel		*label;
@property(nonatomic, weak) IBOutlet UITextField	*textContent;
@property BOOL										canSelect;

-(IBAction)nextResponder:(id)sender;

@end
