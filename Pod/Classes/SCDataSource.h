//
//  SCDataSource.h
//  C2CallPhone
//
//  Created by Michael Knecht on 01.01.18.
//

#ifndef SCDataSource_h
#define SCDataSource_h

typedef NS_ENUM(NSUInteger, SCDataSourceChangeType) {
    SCDataSourceChangeInsert = 1,
    SCDataSourceChangeeDelete = 2,
    SCDataSourceChangeMove = 3,
    SCDataSourceChangeUpdate = 4
};

@protocol SCDataSourceDelegate <NSObject>

@optional
- (void)dataSource:(nonnull id)dataSource didChangeObject:(nullable id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(SCDataSourceChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;

@optional
- (void)dataSource:(nonnull id)dataSource didChangeSection:(NSString *_Nonnull) sectionTitle atIndex:(NSUInteger)sectionIndex forChangeType:(SCDataSourceChangeType)type;

@optional
- (void)dataSourceWillChangeContent:(nonnull id)dataSource;

@optional
- (void)dataSourceDidChangeContent:(nonnull id)dataSource;

@optional
-(void) dataSourceDidReloadContent;

@end

#endif /* SCDataSource_h */
