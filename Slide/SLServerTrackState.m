//
//  SLServerTrackState.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerTrackState.h"

@implementation SLServerTrackState

-(instancetype)initWithState:(SLServerCurrentTrackState)state {
    if (self = [super init]) {
        self.state = state;
    }
    return self;
}

-(BOOL)readyForUpdate {
    return YES;
}

-(BOOL)equalToUpdate:(id<SLServerUpdate>)update {
    SLServerTrackState *stateUpdate = (SLServerTrackState *)update;
    return (stateUpdate.state == self.state);
}

@end
