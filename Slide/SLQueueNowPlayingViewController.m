//
//  SLQueueNowPlayingViewController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/27/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueNowPlayingViewController.h"
#import "SLQueueNowPlayingView.h"

@interface SLQueueNowPlayingViewController () <SLNowPlayingViewManager>

@end

@implementation SLQueueNowPlayingViewController

- (void)loadView {
    SLQueueNowPlayingView *view = [[SLQueueNowPlayingView alloc] init];
    view.delegate = self;
    self.view = view;
}

- (void)setSong:(SLSong *)song {
    [(SLQueueNowPlayingView *)self.view setSong:song];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shouldMinimize:(SLQueueNowPlayingView *)nowPlayingView {
    [self.delegate shouldMinimize:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
