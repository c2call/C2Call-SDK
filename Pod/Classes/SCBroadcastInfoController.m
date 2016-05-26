//
//  SCBroadcastInfoController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 17/05/16.
//
//

#import "SCBroadcastInfoController.h"
#import "SCDataManager.h"

@interface SCBroadcastInfoController ()<NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSFetchedResultsController *mybroadcasts;

@end

@implementation SCBroadcastInfoController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetch = [[SCDataManager instance] fetchRequestForMyBroadcasts:NO];
    self.mybroadcasts = [[SCDataManager instance] fetchedResultsControllerWithFetchRequest:fetch sectionNameKeyPath:nil cacheName:nil];
    self.mybroadcasts.delegate = self;
    [self.mybroadcasts performFetch:nil];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    int numBroadcasts = [[controller fetchedObjects] count];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.broadcastInfo.text = [NSString stringWithFormat:@"%@ Broadcasts", @(numBroadcasts)];
    });
}

@end
