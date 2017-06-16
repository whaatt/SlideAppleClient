//
//  SLServerCurrentTrack.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/10/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerCurrentTrack.h"

@implementation SLServerCurrentTrack

-(instancetype)initWithTrackData:(SLServerTrackData *)trackData
                        progress:(SLServerTrackProgress *)progress
                           state:(SLServerTrackState *)state {
    if (self = [super init]) {
        self.trackData = trackData;
        self.progress = progress;
        self.state = state;
    }
    return self;
}

-(BOOL)equalToUpdate:(id<SLServerUpdate>)update {
    SLServerCurrentTrack *trackUpdate = (SLServerCurrentTrack *)update;
    if ([trackUpdate.trackData.uri isEqualToString:self.trackData.uri] &&
        [trackUpdate.progress equalToUpdate:trackUpdate.progress] &&
        [trackUpdate.state equalToUpdate:trackUpdate.state]) {
        return YES;
    }
    return NO;
}

-(BOOL)readyForUpdate {
    return YES;
}

@end
