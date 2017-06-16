//
//  SLQueueViewController.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/18/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLQueueTableViewController.h"

@class SLQueueViewController;

@protocol SLQueueManager <NSObject>

- (void)queue:(SLQueueViewController *)queue shouldPlayIndex:(SLQueueIndex)queueIndex;
- (void)queue:(SLQueueViewController *)queue shouldMoveIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex;
- (void)queue:(SLQueueViewController *)queue shouldRemoveIndex:(SLQueueIndex)queueIndex;
- (void)queue:(SLQueueViewController *)queue shouldQueueSong:(SLSong *)song;
- (void)shouldDismissQueue:(SLQueueViewController *)queue;

@end

@interface SLQueueViewController : UIViewController

@property (nonatomic) id<SLQueueManager> delegate;

// State Updates
- (void)updateCurrentSong:(SLSong *)currentSong;
- (void)updateQueue:(SLQueue *)queue;
- (void)updateSongAtIndex:(SLQueueIndex)index;


@end
