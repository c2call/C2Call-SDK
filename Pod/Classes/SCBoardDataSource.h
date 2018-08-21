//
//  SCBoardDataSource.h
//  C2CallPhone
//
//  Created by Michael Knecht on 20.11.17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SCBoardDataSource, MOC2CallEvent;

typedef NS_ENUM(NSUInteger, SCBoardDataSourceChangeType) {
    SCBoardDataSourceChangeInsert = 1,
    SCBoardDataSourceChangeeDelete = 2,
    SCBoardDataSourceChangeMove = 3,
    SCBoardDataSourceChangeUpdate = 4
};


@protocol SCBoardDataSourceDelegate <NSObject>

@optional
- (void)dataSource:(nonnull SCBoardDataSource *)dataSource didChangeObject:(nullable id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(SCBoardDataSourceChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;

@optional
- (void)dataSourceWillChangeContent:(nonnull SCBoardDataSource *)dataSource;

@optional
- (void)dataSourceDidChangeContent:(nonnull SCBoardDataSource *)dataSource;

@optional
-(void) dataSourceDidReloadContent;

@end

typedef NS_ENUM(NSUInteger, SCBoardObjectType) {
    SCBoardObjectTypeCoreData = 1,
    SCBoardObjectTypeTimeHeader = 2,
    SCBoardObjectTypeSectionHeader = 3,
    SCBoardObjectTypeNewMessagesHeader = 4,
};

@interface SCBoardObject : NSObject

@property (nonatomic) SCBoardObjectType type;
@property (nonatomic, strong, nullable) NSString *parentToken;

@end

@interface SCBoardObjectCoreData : SCBoardObject

-(nullable instancetype) initWithC2CallEvent:(nonnull MOC2CallEvent *) event andParentToken:(nullable NSString *) parentToken;

@property (weak, nonatomic, nullable) MOC2CallEvent     *dataObject;
@property (nonatomic) BOOL sameSenderOnPreviousMessage;
@property (nonatomic) BOOL inboundEvent;
@property (strong, nonatomic, nullable) NSManagedObjectID       *objectId;
@property (strong, nonatomic, nullable) NSString                *eventId;

@property (readonly, nonatomic, nullable) NSString              *mediaKey;
@property (readonly, nonatomic, nullable) NSString              *messageText;

@end

@interface SCBoardObjectTimeHeader : SCBoardObject

+(instancetype)sharedObject;

-(nullable instancetype) initWithTimeStamp:(nonnull NSDate *) tstamp andToken:(nullable NSString *) token;

@property (strong, nonatomic, nonnull) NSString     *timeHeader;
@property (strong, nonatomic, nonnull) NSString     *timeToken;
@property (strong, nonatomic, nonnull) NSDate       *currentDay;

-(nonnull NSString *) formattedStringFromDate:(nonnull NSDate *) date;

@end

@interface SCBoardObjectSectionHeader : SCBoardObject

-(nullable instancetype) initWithSectionHeader:(nonnull NSString *) header;

@property (strong, nonatomic, nonnull) NSString     *sectionHeader;

@end

@interface SCBoardObjectNewMessagesHeader : SCBoardObjectSectionHeader

@end


@interface SCBoardDataSource : NSObject

@property(weak, nonatomic, nullable) id<SCBoardDataSourceDelegate>  delegate;

@property(strong, nonatomic, nullable) NSFetchedResultsController     *fetchedResultsBoardMessages;

@property(strong, nonatomic, nullable) NSMutableArray<SCBoardObject *> *boardContent;
@property(strong, nonatomic, nullable) NSMutableArray<SCBoardObject *> *boardNewMessagesContent;

@property(strong, nonatomic, nullable) NSString *targetUserid;
@property(nonatomic) BOOL dontShowCallEvents;

-(void) layzInitialize;
-(void) dispose;

-(nullable NSFetchRequest *) fetchRequestBoardMessages;
-(void) setupFetchControllerBoardMessages;

- (NSInteger) numberOfSections;
- (NSInteger) numberOfRowsInSection:(NSInteger)section;

-(nullable SCBoardObject *) boardObjectAtIndexPath:(nonnull NSIndexPath *) indexPath;
-(NSIndexPath *_Nullable) indexPathForBoardObject:(SCBoardObject *_Nonnull) bo;
-(NSIndexPath *_Nullable) indexPathForEventId:(NSString *_Nonnull) eventId;

-(BOOL) previousMessages;
-(void) saveChanges;

-(nonnull NSArray<SCBoardObject *> *) allBoardObjects;

-(NSArray<SCBoardObjectCoreData *> *_Nullable) allBoardImages;
-(NSArray<SCBoardObjectCoreData *> *_Nullable) allBoardVideos;
-(NSArray<SCBoardObjectCoreData *> *_Nullable) allBoardMedia;


@end

