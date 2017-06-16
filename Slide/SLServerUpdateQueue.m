//
//  SLServerUpdateQueue.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/9/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerUpdateQueue.h"

typedef void (^SLServerUpdateOperationContainer)(void);

@interface SLServerUpdateQueue () {
    NSMutableArray<SLServerUpdateOperation *> *_updates;
}

@end

@implementation SLServerUpdateQueue

-(instancetype)init {
    if (self = [super init]) {
        _updates = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)push:(SLServerUpdateOperation *)update {
    [_updates addObject:update];
    [self run];
}

-(void)run {
    SLServerUpdateOperation *next = [_updates firstObject];
    if (next && [next.executionDelegate readyForUpdate]) {
        [_updates removeObjectAtIndex:0];
        next.operation();
        // [self logNamesForList:(SLServerStreamList *)next.executionDelegate];
        [self run];
    }
}

-(void)logNamesForList:(SLServerStreamList *)list {
    // if (list.type != SLQueueListQueue) return;
    // NSLog(@"List: %@", list.list);
    NSLog(@"SUBMITTING QUEUE:");
    for (SLSong *song in list.list) {
        NSLog(@"song: %@", song.title);
    }
}

@end
