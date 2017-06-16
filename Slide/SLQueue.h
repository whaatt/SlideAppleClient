//
//  SLQueue.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/30/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSong.h"

typedef enum {
    SLQueueListQueue,
    SLQueueListUpNext,
    SLQueueListLocked,
    SLQueueListSuggestions
} SLQueueListType;

typedef struct {
    SLQueueListType list;
    NSUInteger position;
} SLQueueIndex;

@interface SLQueue : NSObject

// Modifiers
-(SLSong *)pop;
-(void)enqueue:(SLSong *)song;
-(NSArray<SLSong *> *)jumpToIndex:(SLQueueIndex)index;
-(void)moveItemAtIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex;
-(void)updateQueueList:(SLQueueListType)list withSongs:(NSArray<SLSong *>*)songs;

// Readonly
-(SLQueueIndex)nextIndex;
-(NSArray<SLSong *> *)listForListType:(SLQueueListType)list;

-(NSArray<SLSong *>*)locked;
-(NSArray<SLSong *>*)queue;
-(NSArray<SLSong *>*)upNext;
-(NSArray<SLSong *>*)suggestions;



@end
