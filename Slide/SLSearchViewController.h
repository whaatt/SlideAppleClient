//
//  SLSearchViewController.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLSong.h"

@class SLSearchViewController;
@protocol SLSearchManager <NSObject>

-(void)searchController:(SLSearchViewController *)searchController requestedSong:(SLSong *)song;

@end

@interface SLSearchViewController : UIViewController

@property (nonatomic) id<SLSearchManager> delegate;

-(void)focus;

@end
