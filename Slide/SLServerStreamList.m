//
//  SLServerStreamList.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/7/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerStreamList.h"

@implementation SLServerStreamList

+(instancetype)emptyListForType:(SLQueueListType)type {
    return [[SLServerStreamList alloc] initWithType:type songs:@[]];
}

+(NSString *)convertQueueListTypeToString:(SLQueueListType)type {
    if (type == SLQueueListLocked) return @"locked";
    if (type == SLQueueListUpNext) return @"autoplay";
    if (type == SLQueueListSuggestions) return @"suggestion";
    return @"queue";
}

-(instancetype)initWithType:(SLQueueListType)type songs:(NSArray<SLSong *>*)songs {
    if (self = [super init]){
        self.type = type;
        self.list = songs;
    }
    return self;
}

// updates

-(BOOL)readyForUpdate {
    for (SLSong *song in self.list) {
        if (song.identifier == nil) return NO;
    }
    return YES;
}

-(BOOL)equalToUpdate:(id<SLServerUpdate>)update {
    SLServerStreamList *updatedList = (SLServerStreamList *)update;
    if (self.list.count != updatedList.list.count) return NO;
    for (int i = 0; i < self.list.count; i++) {
        if (![[self.list objectAtIndex:i].identifier isEqualToString:[updatedList.list objectAtIndex:i].identifier]) {
            return NO;
        }
    }
    return YES;
}

// utility

-(NSArray<NSArray<SLSong *> *>*)inferUpdates:(SLServerStreamList *)newList {
    // find old tracks
    NSMutableArray<SLSong *>*oldSongs = [NSMutableArray new];
    for (SLSong *song in self.list) {
        if ([newList findSong:song.identifier] == -1) {
            [oldSongs addObject:song];
        }
    }
    
    // find new tracks, build updated list
    NSMutableArray<SLSong *>*newSongs = [NSMutableArray new];
    NSMutableArray<SLSong *>*updatedList = [[NSMutableArray alloc] initWithArray:newList.list];
    NSUInteger index = 0;
    for (SLSong *newSong in newList.list) {
        NSInteger found = [self findSong:newSong.identifier];
        if (found != -1) {
            [updatedList replaceObjectAtIndex:index withObject:[self.list objectAtIndex:found]];
        } else {
            [newSongs addObject:newSong];
        }
        index++;
    }
    
    return @[updatedList, newSongs, oldSongs];
}

-(NSInteger)findSong:(NSString *)identifier {
    if (identifier) {
        for (int i = 0; i < self.list.count; i++) {
            SLSong *currentSong = [self.list objectAtIndex:i];
            if([currentSong.identifier isEqual:identifier]) {
                return i;
            }
        }
    }
    return -1;
}

// server

-(NSString *)serialize {
    NSMutableString *array = [[NSMutableString alloc] init];
    for(SLSong *track in self.list){
        [array appendFormat:@"\"%@\",", track.identifier];
    }
    return [NSString stringWithFormat:@"[%@]", array];
}

+(instancetype)parse:(NSArray *)serverObject {
    NSMutableArray<SLSong *> *trackList = [[NSMutableArray alloc] init];
    for (NSString *string in serverObject) {
        SLSong *song = [SLSong new];
        song.identifier = string;
        [trackList addObject:song];
    }
    SLServerStreamList *streamList = [[SLServerStreamList alloc] init];
    streamList.list = trackList;
    return streamList;
}

@end
