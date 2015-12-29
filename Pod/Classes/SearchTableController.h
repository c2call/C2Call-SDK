//
//  SearchTableController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 7/11/11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchTableCell;

@interface SearchTableController : UITableViewController {
    BOOL                hasRecent;
}

@property(nonatomic, strong) NSArray     *addressBook, *resultSet;
@property(nonatomic, strong) NSArray     *recentList;
@property(nonatomic, strong) IBOutlet SearchTableCell         *searchTableCell;

-(BOOL) setFilter:(NSString *) filterText;
-(void) initRecentList;
-(void) initAddressbook;

@end
