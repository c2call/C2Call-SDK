//
//  SCBoardDataSource.m
//  C2CallPhone
//
//  Created by Michael Knecht on 20.11.17.
//

#import "SCBoardDataSource.h"
#import <CoreData/CoreData.h>
#import "SocialCommunication.h"
#import "debug.h"



@interface SCBoardDataSource()<NSFetchedResultsControllerDelegate> {
    NSString *lastTimeHeader;
    NSString *contentMutex;
    
    int fetchLimit, fetchSize;
    BOOL hasPreviousMessages;
}

@property(strong, nonatomic) id observer;

@end

@implementation SCBoardObject

- (BOOL)isEqual:(id)other
{
    
    if ([other hash] == [self hash]) {
        return YES;
    }
    
    return NO;
}

@end

@implementation SCBoardObjectCoreData

-(nullable instancetype) initWithC2CallEvent:(nonnull MOC2CallEvent *) event andParentToken:(NSString *)parentToken
{
    self = [super init];
    if (self) {
        self.type = SCBoardObjectTypeCoreData;
        self.parentToken = parentToken;
        self.dataObject = event;
        self.sameSenderOnPreviousMessage = NO;
        self.objectId = [event.objectID copy];
        self.eventId = [event.eventId copy];
    }
    return self;
}

- (NSUInteger)hash
{
    return [self.objectId hash];
}

-(MOC2CallEvent *) dataObject
{
    if (_dataObject) {
        return _dataObject;
    }
    
    return [[SCDataManager instance] eventForEventId:self.eventId];
}

@end

@implementation SCBoardObjectTimeHeader

-(nullable instancetype) initWithTimeStamp:(nonnull NSDate *) tstamp  andToken:(NSString *) token;
{
    self = [super init];
    if (self) {
        self.type = SCBoardObjectTypeTimeHeader;
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        self.currentDay = [cal startOfDayForDate:tstamp];
        
        NSDate *today = [NSDate date];
        today = [cal startOfDayForDate:today];
        
        NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
        yesterday = [cal startOfDayForDate:yesterday];
        
        NSComparisonResult resultToday =[today compare:tstamp];
        NSComparisonResult resultYesterday =[yesterday compare:tstamp];
        
        if (resultToday == NSOrderedAscending || resultToday == NSOrderedSame) {
            self.timeHeader = @"Today";
        } else if (resultYesterday == NSOrderedAscending || resultYesterday == NSOrderedSame) {
            self.timeHeader = @"Yesterday";
        } else  {
            NSDateFormatter *df = [self dateFormatterForTimeHeader:tstamp];
            self.timeHeader = [df stringFromDate:tstamp];
        }
        
        self.timeToken = token;
    }
    return self;
}

- (NSUInteger)hash
{
    return [self.timeToken hash];
}

- (NSComparisonResult)compare:(SCBoardObjectTimeHeader *)other
{
    return [self.currentDay compare:other.currentDay];
}



-(nonnull NSDateFormatter *) dateFormatterForTimeHeader:(nonnull NSDate *) date;
{
    BOOL useWeekDay = YES;
    NSTimeInterval ti = [date timeIntervalSinceNow];
    if (ti < 0) {
        ti = ti * -1;
        
        if (ti > 604800.) {
            useWeekDay = NO;
        }
    }
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    if (useWeekDay) {
        [df setDateFormat:@"EEEE"];
    } else {
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterNoStyle];
    }
    
    return df;
}


@end

@implementation SCBoardObjectSectionHeader

-(nullable instancetype) initWithSectionHeader:(nonnull NSString *) header;
{
    self = [super init];
    if (self) {
        self.type = SCBoardObjectTypeSectionHeader;
        self.sectionHeader = header;
        
    }
    return self;
}

@end

@implementation SCBoardObjectNewMessagesHeader

-(nullable instancetype) initWithSectionHeader:(nonnull NSString *) header;
{
    self = [super initWithSectionHeader: header];
    if (self) {
        self.type = SCBoardObjectTypeNewMessagesHeader;
    }
    return self;
}

@end

@implementation SCBoardDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        lastTimeHeader = nil;
        contentMutex = @"MUTEX";

        [self resetLimits];
    }
    return self;
}

-(void) resetLimits
{
    fetchLimit = 25;
    fetchSize = 25;
}

-(NSFetchRequest *) fetchRequestBoardMessages;
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForEventHistory:nil sort:YES];
    
    if (self.targetUserid) {
        NSPredicate *predicate = nil;
        
        if (!self.dontShowCallEvents) {
            predicate = [NSPredicate predicateWithFormat:@"contact == %@", self.targetUserid];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"contact == %@ AND eventType contains[cd] %@", self.targetUserid, @"message"];
        }
        
        [fetchRequest setPredicate:predicate];
    } else if (self.dontShowCallEvents) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType contains[cd] %@", @"message"];
        [fetchRequest setPredicate:predicate];
    }
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:fetchLimit >= 0? fetchLimit:0];
    
    int offset = 0;
    if (fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:fetchLimit forFetchRequest:fetchRequest];
    }
    
    hasPreviousMessages = offset > 0;
    
    return fetchRequest;
}

-(void) setupFetchControllerBoardMessages;
{
    NSFetchRequest *fetchRequest = [self fetchRequestBoardMessages];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    if (!fetchRequest)
        return;
    
    @try {
        NSFetchedResultsController *aFetchedResultsController = [[SCDataManager instance] fetchedResultsControllerWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
        
        if (!aFetchedResultsController)
            return;
        
        if (self.fetchedResultsBoardMessages) {
            self.fetchedResultsBoardMessages.delegate = nil;
            self.fetchedResultsBoardMessages = nil;
        }
        self.fetchedResultsBoardMessages = aFetchedResultsController;
        
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![self.fetchedResultsBoardMessages performFetch:&error]) {
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return;
        }

        [self prepareBoardMessages];
    }
    @catch (NSException *exception) {
        DLog(@"Exeption : %@", exception);
    }
    
}

-(void) prepareBoardMessages {
    NSFetchRequest *missedRequest = [[SCDataManager instance] fetchRequestForMissedEvents:self.targetUserid sort:YES];
    NSArray<NSManagedObject *> *missedEvents = [[SCDataManager instance] performFetchRequest:missedRequest];
    
    NSArray *fetchedEvents = [self.fetchedResultsBoardMessages fetchedObjects];
    NSMutableArray<MOC2CallEvent *> *remainingMissedEvents = [NSMutableArray array];
    
    for (NSManagedObject *elem in missedEvents) {
        if ([elem isKindOfClass:[MOC2CallEvent class]]) {
            MOC2CallEvent *evnt = (MOC2CallEvent *) elem;
            
            if (![fetchedEvents containsObject:evnt]) {
                [remainingMissedEvents addObject:evnt];
            }
        }
    }
    
    [self reloadBoardMessages: remainingMissedEvents];
}

- (void)dealloc
{
    if (self.observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        self.observer = nil;
    }
}

-(void) layzInitialize {
    
    __weak SCBoardDataSource *weakself = self;
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"C2CallDataManager:initData" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (!weakself.fetchedResultsBoardMessages) {
            [weakself setupFetchControllerBoardMessages];
        }
    }];
    
    if ([SCDataManager instance].isDataInitialized) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        self.observer = nil;
        
        [self setupFetchControllerBoardMessages];
        return;
    }
}

-(BOOL) isSameSenderOnPreviousMessage:(SCBoardObjectCoreData *) bocd inList:(NSArray<SCBoardObject*> *) list
{
    NSUInteger idx = [list indexOfObject:bocd];
    if (idx == NSNotFound || idx == 0) {
        return NO;
    }
    
    SCBoardObject *bo = list[idx - 1];
    if (![bo isKindOfClass:[SCBoardObjectCoreData class]]) {
        return NO;
    }
    
    SCBoardObjectCoreData *previous = (SCBoardObjectCoreData *) bo;
    if (!bocd.inboundEvent) {
        if (!previous.inboundEvent) {
            NSLog(@"Same Sender : %@ / %@ %@:%@ : YES", bocd.dataObject.text, previous.dataObject.text, @(bocd.inboundEvent), @(previous.inboundEvent));
            return YES;
        }
        NSLog(@"Same Sender : %@ / %@ %@:%@ : NO", bocd.dataObject.text, previous.dataObject.text, @(bocd.inboundEvent), @(previous.inboundEvent));
        return NO;
    } else {
        if (!previous.inboundEvent) {
            return NO;
        }
    }
    
    NSString *sendernamePrevious = previous.dataObject.originalSender?previous.dataObject.originalSender : previous.dataObject.contact;
    NSString *sendernameCurrent = bocd.dataObject.originalSender?bocd.dataObject.originalSender : bocd.dataObject.contact;
    
    return [sendernamePrevious isEqualToString:sendernameCurrent];
}

-(void) reloadBoardMessages:(NSArray<MOC2CallEvent *> *) remainingMissedEvents
{
    
    NSMutableArray<SCBoardObject *> *messages = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsBoardMessages fetchedObjects] count] + 10];
    NSMutableArray<SCBoardObject *> *newMessages = [NSMutableArray arrayWithCapacity:20];
    
    NSString *currentDay = nil;
    NSString *currentDayNewMessages = nil;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    
    for (MOC2CallEvent *evnt in remainingMissedEvents) {
        
        if (self.dontShowCallEvents && ([evnt.eventType hasPrefix:@"Call"])) {
            continue;
        }
        
        NSString *cmpDate = [df stringFromDate:evnt.timeStamp];
        SCBoardObjectCoreData *dataObject = [[SCBoardObjectCoreData alloc] initWithC2CallEvent:evnt andParentToken:cmpDate];
        
        dataObject.inboundEvent = [self isInboundMessage:evnt];
        
        if ([evnt.missedDisplay boolValue]) {
            if (![cmpDate isEqualToString:currentDayNewMessages]) {
                // Adding a new TimeHeader
                SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:evnt.timeStamp andToken:cmpDate];
                [newMessages addObject:timeHeader];
                
                currentDayNewMessages = cmpDate;
            }
            
            [newMessages addObject:dataObject];
            
            dataObject.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:dataObject inList:newMessages];
        } else {
            if (![cmpDate isEqualToString:currentDay]) {
                // Adding a new TimeHeader
                SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:evnt.timeStamp andToken:cmpDate];
                [messages addObject:timeHeader];
                
                currentDay = cmpDate;
            }
            
            [messages addObject:dataObject];
            dataObject.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:dataObject inList:messages];
        }
    }

    for (MOC2CallEvent *evnt in [self.fetchedResultsBoardMessages fetchedObjects]) {
        
        NSString *cmpDate = [df stringFromDate:evnt.timeStamp];
        SCBoardObjectCoreData *dataObject = [[SCBoardObjectCoreData alloc] initWithC2CallEvent:evnt andParentToken:cmpDate];
        
        dataObject.inboundEvent = [self isInboundMessage:evnt];
        
        if ([evnt.missedDisplay boolValue]) {
            if (![cmpDate isEqualToString:currentDayNewMessages]) {
                // Adding a new TimeHeader
                SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:evnt.timeStamp andToken:cmpDate];
                [newMessages addObject:timeHeader];
                
                currentDayNewMessages = cmpDate;
            }
            
            [newMessages addObject:dataObject];
            
            dataObject.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:dataObject inList:newMessages];
        } else {
            if (![cmpDate isEqualToString:currentDay]) {
                // Adding a new TimeHeader
                SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:evnt.timeStamp andToken:cmpDate];
                [messages addObject:timeHeader];
                
                currentDay = cmpDate;
            }
            
            [messages addObject:dataObject];
            dataObject.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:dataObject inList:messages];
        }
    }


    
    if ([newMessages count] > 0) {
        
        int count = 0;
        for (SCBoardObject *bo in newMessages) {
            if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                count++;
            }
        }
        
        SCBoardObjectNewMessagesHeader *section = [[SCBoardObjectNewMessagesHeader alloc] initWithSectionHeader:[self sectionStringForUnreadMessages:count]];
        [newMessages insertObject:section atIndex:0];
    }
    
    
    
    @synchronized(contentMutex) {
        lastTimeHeader = currentDay;
        self.boardContent = messages;
        self.boardNewMessagesContent = newMessages;
    }
    
    if ([NSThread isMainThread]) {
        [self.delegate dataSourceDidReloadContent];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate dataSourceDidReloadContent];
        });
    }
}

-(void) insertPreviousMessages
{
    NSArray<MOC2CallEvent *> *allMessages = [self.fetchedResultsBoardMessages fetchedObjects];
    
    if ([allMessages count] == 0) {
        return;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];

    
    NSMutableArray<SCBoardObjectCoreData *> *bolist = [NSMutableArray array];
    @synchronized(contentMutex) {
        
        for (NSUInteger i = [allMessages count] - 1; i > 0; i--) {
            MOC2CallEvent *evnt = allMessages[i];
            
            NSString *cmpDate = [df stringFromDate:evnt.timeStamp];
            SCBoardObjectCoreData *bocd = [[SCBoardObjectCoreData alloc] initWithC2CallEvent:evnt andParentToken:cmpDate];
            bocd.inboundEvent = [self isInboundMessage:evnt];
            
            NSUInteger idx = [self.boardContent indexOfObject:bocd];
            if (idx != NSNotFound) {
                // Updating MOC2CallEvent
                
                SCBoardObjectCoreData *data = (SCBoardObjectCoreData *) self.boardContent[idx];
                data.dataObject = evnt;
                NSLog(@"SCBoardTest: insertPreviousMessages - 1:Existing Message: %@", evnt.text);
                continue;
            }
            
            idx = [self.boardNewMessagesContent indexOfObject:bocd];
            if (idx != NSNotFound) {
                NSLog(@"SCBoardTest: insertPreviousMessages - 2:Existing Message: %@", evnt.text);
                // Updating MOC2CallEvent
                SCBoardObjectCoreData *data = (SCBoardObjectCoreData *) self.boardNewMessagesContent[idx];
                data.dataObject = evnt;
                continue;
            }
            
            if (![self.boardContent containsObject:bocd] && ![self.boardNewMessagesContent containsObject:bocd]) {
                NSLog(@"SCBoardTest: insertPreviousMessages - Insert Message: %@", evnt.text);
                [bolist insertObject:bocd atIndex:0];
            }
        }
    }
    if ([bolist count] == 0) {
        return;
    }
    

    //dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(contentMutex) {
            
            for (SCBoardObjectCoreData *bocd in bolist) {
                SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:bocd.dataObject.timeStamp andToken:bocd.parentToken];
                
                [self insertDataObject:bocd withTimeHeader:timeHeader intoList:self.boardContent offset:0 notifyDelegate:NO];
            }
        }
        //[self.delegate dataSourceDidReloadContent];
    //});

}

-(BOOL) previousMessages
{
    if (!hasPreviousMessages) {
        return NO;
    }
    
    int fetchedObectsCount = (int)[[self.fetchedResultsBoardMessages fetchedObjects] count];
    fetchLimit = MAX(fetchedObectsCount, fetchLimit);
    
    fetchLimit += fetchSize;
    [self refetchResults];
    return YES;
}


-(void) refetchResults
{
    NSFetchRequest *fetchRequest = [self.fetchedResultsBoardMessages fetchRequest];
    [fetchRequest setFetchLimit:0];
    [fetchRequest setFetchOffset:0];
    
    int offset = 0;
    if (fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:fetchLimit forFetchRequest:fetchRequest];
    }
    
    [fetchRequest setFetchLimit:fetchLimit];
    [fetchRequest setFetchOffset:offset];
    
    hasPreviousMessages = offset > 0;
    
    NSError *error = nil;
    [self.fetchedResultsBoardMessages performFetch:&error];
    if (error) {
        DLog(@"Error : %@", error);
    }
    
    [self insertPreviousMessages];
    //[self refreshFilterInfo];
}

-(NSString *) sectionStringForUnreadMessages:(NSInteger) unreadMessages
{
    return [NSString stringWithFormat:@"%@ UNREAD MESSAGES", @(unreadMessages)];
}

-(void) handleInitDataEvent:(NSNotification *) notification
{
    DLog(@"handleInitDataEvent: %@", notification);
    if ([[notification name] isEqualToString:@"C2CallDataManager:initData"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[self updateFetchRequest];
        });
    }
}

- (NSInteger)numberOfSections
{
    return 1;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    return [self.boardContent count] + [self.boardNewMessagesContent count];
}

-(SCBoardObject *) boardObjectAtIndexPath:(NSIndexPath *) indexPath
{
    @synchronized(contentMutex) {
        if (indexPath.row < [self.boardContent count]) {
            return self.boardContent[indexPath.row];
        }
        
        NSUInteger newMessagesIdx = indexPath.row - [self.boardContent count];
        if (newMessagesIdx < [self.boardNewMessagesContent count]) {
            return self.boardNewMessagesContent[newMessagesIdx];
        }
        
        return nil;
    }
}

-(NSIndexPath *) indexPathForBoardObject:(SCBoardObject *) bo
{
    NSUInteger offset = 0;
    
    if (!bo) {
        return nil;
    }
    
    @synchronized(contentMutex) {
        NSUInteger idx = [self.boardContent indexOfObject:bo];
        
        if (idx == NSNotFound && [self.boardNewMessagesContent count] > 0) {
            idx = [self.boardNewMessagesContent indexOfObject:bo];
            offset = [self.boardContent count];
        }

        
        if (idx != NSNotFound) {
            return [NSIndexPath indexPathForRow:idx + offset inSection:0];
        }
        
        return nil;
    }
    
}

-(NSArray<SCBoardObject *> *) allBoardObjects
{
    @synchronized(contentMutex) {
        
        // Return empty array
        if (!self.boardContent) {
            return [NSArray array];
        }
        
        NSMutableArray<SCBoardObject *> *allObjects = [NSMutableArray arrayWithArray:self.boardContent];
        
        if (self.boardNewMessagesContent) {
            [allObjects addObjectsFromArray:self.boardNewMessagesContent];
        }
        
        return allObjects;
    }
    
}

-(NSArray<SCBoardObjectCoreData *> *) allBoardImages
{
    @synchronized(contentMutex) {
        
        // Return empty array
        if (!self.boardContent) {
            return [NSArray array];
        }
        NSMutableArray<SCBoardObjectCoreData *> *imageObjects = [NSMutableArray arrayWithCapacity:[self.boardContent count] + 1];
        
        for (SCBoardObject *bo in self.boardContent) {
            if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                SCBoardObjectCoreData *cdo = (SCBoardObjectCoreData *) bo;
                if ([[C2CallPhone currentPhone] mediaTypeForKey:cdo.dataObject.text] == SCMEDIATYPE_IMAGE) {
                    [imageObjects addObject:cdo];
                }
            }
        }
        
        if (self.boardNewMessagesContent) {
            for (SCBoardObject *bo in self.boardNewMessagesContent) {
                if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                    SCBoardObjectCoreData *cdo = (SCBoardObjectCoreData *) bo;
                    if ([[C2CallPhone currentPhone] mediaTypeForKey:cdo.dataObject.text] == SCMEDIATYPE_IMAGE) {
                        [imageObjects addObject:cdo];
                    }
                }
            }
        }
        
        return imageObjects;
    }
}

-(NSArray<SCBoardObjectCoreData *> *) allBoardVideos
{
    @synchronized(contentMutex) {
        
        // Return empty array
        if (!self.boardContent) {
            return [NSArray array];
        }
        NSMutableArray<SCBoardObjectCoreData *> *videoObjects = [NSMutableArray arrayWithCapacity:[self.boardContent count] + 1];
        
        for (SCBoardObject *bo in self.boardContent) {
            if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                SCBoardObjectCoreData *cdo = (SCBoardObjectCoreData *) bo;
                if ([[C2CallPhone currentPhone] mediaTypeForKey:cdo.dataObject.text] == SCMEDIATYPE_VIDEO) {
                    [videoObjects addObject:cdo];
                }
            }
        }
        
        if (self.boardNewMessagesContent) {
            for (SCBoardObject *bo in self.boardNewMessagesContent) {
                if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                    SCBoardObjectCoreData *cdo = (SCBoardObjectCoreData *) bo;
                    if ([[C2CallPhone currentPhone] mediaTypeForKey:cdo.dataObject.text] == SCMEDIATYPE_VIDEO) {
                        [videoObjects addObject:cdo];
                    }
                }
            }
        }
        
        return videoObjects;
    }
}

-(BOOL) isMedia:(SCRichMediaType) mt
{
    switch (mt) {
        case SCMEDIATYPE_IMAGE:
        case SCMEDIATYPE_VIDEO:
        case SCMEDIATYPE_FILE:
        case SCMEDIATYPE_VOICEMAIL:
        case SCMEDIATYPE_VCARD:
        case SCMEDIATYPE_LOCATION:
            return YES;
        default:
            return NO;
    }
}

-(NSArray<SCBoardObjectCoreData *> *) allBoardMedia
{
    @synchronized(contentMutex) {
        
        // Return empty array
        if (!self.boardContent) {
            return [NSArray array];
        }
        NSMutableArray<SCBoardObjectCoreData *> *mediaObjects = [NSMutableArray arrayWithCapacity:[self.boardContent count] + 1];
        
        for (SCBoardObject *bo in self.boardContent) {
            if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                SCBoardObjectCoreData *cdo = (SCBoardObjectCoreData *) bo;
                if ([self isMedia:[[C2CallPhone currentPhone] mediaTypeForKey:cdo.dataObject.text]]) {
                    [mediaObjects addObject:cdo];
                }
            }
        }
        
        if (self.boardNewMessagesContent) {
            for (SCBoardObject *bo in self.boardNewMessagesContent) {
                if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                    SCBoardObjectCoreData *cdo = (SCBoardObjectCoreData *) bo;
                    if ([self isMedia:[[C2CallPhone currentPhone] mediaTypeForKey:cdo.dataObject.text]]) {
                        [mediaObjects addObject:cdo];
                    }
                }
            }
        }
        
        return mediaObjects;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
{
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.delegate dataSourceWillChangeContent:self];
            [self insertEvent:anObject atIndexPath:newIndexPath];
            [self.delegate dataSourceDidChangeContent:self];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.delegate dataSourceWillChangeContent:self];
            [self deleteEvent:anObject atIndexPath:indexPath];
            [self.delegate dataSourceDidChangeContent:self];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self updateEvent:anObject atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.delegate dataSourceWillChangeContent:self];
            [self moveEvent:anObject fromIndexPath:indexPath to:newIndexPath];
            [self.delegate dataSourceDidChangeContent:self];
            break;
    }
    
}

-(void) addBoardContent:(SCBoardObject *) obj
{
    @synchronized(contentMutex) {
        [self.boardContent addObject:obj];
    }
}

-(void) insertBoardContent:(SCBoardObject *) obj atIndex:(NSUInteger) idx
{
    @synchronized(contentMutex) {
        [self.boardContent insertObject:obj atIndex:idx];
    }
}

-(void) removeBoardContent:(SCBoardObject *) obj
{
    @synchronized(contentMutex) {
        [self.boardContent removeObject:obj];
    }
}

-(SCBoardObjectNewMessagesHeader *) currentNewMessagesHeader
{
    @synchronized(contentMutex) {
        for (SCBoardObject *obj in self.boardNewMessagesContent) {
            if ([obj isKindOfClass:[SCBoardObjectNewMessagesHeader class]]) {
                return (SCBoardObjectNewMessagesHeader *)obj;
            }
        }
    }
    
    return nil;
}

// Call only from synchronized block
-(void) updateNewMessagesHeader
{
    NSUInteger contentOffset = [self.boardContent count];
    
    if ([self.boardNewMessagesContent count] > 0) {
        // It's always the first object
        SCBoardObjectNewMessagesHeader *nh = (SCBoardObjectNewMessagesHeader *) self.boardNewMessagesContent[0];
        
        int count = 0;
        for (SCBoardObject *bo in self.boardNewMessagesContent) {
            if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                count++;
            }
        }
        
        // In case we don't have data objects left, clear this section
        if (count == 0) {
            while ([self.boardNewMessagesContent count] > 0) {
                SCBoardObject *bo = self.boardNewMessagesContent[0];
                [self.boardNewMessagesContent removeObjectAtIndex:0];
                
                [self.delegate dataSource:self didChangeObject:bo atIndexPath:[NSIndexPath indexPathForRow:0 + contentOffset inSection:0] forChangeType:SCBoardDataSourceChangeeDelete newIndexPath:nil];
            }
            return;
        }
        
        // Update the header with the new object count
        nh.sectionHeader = [self sectionStringForUnreadMessages:count];
        [self.delegate dataSource:self didChangeObject:nh atIndexPath:[NSIndexPath indexPathForRow:0 + contentOffset inSection:0] forChangeType:SCBoardDataSourceChangeUpdate newIndexPath:nil];
    }
}

-(NSUInteger) insertIndex:(NSArray *) list forTimeHeader:(SCBoardObjectTimeHeader *) timeHeader
{
    for (SCBoardObject *bo in list) {
        
        if ([bo isKindOfClass:[SCBoardObjectTimeHeader class]]) {
            SCBoardObjectTimeHeader *th = (SCBoardObjectTimeHeader *)bo;
            
            // We return the index of the first time header which is after our reference timestamp
            if ([timeHeader.currentDay compare:th.currentDay] == NSOrderedAscending) {
                return [list indexOfObject:th];
            }
        }
    }
    
    // Just append
    return [list count];
}

-(NSUInteger) insertIndex:(NSArray *) list forDataObject:(SCBoardObjectCoreData *) dataObject startIdx:(NSUInteger) startIdx
{
    //
    for (NSUInteger i = startIdx; i < [list count]; i++) {
        SCBoardObject *bo = list[i];
        
        if ([bo isKindOfClass:[SCBoardObjectTimeHeader class]]) {
            SCBoardObjectTimeHeader *th = (SCBoardObjectTimeHeader *) bo;
            
            if (![dataObject.parentToken isEqualToString:th.timeToken]) {
                // Break here, we got to the next time header
                return i;
            }
        }
        
        if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
            SCBoardObjectCoreData *obj = (SCBoardObjectCoreData *)bo;
            
            // We return the index of the first Data Object which has a larger timestamp
            if ([dataObject.dataObject.timevalue longLongValue] < [obj.dataObject.timevalue longLongValue]) {
                return i;
            }
        }
    }
    
    // Just append
    return [list count];
}

-(BOOL) isInboundMessage:(MOC2CallEvent *) event
{
    if ([event.eventType isEqualToString:@"MessageIn"] || [event.eventType isEqualToString:@"CallIn"]) {
        return YES;
    }
    
    return NO;
}

-(void) insertDataObject:(SCBoardObjectCoreData *) dataObject withTimeHeader:(SCBoardObjectTimeHeader *)timeHeader intoList:(NSMutableArray<SCBoardObject *> *) list offset:(NSUInteger) idxOffset notifyDelegate:(BOOL) notify
{
    NSUInteger timeHeaderIdx = [list indexOfObject:timeHeader];
    if (timeHeaderIdx == NSNotFound) {
        // Adding a new TimeHeader
        
        NSUInteger idx = [self insertIndex:list forTimeHeader:timeHeader];
        [list insertObject:timeHeader atIndex:idx];
        
        if (notify) {
            [self.delegate dataSource:self didChangeObject:timeHeader atIndexPath:nil forChangeType:SCBoardDataSourceChangeInsert newIndexPath:[NSIndexPath indexPathForRow:idx + idxOffset inSection:0]];
        }
        
        idx++;
        [list insertObject:dataObject atIndex:idx];
        
        if (notify) {
            [self.delegate dataSource:self didChangeObject:dataObject atIndexPath:nil forChangeType:SCBoardDataSourceChangeInsert newIndexPath:[NSIndexPath indexPathForRow:idx + idxOffset inSection:0]];
        }
        
    } else {
        NSUInteger idx = [self insertIndex:list forDataObject:dataObject startIdx:timeHeaderIdx];
        [list insertObject:dataObject atIndex:idx];
        
        dataObject.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:dataObject inList:list];
        
        if (notify) {
            [self.delegate dataSource:self didChangeObject:dataObject atIndexPath:nil forChangeType:SCBoardDataSourceChangeInsert newIndexPath:[NSIndexPath indexPathForRow:idx + idxOffset inSection:0]];
        }
        
    }
}

-(void) refreshSameSenderInformation
{
    for (SCBoardObject *bo in self.boardContent) {
        if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
            SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) bo;
            bocd.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:(SCBoardObjectCoreData *) bo inList:self.boardContent];
        }
    }
    
    for (SCBoardObject *bo in self.boardNewMessagesContent) {
        if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
            SCBoardObjectCoreData *bocd = (SCBoardObjectCoreData *) bo;
            bocd.sameSenderOnPreviousMessage = [self isSameSenderOnPreviousMessage:(SCBoardObjectCoreData *) bo inList:self.boardNewMessagesContent];
        }
    }
    
}

-(void) insertEvent:(MOC2CallEvent *) evnt atIndexPath: (NSIndexPath *) indexPath
{
    
    if (self.dontShowCallEvents && ([evnt.eventType hasPrefix:@"Call"])){
        return;
    }

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *cmpDate = [df stringFromDate:evnt.timeStamp];
    SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:evnt.timeStamp andToken:cmpDate];
    SCBoardObjectCoreData *dataObject = [[SCBoardObjectCoreData alloc] initWithC2CallEvent:evnt andParentToken:cmpDate];
    dataObject.inboundEvent = [self isInboundMessage:evnt];
    
    @synchronized(contentMutex) {
        NSMutableArray *list = nil;
        NSUInteger idxOffset = 0;
        BOOL updateNewMessagesHeader = NO;
        
        // In case we get a new outbound message
        // Remove the new messages section
        if ([self.boardNewMessagesContent count] > 0 && ![self isInboundMessage:dataObject.dataObject]) {
            
            NSMutableArray<SCBoardObjectCoreData *> *reInsertList = [NSMutableArray arrayWithCapacity:[self.boardNewMessagesContent count]];
            idxOffset = [self.boardContent count];
            while ([self.boardNewMessagesContent count] > 0) {
                SCBoardObject *bo = [self.boardNewMessagesContent lastObject];
                
                NSUInteger currentIdx = [self.boardNewMessagesContent indexOfObject:bo] + idxOffset;
                [self.boardNewMessagesContent removeObject:bo];
                [self.delegate dataSource:self didChangeObject:bo atIndexPath:[NSIndexPath indexPathForRow:currentIdx inSection:0] forChangeType:SCBoardDataSourceChangeeDelete newIndexPath:nil];
                
                if ([bo isKindOfClass:[SCBoardObjectCoreData class]]) {
                    [reInsertList insertObject:(SCBoardObjectCoreData *)bo atIndex:0];
                }
            }
            
            for (SCBoardObjectCoreData *bo in reInsertList) {
                NSString *cmpDate = [df stringFromDate:bo.dataObject.timeStamp];
                SCBoardObjectTimeHeader *timeHeader = [[SCBoardObjectTimeHeader alloc] initWithTimeStamp:bo.dataObject.timeStamp andToken:cmpDate];
                
                [self insertDataObject:(SCBoardObjectCoreData *) bo withTimeHeader:(SCBoardObjectTimeHeader *)timeHeader intoList:(NSMutableArray<SCBoardObject *> *) self.boardContent offset:0 notifyDelegate:YES];
            }
            
            [self refreshSameSenderInformation];
        }
        
        idxOffset = 0;
        if ([evnt.missedDisplay boolValue] && [self.boardNewMessagesContent count] > 0 && [self isInboundMessage:dataObject.dataObject]) {
            list = self.boardNewMessagesContent;
            idxOffset = [self.boardContent count];
            updateNewMessagesHeader = YES;
        } else {
            list = self.boardContent;
        }
        
        [self insertDataObject:dataObject withTimeHeader:timeHeader intoList:list offset:idxOffset notifyDelegate:YES];
        
        if (updateNewMessagesHeader) {
            [self updateNewMessagesHeader];
        }
        
    }
    
}

-(void) deleteEvent:(MOC2CallEvent *) evnt atIndexPath: (NSIndexPath *) indexPath
{
    // We create this dataObject as compare object, to find its index in the content lists
    SCBoardObjectCoreData *dataObject = [[SCBoardObjectCoreData alloc] initWithC2CallEvent:evnt andParentToken:@""];
    dataObject.inboundEvent = [self isInboundMessage:evnt];
    
    @synchronized(contentMutex) {
        
        // First Step, locate the object in the content list
        NSUInteger idx = [self.boardContent indexOfObject:dataObject];
        if (idx != NSNotFound) {
            dataObject = (SCBoardObjectCoreData *) self.boardContent[idx];
            
            // Remove the object
            [self.boardContent removeObjectAtIndex:idx];
            [self.delegate dataSource:self didChangeObject:dataObject atIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] forChangeType:SCBoardDataSourceChangeeDelete newIndexPath:nil];
            
            // Find the previous object and if time header, remove too
            if (idx > 0) {
                idx--;
                
                SCBoardObject *bo = self.boardContent[idx];
                if ([bo isKindOfClass:[SCBoardObjectTimeHeader class]]) {
                    [self.boardContent removeObjectAtIndex:idx];
                    [self.delegate dataSource:self didChangeObject:bo atIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] forChangeType:SCBoardDataSourceChangeeDelete newIndexPath:nil];
                }
            }
            return;
        }
        
        // Do the same for the new messages section
        idx = [self.boardNewMessagesContent indexOfObject:dataObject];
        if (idx != NSNotFound) {
            NSUInteger contentOffset = [self.boardContent count];
            dataObject = (SCBoardObjectCoreData *) self.boardNewMessagesContent[idx];
            
            // Remove the object
            [self.boardNewMessagesContent removeObjectAtIndex:idx];
            [self.delegate dataSource:self didChangeObject:dataObject atIndexPath:[NSIndexPath indexPathForRow:idx + contentOffset inSection:0] forChangeType:SCBoardDataSourceChangeeDelete newIndexPath:nil];
            
            // Find the previous object and if time header, remove too
            if (idx > 0) {
                idx--;
                
                SCBoardObject *bo = self.boardNewMessagesContent[idx];
                if ([bo isKindOfClass:[SCBoardObjectTimeHeader class]]) {
                    [self.boardNewMessagesContent removeObjectAtIndex:idx];
                    [self.delegate dataSource:self didChangeObject:bo atIndexPath:[NSIndexPath indexPathForRow:idx + contentOffset inSection:0] forChangeType:SCBoardDataSourceChangeeDelete newIndexPath:nil];
                }
            }
            
            // Update or remove the new message header
            [self updateNewMessagesHeader];
            return;
        }
    }
    
}


-(void) updateEvent:(MOC2CallEvent *) evnt atIndexPath: (NSIndexPath *) indexPath
{
    
    if (self.dontShowCallEvents && ([evnt.eventType hasPrefix:@"Call"])){
        return;
    }

    // We create this dataObject as compare object, to find its index in the content lists
    SCBoardObjectCoreData *dataObject = [[SCBoardObjectCoreData alloc] initWithC2CallEvent:evnt andParentToken:@""];
    dataObject.inboundEvent = [self isInboundMessage:evnt];
    
    @synchronized(contentMutex) {
        // First Step, locate the object in the content list
        NSUInteger idx = [self.boardContent indexOfObject:dataObject];
        if (idx != NSNotFound) {
            dataObject = (SCBoardObjectCoreData *)self.boardContent[idx];
            [self.delegate dataSource:self didChangeObject:dataObject atIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] forChangeType:SCBoardDataSourceChangeUpdate newIndexPath:nil];
            return;
        }
        
        idx = [self.boardNewMessagesContent indexOfObject:dataObject];
        if (idx != NSNotFound) {
            NSUInteger contentOffset = [self.boardContent count];
            dataObject = (SCBoardObjectCoreData *) self.boardNewMessagesContent[idx];
            [self.delegate dataSource:self didChangeObject:dataObject atIndexPath:[NSIndexPath indexPathForRow:idx + contentOffset inSection:0] forChangeType:SCBoardDataSourceChangeUpdate newIndexPath:nil];
            return;
        }
    }
}

// We do not move anything...
-(void) moveEvent:(MOC2CallEvent *) evnt fromIndexPath: (NSIndexPath *) oldIndexPath to:(NSIndexPath *) newIndexPath
{
    
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



@end
