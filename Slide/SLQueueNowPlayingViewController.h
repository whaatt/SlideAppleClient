//
//  SLQueueNowPlayingViewController.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/27/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLStream.h"

@class SLQueueNowPlayingViewController;

@protocol SLNowPlayingManager <NSObject>

-(void)shouldMinimize:(SLQueueNowPlayingViewController *)nowPlayingController;

@end

@interface SLQueueNowPlayingViewController : UIViewController

@property (nonatomic) id<SLNowPlayingManager> delegate;
@property (nonatomic) SLSong *song;

@end
