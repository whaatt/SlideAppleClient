//
//  SLQueueTableViewController.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/18/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLStream.h"

@class SLQueueTableViewController;

@protocol SLQueueTableManager <NSObject>

- (void)queueTable:(SLQueueTableViewController *)queueTable requestedIndex:(SLQueueIndex)queueIndex;
- (void)queueTable:(SLQueueTableViewController *)queueTable requestedMoveIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex;
- (void)queueTable:(SLQueueTableViewController *)queueTable requestedRemoveIndex:(SLQueueIndex)index;

@end

@interface SLQueueTableViewController : UITableViewController

@property (nonatomic) id<SLQueueTableManager> delegate;
@property (nonatomic) NSMutableArray<NSMutableArray<SLSong *>*> *data;

- (void)updateSongAtIndex:(SLQueueIndex)index;

@end
