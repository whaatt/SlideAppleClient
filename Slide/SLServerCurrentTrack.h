//
//  SLServerCurrentTrack.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/10/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLServerTrackData.h"
#import "SLServerUpdate.h"
#import "SLServerTrackProgress.h"
#import "SLServerTrackState.h"

@interface SLServerCurrentTrack : NSObject <SLServerUpdate>

@property (nonatomic) SLServerTrackData *trackData;
@property (nonatomic) SLServerTrackProgress *progress;
@property (nonatomic) SLServerTrackState *state;

-(instancetype)initWithTrackData:(SLServerTrackData *)trackData
                        progress:(SLServerTrackProgress *)progress
                           state:(SLServerTrackState *)state;

@end
