//
//  SCFriendsDataSource.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.01.18.
//

#import <Foundation/Foundation.h>

#import "SCDataSource.h"

@class MOC2CallUser, NSFetchedResultsController;

@interface SCUserObject : NSObject

@property (nonatomic, strong, nullable) NSString    *displayName;
@property (nonatomic, strong, nullable) NSString    *userid;
@property (nonatomic, strong, nullable) NSString    *lastName;
@property (nonatomic, strong, nullable) NSString    *firstName;
@property (nonatomic, strong, nullable) UIImage     *userImage;
@property (nonatomic) NSUInteger                    userType;
@property (nonatomic, readonly) NSUInteger          onlineStatus;

@property (nonatomic) BOOL                    isGroup;
@property (nonatomic) BOOL                    isBroadcast;
@property (nonatomic) BOOL                    isMeeting;
@property (nonatomic) BOOL                    isFriend;

@property (nonatomic, weak, readonly, nullable) MOC2CallUser    *user;

-(instancetype _Nullable) initWithUser:(MOC2CallUser *_Nonnull) user;

-(UIImage *_Nullable) userimageForUser:(NSString *_Nonnull) userid withType:(NSUInteger) userType;

-(NSString *_Nonnull) indexTitle;

@end


@interface SCFriendsDataSource : NSObject

@property(weak, nonatomic, nullable) id<SCDataSourceDelegate>  delegate;

@property(nonatomic) BOOL showFriends;
@property(nonatomic) BOOL showGroups;
@property(nonatomic) BOOL showBroadcasts;
@property(nonatomic) BOOL showOnlineOnly;
@property(nonatomic) BOOL showMeetings;
@property(nonatomic) BOOL showRecent;
@property(nonatomic) BOOL useAlphabethicalIndex;

@property(strong, nonatomic) NSArray    * _Nullable sectionIndexTitle;

@property(strong, nonatomic, nullable) NSFetchedResultsController     *fetchedResultsAllFriends;
@property(strong, nonatomic, nullable) NSFetchedResultsController     *fetchedResultsRecentFriends;

-(void) layzInitialize;
-(void) refetchResults;

-(nullable NSFetchRequest *) fetchRequestAllFriends;
-(nullable NSFetchRequest *) fetchRequestRecentFriends;

-(void) setupFetchControllerAllFriends;
-(void) setupFetchControllerRecentFriends;

- (NSInteger) numberOfSections;
- (NSInteger) numberOfRowsInSection:(NSInteger)section;
- (NSString *_Nullable) titleForHeaderInSection:(NSInteger) section;

-(nullable SCUserObject *) userObjectAtIndexPath:(nonnull NSIndexPath *) indexPath;

-(NSArray<SCUserObject *> *_Nullable) allFriends;
-(NSArray<SCUserObject *> *_Nullable) recentFriends;

-(void) selectUser:(SCUserObject *_Nonnull) userObject;
-(void) deselectUser:(SCUserObject *_Nonnull) userObject;
-(BOOL) isUserSelected:(SCUserObject *_Nonnull) userObject;
-(NSArray<SCUserObject *> *_Nullable) selectedUserList;

-(void) beginSearch;
-(void) endSearch;
-(void) searchFilterForText:(NSString *_Nullable) filterText;

@end
