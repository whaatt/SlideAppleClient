//
//  SLQueue.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/30/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueue.h"

@interface SLQueue () {
    NSMutableArray<SLSong *> *_locked;
    NSMutableArray<SLSong *> *_queue;
    NSMutableArray<SLSong *> *_upNext;
    NSMutableArray<SLSong *> *_suggestions;
}

@end

@implementation SLQueue

-(instancetype)init{
    if (self = [super init]) {
        // Defaults
        _queue = [NSMutableArray new];
        _locked = [NSMutableArray new];
        _upNext = [NSMutableArray new];
        _suggestions = [NSMutableArray new];
    }
    return self;
}

// Modifiers

-(SLQueueIndex)nextIndex {
    SLQueueIndex next;
    next.position = 0;
    if ([_locked firstObject]){
        next.list = SLQueueListLocked;
    } else if ([_queue firstObject]){
        next.list = SLQueueListQueue;
    } else if ([_upNext firstObject]){
        next.list = SLQueueListUpNext;
    } else {
        next.position = -1;
    }
    return next;
}

-(SLSong *)pop {
    SLQueueIndex next = [self nextIndex];
    NSMutableArray<SLSong *>*target = (NSMutableArray *)[self listForListType:next.list];
    if (next.position != -1) {
        SLSong *song = [target objectAtIndex:next.position];
        [target removeObjectAtIndex:next.position];
        return song;
    } else return nil;
}

-(void)enqueue:(SLSong *)song {
    [_queue insertObject:song atIndex:0];
}

-(NSArray<SLSong *>*)jumpToIndex:(SLQueueIndex)index {
    NSMutableArray<SLSong *> *targetList = (NSMutableArray *)[self listForListType:index.list];
    NSIndexSet *targetIndices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index.position)];
    NSArray<SLSong *> *songs = [targetList objectsAtIndexes:targetIndices];
    [targetList removeObjectsAtIndexes:targetIndices];
    
    if (index.list == SLQueueListUpNext){
        songs = [[_queue copy] arrayByAddingObjectsFromArray:songs];
        [_queue removeAllObjects];
    }
    return songs;
}

-(void)moveItemAtIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex {
    NSMutableArray<SLSong *> *sourceList = (NSMutableArray *)[self listForListType:sourceIndex.list];
    NSMutableArray<SLSong *> *targetList = (NSMutableArray *)[self listForListType:targetIndex.list];
    SLSong *source = [sourceList objectAtIndex:sourceIndex.position];
    [sourceList removeObjectAtIndex:sourceIndex.position];
    [targetList insertObject:source atIndex:targetIndex.position];
}

-(void)updateQueueList:(SLQueueListType)list withSongs:(NSArray<SLSong *> *)songs {
    [self updateList:songs forListType:list];
}

// Readonly

-(NSArray<SLSong *> *)locked {
    return _locked.copy;
}

-(NSArray<SLSong *> *)queue {
    return _queue.copy;
}

-(NSArray<SLSong *> *)upNext {
    return _upNext.copy;
}

-(NSArray<SLSong *> *)suggestions {
    return _suggestions.copy;
}

// Utility

-(void)updateList:(NSArray<SLSong *>*)list forListType:(SLQueueListType)type {
    if (type == SLQueueListLocked) _locked = list.mutableCopy;
    else if (type == SLQueueListQueue) _queue = list.mutableCopy;
    else if (type == SLQueueListUpNext) _upNext = list.mutableCopy;
    else _suggestions = list.mutableCopy;
}

-(NSArray<SLSong *>*)listForListType:(SLQueueListType)type {
    if (type == SLQueueListLocked) return _locked;
    if (type == SLQueueListQueue) return _queue;
    if (type == SLQueueListUpNext) return _upNext;
    else return _suggestions;
}

@end
