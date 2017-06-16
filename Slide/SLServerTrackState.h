//
//  SLServerTrackState.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLServerUpdate.h"

typedef enum {
    SLServerCurrentTrackPlaying,
    SLServerCurrentTrackPaused
} SLServerCurrentTrackState;

@interface SLServerTrackState : NSObject <SLServerUpdate>

@property (nonatomic) SLServerCurrentTrackState state;

-(instancetype)initWithState:(SLServerCurrentTrackState)state;

@end
