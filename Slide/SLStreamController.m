//
//  SLStreamController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLStreamController.h"
#import "SLQueueViewController.h"
#import "SLQueueTableView.h"
#import "SLPlayerView.h"
#import "SLStream.h"

@interface SLStreamController () <SLQueueManager, SLPlayerManager, SLStreamManager> {
    SLStream *_stream;
    
    SLQueueViewController *_queueController;
    SLPlayerView *_playerView;
    
    UIView *_queueView; // for preloading
}

@end

@implementation SLStreamController

- (instancetype)init{
    if (self = [super init]) {
        _stream = [[SLStream alloc] initWithNetworkAccess:YES];
        _stream.delegate = self;

        _queueController = [[SLQueueViewController alloc] init];
        _queueController.delegate = self;
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    
    _playerView = [[SLPlayerView alloc] initWithFrame:view.frame];
    _playerView.clipsToBounds = YES;
    _playerView.delegate = self;
    [view addSubview:_playerView];
    
    _queueView = _queueController.view; // pre-load the queue view
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_playerView updateStreamMetadata:_stream];
    [_queueController updateCurrentSong:_stream.currentSong];
    [_queueController updateQueue:_stream.queue];
    /**[UIView animateWithDuration:0.0f delay:2.0f options:0 animations:^(){} completion:^(BOOL finished){
        //[(SLStreamView *)self.view play];
    }];*/
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Queue Updates

- (void)queue:(SLQueueViewController *)queue shouldPlayIndex:(SLQueueIndex)queueIndex {
    [_stream startSongAtIndex:queueIndex];
}

- (void)queue:(SLQueueViewController *)queue shouldRemoveIndex:(SLQueueIndex)queueIndex {
    
}

- (void)queue:(SLQueueViewController *)queue shouldMoveIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex {
    [_stream moveSongAtIndex:sourceIndex toIndex:targetIndex];
}

- (void)queue:(SLQueueViewController *)queue shouldQueueSong:(SLSong *)song {
    [_stream enqueue:song];
}

- (void)shouldDismissQueue:(SLQueueViewController *)queue {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Player Updates

- (void)playerShouldPlay:(SLPlayerView *)player {
    [_stream play];
}

- (void)playerShouldPause:(SLPlayerView *)player {
    [_stream pause];
}

- (void)playerShouldPlayNextSong:(SLPlayerView *)player {
    [_stream startNextSong];
}

- (void)playerShouldPlayPreviousSong:(SLPlayerView *)player {
    [_stream startPreviousSong];
}

- (void)playerShouldReplayCurrentSong:(SLPlayerView *)player {
    [_stream restartCurrentSong];
}

- (void)player:(SLPlayerView *)player shouldChangeProgress:(CGFloat)progress {
    [_stream updateProgress:progress];
}

- (void)playerShouldDisplayQueue:(SLPlayerView *)player {
    [self displayQueue];
}

#pragma mark Stream Updates

- (void)streamUpdatedName:(SLStream *)stream {
    [_playerView updateStreamMetadata:_stream];
}

- (void)streamUpdatedPeople:(SLStream *)stream {
    [_playerView updateStreamMetadata:_stream];
}

- (void)streamUpdatedPaused:(SLStream *)stream {
    if (stream.paused) [_playerView pause];
    else [_playerView play];
}

- (void)streamUpdatedCurrentSong:(SLStream *)stream {
    [_playerView updateSong:_stream.currentSong];
    [_queueController updateCurrentSong:_stream.currentSong];
}

- (void)streamUpdatedProgress:(SLStream *)stream {
    [_playerView updateProgress:(CGFloat)stream.progress];
}

- (void)streamUpdatedQueue:(SLStream *)stream {
     [_queueController updateQueue:_stream.queue];
}

- (void)stream:(SLStream *)stream updatedSongAtIndex:(SLQueueIndex)index {
    [_queueController updateSongAtIndex:index];
}

- (void)streamUpdatedSettings:(SLStream *)stream {
    
}

#pragma mark Active View

- (void)displayQueue {
    [self presentViewController:_queueController animated:YES completion:nil];
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
