//
//  SLQueueNowPlayingView.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/27/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLStream.h"

@class SLQueueNowPlayingView;

@protocol SLNowPlayingViewManager <NSObject>

-(void)shouldMinimize:(SLQueueNowPlayingView *)nowPlayingView;

@end

@interface SLQueueNowPlayingView : UIView

@property (nonatomic) id<SLNowPlayingViewManager> delegate;
@property (nonatomic) SLSong *song;

@end
