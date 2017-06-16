//
//  SLQueueViewController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/18/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueViewController.h"
#import "SLQueueTableViewController.h"
#import "SLQueueNowPlayingViewController.h"
#import "SLSearchViewController.h"
#import "SLUXController.h"
#import "SLStream.h"
#import "SLStreamControl.h"


@interface SLQueueViewController () <SLQueueTableManager, SLNowPlayingManager, SLSearchManager, /** TODO: integrate more cleanly */SLStreamControlManager> {
    SLQueueTableViewController *_queueTable;
    SLQueueNowPlayingViewController *_nowPlaying;
    SLSearchViewController *_search;
    
    // TODO: integrate more cleanly
    SLStreamControl *_searchButton;
    UIView *_searchButtonContainer;
}

@end

@implementation SLQueueViewController

#pragma mark State Updates 

- (void)updateCurrentSong:(SLSong *)currentSong {
    _nowPlaying.song = currentSong;
}

- (void)updateQueue:(SLQueue *)queue {
    NSArray <NSMutableArray<SLSong *>*>*data = @[[queue queue].mutableCopy,[queue upNext].mutableCopy];
    _queueTable.data = [data mutableCopy];
}

- (void)updateSongAtIndex:(SLQueueIndex)index {
    [_queueTable updateSongAtIndex:index];
}

#pragma mark Queue Requests

- (void)queueTable:(SLQueueTableViewController *)queueTable requestedIndex:(SLQueueIndex)queueIndex {
    [self.delegate queue:self shouldPlayIndex:queueIndex];
}

- (void)queueTable:(SLQueueTableViewController *)queueTable requestedMoveIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex {
    [self.delegate queue:self shouldMoveIndex:sourceIndex toIndex:targetIndex];
}

- (void)queueTable:(SLQueueTableViewController *)queueTable requestedRemoveIndex:(SLQueueIndex)index {
    [self.delegate queue:self shouldRemoveIndex:index];
}

#pragma mark Now Playing Requests

- (void)shouldMinimize:(SLQueueNowPlayingViewController *)nowPlayingController {
    [self.delegate shouldDismissQueue:self];
}

#pragma mark Search Requests

- (void)searchController:(SLSearchViewController *)searchController requestedSong:(SLSong *)song {
    [self.delegate queue:self shouldQueueSong:song];
}

#pragma mark View

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    view.clipsToBounds = YES;
    
    float nowPlayingHeight = 75.0f;
    _nowPlaying = [[SLQueueNowPlayingViewController alloc] init];
    _nowPlaying.delegate = self;
    _nowPlaying.view.frame = CGRectMake(0, 0, view.frame.size.width, nowPlayingHeight);
    [view addSubview:_nowPlaying.view];
    
    // UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    // blurView.frame = CGRectMake(0, nowPlayingHeight, view.frame.size.width, view.frame.size.height - nowPlayingHeight);
    // [view addSubview:blurView];
    
    _queueTable = [[SLQueueTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _queueTable.delegate = self;
    _queueTable.tableView.frame = CGRectMake(0, nowPlayingHeight, view.frame.size.width, view.frame.size.height - nowPlayingHeight);
    [view addSubview:_queueTable.tableView];
    
    _search = [[SLSearchViewController alloc] init];
    _search.delegate = self;
    
    /** TODO: integrate more cleanly */
    float searchButtonSize = 45.0f;
    _searchButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width - searchButtonSize - 10.0f,
                                                                     nowPlayingHeight/2 - searchButtonSize/2,
                                                                     searchButtonSize, searchButtonSize)];
    _searchButtonContainer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.05f];
    _searchButtonContainer.layer.cornerRadius = 8.0f;
    [view addSubview:_searchButtonContainer];
    
    float searchButtonPadding = 10.0f;
    _searchButton = [SLStreamControl buttonWithIcon:[UIImage imageNamed:@"Design/search_icon.png"]];
    _searchButton.frame = CGRectMake(searchButtonPadding, searchButtonPadding,
                                    searchButtonSize - searchButtonPadding * 2, searchButtonSize - searchButtonPadding * 2);
    _searchButton.tintColor = [UIColor colorWithWhite:0.9f alpha:0.5f];
    _searchButton.delegate = self;
    [_searchButtonContainer addSubview:_searchButton];
    /** END TODO */
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Buttons

/** TODO: integrate more cleanly */

#pragma mark Buttons

- (void)buttonPressed:(SLStreamControl *)button {
    [self presentViewController:_search animated:YES completion:^(void){
        [_search focus];
    }];
}

- (void)toggle:(SLStreamControl *)toggle changedState:(SLStreamControlState)newState {
    
}

- (void)controlWillBeginInteraction:(SLStreamControl *)control {
    
}

- (void)controlWillEndInteraction:(SLStreamControl *)control {
    
}

#pragma mark Stubs

/**
- (void)displayQueue:(BOOL)display animated:(BOOL)animated {
    self.view.userInteractionEnabled = NO;
    
    float targetOpacity;
    CGRect targetQueueFrame, targetNowPlayingFrame;
    BOOL shouldEnableUserInteraction;
    if (display) {
        shouldEnableUserInteraction = YES;
        targetOpacity = 1.0f;
        targetNowPlayingFrame = CGRectMake(0, 0, CGRectGetWidth(_nowPlaying.view.frame), CGRectGetHeight(_nowPlaying.view.frame));
        targetQueueFrame = CGRectMake(0, CGRectGetHeight(_nowPlaying.view.frame), CGRectGetWidth(_queueTable.tableView.frame), CGRectGetHeight(_queueTable.tableView.frame));
    } else {
        shouldEnableUserInteraction = NO;
        targetOpacity = 0.0f;
        targetNowPlayingFrame = CGRectMake(0, self.view.frame.size.height, CGRectGetWidth(_nowPlaying.view.frame), CGRectGetHeight(_nowPlaying.view.frame));
        targetQueueFrame = CGRectMake(0, self.view.frame.size.height + CGRectGetHeight(_nowPlaying.view.frame), CGRectGetWidth(_queueTable.tableView.frame), CGRectGetHeight(_queueTable.tableView.frame));
    }
    
    
    float duration = animated? 0.4f : 0.0f;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         // _nowPlaying.view.layer.opacity = targetOpacity;
                         _queueTable.tableView.frame = targetQueueFrame;
                         _nowPlaying.view.frame = targetNowPlayingFrame;
                     } completion:^(BOOL finished){
                         self.view.userInteractionEnabled = shouldEnableUserInteraction;
                     }];
}

*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
