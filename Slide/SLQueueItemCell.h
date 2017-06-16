//
//  SLQueueItemCell.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/26/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLStream.h"

@interface SLQueueItemCell : UITableViewCell

@property (nonatomic) SLSong *song;
@property (nonatomic) BOOL hideBorder;

@end
