//
//  SLSearchResultCell.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLSong.h"

@interface SLSearchResultCell : UITableViewCell

@property (nonatomic) SLSong *song;

- (void)addAnimation;

@end
