//
//  SLSearchTableViewController.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLSong.h"

@class SLSearchTableViewController;
@protocol SLSearchTableManager <NSObject>

-(void)searchTable:(SLSearchTableViewController *)searchTable selectedSong:(SLSong *)song;

@end

@interface SLSearchTableViewController : UITableViewController

@property (nonatomic) id<SLSearchTableManager> delegate;
@property (nonatomic) NSArray<SLSong *>*data;

@end
