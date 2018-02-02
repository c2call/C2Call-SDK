//
//  SCFriendsDataSource.m
//  C2CallPhone
//
//  Created by Michael Knecht on 01.01.18.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

#import "SCFriendsDataSource.h"
#import "MOC2CallUser.h"
#import "SocialCommunication.h"
#import "SCAssetManager.h"
#import "C2CallConstants.h"


@interface SCUserObject()

@property (nonatomic, weak, nullable) MOC2CallUser    *user;

@end

@implementation SCUserObject

-(instancetype) initWithUser:(MOC2CallUser *)user
{
    self = [super init];
    if (self) {
        _user = user;
        
        _displayName = [user.displayName copy];
        _userid = [user.userid copy];
        _firstName = [user.firstname copy];
        _lastName = [user.name copy];
        _userid = [user.userid copy];
        _userType = [user.userType integerValue];
        _userImage = [self userimageForUser:_userid withType:_userType];
        
        _isGroup = _userType == 2;
        _isBroadcast = _userType == 4;
        _isFriend = YES;
    }
    return self;
}

-(UIImage *) userimageForUser:(NSString *) userid withType:(NSUInteger) userType
{
 
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:_userid];
    if (image) {
        return image;
    }
    
    if (userType == 2) {
        image = [[SCAssetManager instance] imageForName:@"btn_ico_avatar_group"];
        return image;
    }
    
    image = [[SCAssetManager instance] imageForName:@"btn_ico_avatar"];
    return image;
}

-(NSUInteger) onlineStatus
{
    return [self.user.onlineStatus integerValue];
}

-(MOC2CallUser *) user {
    if (!_user) {
        _user = [[SCDataManager instance] userForUserid:_userid];
    }
    
    return _user;
}

- (NSUInteger)hash
{
    return [_userid hash];
}

- (NSComparisonResult)compare:(SCUserObject *)other
{
    if ([_userid isEqualToString:other.userid]) {
        return NSOrderedSame;
    }
    
    return [_displayName compare:other.displayName];
}

-(NSString *) indexTitle
{
    if ([self.displayName length] > 0) {
        return [self.displayName substringToIndex:1];
    }
    
    if ([self.firstName length] > 0) {
        return [self.firstName substringToIndex:1];
    }

    if ([self.lastName length] > 0) {
        return [self.lastName substringToIndex:1];
    }

    return @"#";
}

@end

@interface SCFriendsDataSource() <NSFetchedResultsControllerDelegate> {
    NSString *contentMutex;
    
    
}

@property(strong, nonatomic) id observer;

@property(strong, nonatomic) NSMutableArray<SCUserObject *> *allUserObjects;
@property(strong, nonatomic) NSMutableArray<SCUserObject *> *recentUserObjects;
@property(strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray<SCUserObject *> *> *segmentedUserObjects;
@property(strong, nonatomic) NSMutableArray<NSString *>    *selectedUsers;

// Handle Search
@property(strong, nonatomic) NSArray<SCUserObject *> *searchUserObjects;
@property(strong, nonatomic) NSArray<SCUserObject *> *searchResultUserObjects;
@property(nonatomic) BOOL                            searchEnabled;


@property(strong, nonatomic) NSDate                         *compareDate;

@end

@implementation SCFriendsDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        contentMutex = @"MUTEX";
        
        _showFriends = YES;
        _showGroups = YES;
        _showBroadcasts = NO;
        _showMeetings = NO;
        _showOnlineOnly = NO;
        _showRecent = YES;
        _useAlphabethicalIndex = YES;
        
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setWeekOfYear:-2];
        self.compareDate = [cal dateByAddingComponents:offsetComponents toDate:today options:0];
        self.selectedUsers = [NSMutableArray array];
    }
    return self;
}

-(NSFetchRequest *) fetchRequestAllFriends;
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    BOOL sortByFirstName = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_SORTBYFIRSTNAME];

    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForFriendlist:sortByFirstName];
    
    NSPredicate *originalPredicate = fetchRequest.predicate;

    NSMutableArray<NSPredicate *> *andPredicates = [NSMutableArray arrayWithCapacity:5];
    
    if (originalPredicate) {
        [andPredicates addObject:originalPredicate];
    }
    
    if (self.showOnlineOnly) {
        [andPredicates addObject:[NSPredicate predicateWithFormat:@"online = YES"]];
    }
    
    if (!self.showMeetings) {
        NSPredicate *meetingFilter = [NSPredicate predicateWithFormat:@"SUBQUERY(userdata, $sub, $sub.key like 'BRMeetingStart').@count == 0"];
        [andPredicates addObject:meetingFilter];
    }
    
    // User Types
    NSMutableArray<NSPredicate *> *userTypes = [NSMutableArray arrayWithCapacity:5];
    if (self.showFriends) {
        [userTypes addObject:[NSPredicate predicateWithFormat:@"userType == 0"]];
    }
    if (self.showGroups) {
        [userTypes addObject:[NSPredicate predicateWithFormat:@"userType == 2"]];
    }
    if (self.showBroadcasts) {
        [userTypes addObject:[NSPredicate predicateWithFormat:@"userType == 4"]];
    }

    if ([userTypes count] > 0) {
        NSCompoundPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:userTypes];
        [andPredicates addObject:orPredicate];
    }
    
    if ([andPredicates count] > 0) {
        NSCompoundPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:andPredicates];
        [fetchRequest setPredicate:cp];
    }
    return fetchRequest;
}

-(NSFetchRequest *) fetchRequestRecentFriends;
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;


    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForFriendlist:NO];
    
    NSPredicate *originalPredicate = fetchRequest.predicate;
    NSPredicate *p = [NSPredicate predicateWithFormat:@"lastActivity >= %@ or recentIndicationDate >= %@", self.compareDate, self.compareDate];

    NSMutableArray<NSPredicate *> *andPredicates = [NSMutableArray arrayWithCapacity:5];

    if (originalPredicate) {
        [andPredicates addObject:originalPredicate];
    }
    
    [andPredicates addObject:p];
    
    if (self.showOnlineOnly) {
        [andPredicates addObject:[NSPredicate predicateWithFormat:@"online = YES"]];
    }
    
    if (!self.showMeetings) {
        NSPredicate *meetingFilter = [NSPredicate predicateWithFormat:@"SUBQUERY(userdata, $sub, $sub.key like 'BRMeetingStart').@count == 0"];
        [andPredicates addObject:meetingFilter];
    }

    // User Types
    NSMutableArray<NSPredicate *> *userTypes = [NSMutableArray arrayWithCapacity:5];
    if (self.showFriends) {
        [userTypes addObject:[NSPredicate predicateWithFormat:@"userType == 0"]];
    }
    if (self.showGroups) {
        [userTypes addObject:[NSPredicate predicateWithFormat:@"userType == 2"]];
    }
    if (self.showBroadcasts) {
        [userTypes addObject:[NSPredicate predicateWithFormat:@"userType == 4"]];
    }
    
    if ([userTypes count] > 0) {
        NSCompoundPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:userTypes];
        [andPredicates addObject:orPredicate];
    }

    if ([andPredicates count] > 0) {
        NSCompoundPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:andPredicates];
        [fetchRequest setPredicate:cp];
    }
    
    NSSortDescriptor *sortLastActivity = [[NSSortDescriptor alloc] initWithKey:@"lastActivity" ascending:NO];
    NSSortDescriptor *sortFirstname = [[NSSortDescriptor alloc] initWithKey:@"firstname" ascending:YES];
    NSSortDescriptor *sortLastname = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortEMail = [[NSSortDescriptor alloc] initWithKey:@"email" ascending:YES];

    BOOL sortByFirstName = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_SORTBYFIRSTNAME];
    
    NSArray *sortDescriptors = nil;
    if (sortByFirstName) {
        sortDescriptors = [NSArray arrayWithObjects:sortLastActivity, sortFirstname, sortLastname, sortEMail, nil];
    } else {
        sortDescriptors = [NSArray arrayWithObjects:sortLastActivity, sortLastname, sortFirstname, sortEMail, nil];
    }

    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return fetchRequest;
}


-(void) setupFetchControllerAllFriends;
{
    NSFetchRequest *fetchRequest = [self fetchRequestAllFriends];
    
    if (!fetchRequest)
        return;
    
    @try {
        NSFetchedResultsController *aFetchedResultsController = [[SCDataManager instance] fetchedResultsControllerWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
        
        if (!aFetchedResultsController)
            return;
        
        
        if (self.fetchedResultsAllFriends) {
            self.fetchedResultsAllFriends.delegate = nil;
            self.fetchedResultsAllFriends = nil;
        }
        self.fetchedResultsAllFriends = aFetchedResultsController;
        
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![self.fetchedResultsAllFriends performFetch:&error]) {
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return;
        }
        
        
    }
    @catch (NSException *exception) {
        DLog(@"Exeption : %@", exception);
    }
    
}

-(void) setupFetchControllerRecentFriends;
{
    NSFetchRequest *fetchRequest = [self fetchRequestRecentFriends];
    
    if (!fetchRequest)
        return;
    
    @try {
        NSFetchedResultsController *aFetchedResultsController = [[SCDataManager instance] fetchedResultsControllerWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
        
        if (!aFetchedResultsController)
            return;
        
        
        if (self.fetchedResultsRecentFriends) {
            self.fetchedResultsRecentFriends.delegate = nil;
            self.fetchedResultsRecentFriends = nil;
        }
        self.fetchedResultsRecentFriends = aFetchedResultsController;
        
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![self.fetchedResultsRecentFriends performFetch:&error]) {
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return;
        }
        
        
    }
    @catch (NSException *exception) {
        DLog(@"Exeption : %@", exception);
    }
    
}

-(void) setupFetchedResultsController
{
    [self setupFetchControllerAllFriends];
    [self setupFetchControllerRecentFriends];
}

-(void) prepareFriendsList  {
    
    NSArray *fetchedFriends = [self.fetchedResultsAllFriends fetchedObjects];
    NSArray *recentFriends = [self.fetchedResultsRecentFriends fetchedObjects];
    NSMutableArray<SCUserObject*> *friendslist = [NSMutableArray arrayWithCapacity:[fetchedFriends count] +1];
    NSMutableArray<SCUserObject*> *recentlist = [NSMutableArray arrayWithCapacity:[recentFriends count] +1];

    NSMutableDictionary<NSString *, NSMutableArray<SCUserObject *> *> *segments = [NSMutableDictionary dictionaryWithCapacity:30];
    
    
    for (MOC2CallUser *user in recentFriends) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        [recentlist addObject:userObject];
    }

    if ([recentlist count] > 0) {
        segments[@"Recent Friends"] = recentlist;
    }
    
    NSMutableArray *indexTitles = [NSMutableArray array];
    for (MOC2CallUser *user in fetchedFriends) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        [friendslist addObject:userObject];
        
        NSString *indexTitle = [userObject indexTitle];
        NSMutableArray *list = segments[indexTitle];
        if (!list) {
            list = [NSMutableArray array];
            segments[indexTitle] = list;
            [indexTitles addObject:indexTitle];
        }
        [list addObject:userObject];
    }
    
    [indexTitles sortUsingComparator:^NSComparisonResult(NSString    *obj1, NSString   *obj2) {
        return [obj1 compare:obj2];
    }];
    
    if ([recentlist count] > 0) {
        [indexTitles insertObject:@"Recent Friends" atIndex:0];
    }
    
    @synchronized(contentMutex) {
        self.allUserObjects = friendslist;
        self.recentUserObjects = recentlist;
        self.segmentedUserObjects = segments;
        self.sectionIndexTitle = indexTitles;
    }
    
    if ([NSThread isMainThread]) {
        [self.delegate dataSourceDidReloadContent];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate dataSourceDidReloadContent];
        });
    }

}


- (void)dealloc
{
    if (self.observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        self.observer = nil;
    }
}

-(void) layzInitialize {
    
    __weak SCFriendsDataSource *weakself = self;
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"C2CallDataManager:initData" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (!weakself.fetchedResultsAllFriends) {
            [weakself setupFetchedResultsController];
            [weakself prepareFriendsList];
        }
    }];
    
    if ([SCDataManager instance].isDataInitialized) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        self.observer = nil;
        
        [self setupFetchedResultsController];
        [self prepareFriendsList];
        return;
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
{
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            if (!self.searchEnabled) {
                [self.delegate dataSourceWillChangeContent:self];
            }
            
            if ([controller isEqual:self.fetchedResultsAllFriends]) {
                [self insertAllUser:anObject atIndexPath:newIndexPath];
            } else {
                [self insertRecentUser:anObject atIndexPath:newIndexPath];
            }
            if (!self.searchEnabled) {
                [self.delegate dataSourceDidChangeContent:self];
            }
            break;
            
        case NSFetchedResultsChangeDelete:
            if (!self.searchEnabled) {
                [self.delegate dataSourceWillChangeContent:self];
            }
            if ([controller isEqual:self.fetchedResultsAllFriends]) {
                [self deleteAllUser:anObject atIndexPath:newIndexPath];
            } else {
                [self deleteRecentUser:anObject atIndexPath:newIndexPath];
            }
            if (!self.searchEnabled) {
                [self.delegate dataSourceDidChangeContent:self];
            }
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([controller isEqual:self.fetchedResultsAllFriends]) {
                [self updateAllUser:anObject atIndexPath:newIndexPath];
            } else {
                [self updateRecentUser:anObject atIndexPath:newIndexPath];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            if (!self.searchEnabled) {
                [self.delegate dataSourceWillChangeContent:self];
            }
            //[self moveEvent:anObject fromIndexPath:indexPath to:newIndexPath];

            if (!self.searchEnabled) {
                [self.delegate dataSourceDidChangeContent:self];
            }
            break;
    }
    
}

-(void) addSectionIndexTitle:(NSString *) indexTitle
{
    NSMutableArray *indexTitles = [self.sectionIndexTitle copy];
    [indexTitles addObject:indexTitle];
    
    [indexTitles removeObjectAtIndex:0];

    [indexTitles sortUsingComparator:^NSComparisonResult(NSString    *obj1, NSString   *obj2) {
        return [obj1 compare:obj2];
    }];
    [indexTitles insertObject:@"Recent Friends" atIndex:0];

    self.sectionIndexTitle = indexTitles;
}

-(NSIndexPath *) indexPathForAllUser:(SCUserObject *) userObject
{
    NSString *indexTitle = userObject.indexTitle;
    NSMutableArray *list = self.segmentedUserObjects[indexTitle];
    
    if (!list) {
        return nil;
    }
    
    NSInteger section = [self.sectionIndexTitle indexOfObject:indexTitle];
    if (section == NSNotFound) {
        return nil;
    }
    
    NSInteger row = [list indexOfObject:userObject];
    if (row == NSNotFound) {
        return nil;
    }
    
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:row inSection:section];
    return idxPath;
}

-(void) insertAllUser:(MOC2CallUser *) user atIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        if (![self.allUserObjects containsObject:userObject]) {
            [self.allUserObjects addObject:userObject];
            
            NSString *indexTitle = userObject.indexTitle;
            NSMutableArray *list = self.segmentedUserObjects[indexTitle];
            
            BOOL addSection = NO;
            if (!list) {
                list = [NSMutableArray array];
                self.segmentedUserObjects[indexTitle] = list;

                [self addSectionIndexTitle:indexTitle];
                addSection = YES;
            }
            
            NSInteger foundIdx = -1;
            for (int i = 0; i < [list count]; i++) {
                SCUserObject *tmpUser = list[i];
                
                if ([userObject compare:tmpUser] == NSOrderedAscending) {
                    [list insertObject:userObject atIndex:i];
                    foundIdx = i;
                    break;
                }
            }
            
            if (foundIdx == -1) {
                [list addObject:userObject];
                foundIdx = [list count] - 1;
            }
            
            NSInteger section = [self.sectionIndexTitle indexOfObject:indexTitle];
            
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:foundIdx inSection:section];
            DLog(@"Insert User: %@ at %@ / %@", userObject.displayName, @(section), @(foundIdx));

            if (addSection) {
                if (!self.searchEnabled) {
                    [self.delegate dataSource:self didChangeSection:indexTitle atIndex:section forChangeType:SCDataSourceChangeInsert];
                }
            }
            if (!self.searchEnabled) {
                [self.delegate dataSource:self didChangeObject:userObject atIndexPath:nil forChangeType:SCDataSourceChangeInsert newIndexPath:idxPath];
            }
            
        }
        
    }
}

-(void) deleteAllUser:(MOC2CallUser *) user atIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        if (![self.allUserObjects containsObject:userObject]) {
            return;
        }
        
        NSIndexPath *idxPath = [self indexPathForAllUser:userObject];
        
        if (!idxPath) {
            return;
        }
        
        [self.allUserObjects removeObject:userObject];

        NSString *indexTitle = userObject.indexTitle;
        NSMutableArray *list = self.segmentedUserObjects[indexTitle];
        [list removeObject:userObject];

        BOOL removeSection = NO;
        if ([list count] == 0) {
            NSMutableArray *tmp = [self.sectionIndexTitle mutableCopy];
            [tmp removeObject:indexTitle];
            self.sectionIndexTitle = tmp;
            removeSection = YES;
            
            [self.segmentedUserObjects removeObjectForKey:indexTitle];
        }
        
        DLog(@"RemoveUser: %@ at %@ / %@", userObject.displayName, @(idxPath.section), @(idxPath.row));
        
        if (!self.searchEnabled) {
            [self.delegate dataSource:self didChangeObject:userObject atIndexPath:idxPath forChangeType:SCDataSourceChangeeDelete newIndexPath:nil];
        }
        
        if (removeSection) {
            if (!self.searchEnabled) {
                [self.delegate dataSource:self didChangeSection:indexTitle atIndex:idxPath.section forChangeType:SCDataSourceChangeeDelete];
            }
        }

    }
}


-(void) updateAllUser:(MOC2CallUser *) user atIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        
        NSIndexPath *idxPath = [self indexPathForAllUser:userObject];
        if (!idxPath) {
            return;
        }

        NSString *indxTitle = userObject.indexTitle;
        NSMutableArray *list = self.segmentedUserObjects[indxTitle];
        
        [list removeObjectAtIndex:idxPath.row];
        [list insertObject:userObject atIndex:idxPath.row];
        
        if (!self.searchEnabled) {
            [self.delegate dataSource:self didChangeObject:userObject atIndexPath:idxPath forChangeType:SCDataSourceChangeUpdate newIndexPath:nil];
        }
    }
}

-(void) insertRecentUser:(MOC2CallUser *) user atIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        
        BOOL addSection = NO;
        if ([self.recentUserObjects count] == 0) {
            addSection = YES;
        }
        
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        
        if ([self.recentUserObjects containsObject:userObject]) {
            return;
        }
        
        NSInteger foundIdx = -1;
        for (int i = 0; i < [self.recentUserObjects count]; i++) {
            SCUserObject *tmpUser = self.recentUserObjects[i];
            
            if ([userObject compare:tmpUser] == NSOrderedAscending) {
                [self.recentUserObjects insertObject:userObject atIndex:i];
                foundIdx = i;
                break;
            }
        }
        
        if (foundIdx == -1) {
            [self.recentUserObjects addObject:userObject];
            foundIdx = [self.recentUserObjects count] - 1;
        }
        
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:foundIdx inSection:0];
        
        if (addSection) {
            NSMutableArray *idxlist = [self.sectionIndexTitle mutableCopy];
            [idxlist insertObject:@"Recent Friends" atIndex:0];
            self.sectionIndexTitle = idxlist;
            if (!self.searchEnabled) {
                [self.delegate dataSource:self didChangeSection:@"Recent Friends" atIndex:0 forChangeType:SCDataSourceChangeInsert];
            }
        }

        if (!self.searchEnabled) {
            [self.delegate dataSource:self didChangeObject:userObject atIndexPath:nil forChangeType:SCDataSourceChangeInsert newIndexPath:idxPath];
        }
        
    }
}

-(void) deleteRecentUser:(MOC2CallUser *) user atIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];

        NSInteger idx = [self.recentUserObjects indexOfObject:userObject];
        
        if (idx == NSNotFound) {
            return;
        }

        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        [self.recentUserObjects removeObjectAtIndex:idx];
        
        BOOL removeSection = NO;
        if ([self.recentUserObjects count] == 0) {
            removeSection = YES;
            NSMutableArray *idxlist = [self.sectionIndexTitle mutableCopy];
            [idxlist removeObjectAtIndex:0];
            self.sectionIndexTitle = idxlist;
            
            [self.segmentedUserObjects removeObjectForKey:@"Recent Friends"];
        }
        
        if (!self.searchEnabled) {
            [self.delegate dataSource:self didChangeObject:userObject atIndexPath:idxPath forChangeType:SCDataSourceChangeeDelete newIndexPath:nil];
        }
        
        if (removeSection) {
            if (!self.searchEnabled) {
                [self.delegate dataSource:self didChangeSection:@"Recent Friends" atIndex:0 forChangeType:SCDataSourceChangeeDelete];
            }
        }
    }
}

-(void) updateRecentUser:(MOC2CallUser *) user atIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        SCUserObject *userObject = [[SCUserObject alloc] initWithUser:user];
        
        NSInteger idx = [self.recentUserObjects indexOfObject:userObject];
        
        if (idx == NSNotFound) {
            return;
        }
        
        [self.recentUserObjects removeObjectAtIndex:idx];
        [self.recentUserObjects insertObject:userObject atIndex:idx];
        
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
        if (!self.searchEnabled) {
            [self.delegate dataSource:self didChangeObject:userObject atIndexPath:idxPath forChangeType:SCDataSourceChangeUpdate newIndexPath:nil];
        }

    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
{
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    //[self.delegate dataSourceWillChangeContent:self];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    //[self.delegate dataSourceDidChangeContent:self];
}

-(void) refetchResults
{
    NSError *error = nil;
    [self.fetchedResultsAllFriends performFetch:&error];
    if (error) {
        DLog(@"Error : %@", error);
    }
    [self.fetchedResultsRecentFriends performFetch:&error];
    if (error) {
        DLog(@"Error : %@", error);
    }
    [self prepareFriendsList];
}

-(void) reinitFetchResultsController
{
    [self setupFetchedResultsController];
    [self prepareFriendsList];
}

- (NSInteger) numberOfSections;
{
    if (self.searchEnabled) {
        return 1;
    }
    
    @synchronized(contentMutex) {
        return [self.segmentedUserObjects count];
    }
}


- (NSInteger) numberOfRowsInSection:(NSInteger)section;
{
    if (self.searchEnabled) {
        if ([self.searchResultUserObjects count] > 0) {
            return [self.searchResultUserObjects count];
        }
        
        return [self.searchUserObjects count];
    }
    
    @synchronized(contentMutex) {
        if ([self.sectionIndexTitle count] > section) {
            NSString *sectionIndex = self.sectionIndexTitle[section];
            return [self.segmentedUserObjects[sectionIndex] count];
        }
        
        return 0;
    }
}

-(NSString *) titleForHeaderInSection:(NSInteger) section
{
    if (self.searchEnabled) {
        return nil;
    }
    
    @synchronized(contentMutex) {
        if ([self.sectionIndexTitle count] > section) {
            return self.sectionIndexTitle[section];
        }
        
        return nil;
    }

}

-(nullable SCUserObject *) userObjectAtIndexPath:(nonnull NSIndexPath *) indexPath;
{
    
    if (self.searchEnabled) {
        if ([self.searchResultUserObjects count] > 0) {
            return [self.searchResultUserObjects objectAtIndex:indexPath.row];
        }

        return [self.searchUserObjects objectAtIndex:indexPath.row];
    }
    
    @synchronized(contentMutex) {
        if ([self.sectionIndexTitle count] > indexPath.section) {
            NSString *sectionIndex = self.sectionIndexTitle[indexPath.section];
            NSArray *list = self.segmentedUserObjects[sectionIndex];
            
            if ([list count] > indexPath.row) {
                return list[indexPath.row];
            }
        }

        return nil;
    }
}

-(NSArray<SCUserObject *> *_Nullable) allFriends;
{
    @synchronized(contentMutex) {
        return [self.allUserObjects copy];
    }
}

-(NSArray<SCUserObject *> *_Nullable) recentFriends;
{
    @synchronized(contentMutex) {
        return [self.recentUserObjects copy];
    }
}

#pragma mark User Selection

-(void) selectUser:(SCUserObject *_Nonnull) userObject;
{
    if (![self isUserSelected:userObject]) {
        [self.selectedUsers addObject:userObject.userid];
    }
}
-(void) deselectUser:(SCUserObject *_Nonnull) userObject;
{
    [self.selectedUsers removeObject:userObject.userid];
}

-(BOOL) isUserSelected:(SCUserObject *_Nonnull) userObject;
{
    return [self.selectedUsers containsObject:userObject.userid];
}

-(NSArray<SCUserObject *> *_Nullable) selectedUserList;
{
    NSMutableArray<SCUserObject *> *userlist = [NSMutableArray array];
    
    NSArray<SCUserObject *> *all = [self allFriends];
    for (SCUserObject *userObject in all) {
        if ([self.selectedUsers containsObject:userObject.userid]) {
            [userlist addObject:userObject];
        }
    }
    return userlist;
}


#pragma mark Search Delegate

-(void) beginSearch
{
    if (self.searchEnabled) {
        return;
    }
    
    self.searchUserObjects = [self allFriends];
    self.searchResultUserObjects = nil;
    self.searchEnabled = YES;
    
    [self.delegate dataSourceDidReloadContent];
}

-(void) endSearch
{
    if (!self.searchEnabled) {
        return;
    }
    
    self.searchEnabled = NO;
    [self.delegate dataSourceDidReloadContent];
}

-(void) searchFilterForText:(NSString *) filterText
{
    if ([filterText length] == 0) {
        self.searchResultUserObjects = nil;
        [self.delegate dataSourceDidReloadContent];
        return;
    }
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF.displayName contains[cd] %@", filterText];
    
    NSArray *result = [self.searchUserObjects filteredArrayUsingPredicate:p];
    self.searchResultUserObjects = result;
    [self.delegate dataSourceDidReloadContent];
}

-(void) setShowOnlineOnly:(BOOL)showOnlineOnly
{
    _showOnlineOnly = showOnlineOnly;
    [self reinitFetchResultsController];
}

-(void) setShowFriends:(BOOL)showFriends
{
    _showFriends = showFriends;
    [self reinitFetchResultsController];
}

-(void) setShowGroups:(BOOL)showGroups
{
    _showGroups = showGroups;
    [self reinitFetchResultsController];
}
@end
