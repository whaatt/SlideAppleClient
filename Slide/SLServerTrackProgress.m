//
//  SLServerTrackProgress.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerTrackProgress.h"

@implementation SLServerTrackProgress

-(instancetype)initWithProgress:(NSTimeInterval)progress {
    if (self = [super init]) {
        self.progress = progress;
    }
    return self;
}

-(BOOL)readyForUpdate {
    return YES;
}

-(BOOL)equalToUpdate:(id<SLServerUpdate>)update {
    SLServerTrackProgress *progressUpdate = (SLServerTrackProgress *)update;
    return (progressUpdate.progress == self.progress);
}

@end
