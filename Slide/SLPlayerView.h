//
//  SLPlayerView.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SLStream.h"

@class SLPlayerView;

@protocol SLPlayerManager <NSObject>

- (void)playerShouldPlay:(SLPlayerView *)player;
- (void)playerShouldPause:(SLPlayerView *)player;
- (void)playerShouldPlayNextSong:(SLPlayerView *)player;
- (void)playerShouldPlayPreviousSong:(SLPlayerView *)player;
- (void)playerShouldReplayCurrentSong:(SLPlayerView *)player;
- (void)player:(SLPlayerView *)player shouldChangeProgress:(CGFloat)progress;
- (void)playerShouldDisplayQueue:(SLPlayerView *)player;

@end

@interface SLPlayerView : UIView

@property (nonatomic) id<SLPlayerManager> delegate;

// State Updates
- (void)updateSong:(SLSong *)play;
- (void)updateStreamMetadata:(SLStream *)stream;

- (void)play;
- (void)pause;
- (void)updateProgress:(CGFloat)progress;
- (void)playNextEnabled:(BOOL)enabled;
- (void)playPreviousEnabled:(BOOL)enabled;

@end
