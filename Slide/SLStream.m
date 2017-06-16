//
//  SLStream.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLStream.h"
#import "SLServer.h"
#import "SLSpotifyStream.h"

#define SYNCHRONIZATION_DELTA 1.0f

static NSString * const kDefaultUsername = @"rooz";
static NSString * const kDefaultUUID = @"1d15df6f-59db-49fe-8384-e12154e91fd0";

//static NSString * const kDefaultUsername = @"sanj";
//static NSString * const kDefaultUUID = @"be06a4e0-3607-48d5-b7ca-54952ebb0b39";

// static NSString * const kDefaultUsername = @"test";
// static NSString * const kDefaultUUID = @"356f021f-75a5-42eb-b9dd-ec4f4d937525";

@interface SLStream () <SLClient, SLSpotifyStreamManager> {
    SLServer *_server;
    
    NSMutableArray <SLSong *>*_history;
    SLSong *_currentSong;
    SLQueue *_queue;
    NSString *_name;
    NSArray <SLPerson *> *_people;
    SLStreamSettings _settings;
    BOOL _paused;
    CGFloat _progress;
    
    SLSpotifyStream *_spotify;
    NSTimer *_playTimer;
}

@end

@implementation SLStream

-(instancetype)initWithNetworkAccess:(BOOL)networkAccess {
    if (self = [super init]) {
        if (networkAccess) {
            _server = [SLServer new];
            _server.client = self;
        }
        
        _history = [[NSMutableArray alloc] init];
        _currentSong = nil;
        _paused = YES;
        _queue = [SLQueue new];
        
        _spotify = [SLSpotifyStream sharedInstance];
        _spotify.delegate = self;
    }
    return self;
}

-(void)setContext:(UIView *)context {
    _server.context = context;
}

#pragma mark Modifiers

-(void)play {
    _paused = NO;
    [_server setPaused:NO];
}

-(void)pause {
    //TODO: Integrate with Server
    _paused = YES;
    [_server setPaused:YES];
}

-(void)updateProgress:(CGFloat)progress {
    if (!self.node) {
        [_server setProgress:progress];
    }
    // server/state maintained when spotify stream returns
    [_spotify updateProgress:progress];
}

-(void)enqueue:(SLSong *)song {
    [_queue enqueue:song];
    [_server setQueue:SLQueueListQueue songs:[_queue queue]];
}

-(void)startSongAtIndex:(SLQueueIndex)index {
    if(_currentSong){
        [_history addObject:_currentSong];
        _currentSong = nil;
    }
    NSArray<SLSong *> *songs = [_queue jumpToIndex:index];
    [_history addObjectsFromArray:songs];
    [self startNextSong];
}

-(void)moveSongAtIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex {
    [_queue moveItemAtIndex:sourceIndex toIndex:targetIndex];
    // TODO: more granular updates
    [_server setQueue:SLQueueListLocked songs:[_queue locked]];
    [_server setQueue:SLQueueListQueue songs:[_queue queue]];
    [_server setQueue:SLQueueListUpNext songs:[_queue upNext]];
}

-(void)startNextSong {
    SLSong *nextSong = [_queue pop];
    if (!nextSong) return; // TODO: integrate with client
    
    if(_currentSong){
        [_history addObject:_currentSong];
    }
    _currentSong = nextSong;
    
    [self updateProgress:0.0f];
    [self streamCurrentSong];
    [_server setCurrentSong:_currentSong];
    // TODO: more granular updates
    [_server setQueue:SLQueueListLocked songs:[_queue locked]];
    [_server setQueue:SLQueueListQueue songs:[_queue queue]];
    [_server setQueue:SLQueueListUpNext songs:[_queue upNext]];
    
}

-(void)startPreviousSong {
    SLSong *previousSong = [_history lastObject];
    if (!previousSong) return; // TODO: integrate with client
    
    if(_currentSong){
        [_queue enqueue:_currentSong];
    }
    if(previousSong){
        [_history removeLastObject];
    }
    _currentSong = previousSong;
    
    [self updateProgress:0.0f];
    [self streamCurrentSong];
    [_server setCurrentSong:_currentSong];
    [_server setQueue:SLQueueListQueue songs:[_queue queue]];
}

-(void)restartCurrentSong {
    [_spotify updateProgress:0.0f];
}

-(void)streamCurrentSong {
    [_spotify pause];
    if (_playTimer) {
        [_playTimer invalidate];
    }
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                 repeats:NO
                                                   block:^(NSTimer *timer){
                                                       [_spotify updateSong:_currentSong];
                                                       if (_paused) {
                                                           [_spotify pause];
                                                       } else {
                                                           [_spotify play];
                                                       }
                                                   }];
    
    }

-(void)updateName:(NSString *)name {
    // TODO: integrate with Slide API
    _name = name;
}

-(void)updateQueue:(SLQueue *)queue {
    // TODO: integrate with Slide API
    _queue = queue;
}

#pragma mark Readonly

-(SLPerson *)currentUser {
    return [SLPerson personWithUsername:kDefaultUsername];
}

-(SLPerson *)host {
    return [SLPerson personWithUsername:_name];
}

-(SLQueue *)queue {
    return _queue;
}

-(NSArray<SLSong *>*)history {
    return (NSArray<SLSong *>*)[_history copy];
}

-(SLSong *)currentSong {
    return _currentSong;
}

-(NSString *)name{
    return _name;
}

-(NSArray<SLPerson *> *)people {
    return _people;
}

-(BOOL)paused {
    return _paused;
}

-(NSTimeInterval)progress {
    return (NSTimeInterval)_progress;
}

#pragma mark Server Delegates

- (void)serverInitialized:(SLServer *)server {
    [_spotify authenticate];
    [_server loginWithUsername:kDefaultUsername UUID:kDefaultUUID];
}

- (void)server:(SLServer *)server loggedIn:(BOOL)success {
    if (success) {
        [self startStream];
        //[_server joinStream:@"rooz"];
    }
}

- (void)server:(SLServer *)server loggedOut:(BOOL)success {
    
}

- (void)server:(SLServer *)server updatedQueue:(SLQueueListType)type withSongs:(NSArray<SLSong *> *)songs {
    [self.queue updateQueueList:type withSongs:songs];
    [self.delegate streamUpdatedQueue:self];
}

- (void)server:(SLServer *)server updatedSongAtIndex:(SLQueueIndex)index {
    [self.delegate stream:self updatedSongAtIndex:index];
}

- (void)server:(SLServer *)server updatedName:(NSString *)name {
    _name = name;
    [self.delegate streamUpdatedName:self];
}

- (void)server:(SLServer *)server updatedPeople:(NSArray<SLPerson *> *)people {
    _people = people;
    [self.delegate streamUpdatedPeople:self];
}

- (void)server:(SLServer *)server updatedSettings:(SLStreamSettings)settings {
    _settings = settings;
    [self.delegate streamUpdatedSettings:self];
}

- (void)server:(SLServer *)server updatedCurrentSong:(SLSong *)song {
    _currentSong = song;
    [self streamCurrentSong];
    [self.delegate streamUpdatedCurrentSong:self];
}

- (void)server:(SLServer *)server updatedPaused:(BOOL)paused {
    _paused = paused;
    if (paused) {
        [_spotify pause];
    } else {
        [_spotify play];
    }
    [self.delegate streamUpdatedPaused:self];
}

- (void)server:(SLServer *)server updatedProgress:(CGFloat)progress {
    NSLog(@"STREAM RECIEVED UPDATE %f AGAINST LOCAL %f", progress, _progress);
    if (self.node) {
        if (progress != _progress) {
            NSLog(@"SERVER UPDATED PROGRESS FORCE!!!");
            _progress = progress;
            [_spotify updateProgress:progress];
        }
        [self.delegate streamUpdatedProgress:self];
    } else if ([self progressShouldSynchronize:progress]) {
        NSLog(@"SERVER RESYNCRONIZED PROGRESS");
        _progress = progress;
        [_spotify updateProgress:progress];
        [self.delegate streamUpdatedProgress:self];
    }
}

#pragma mark Spotify Delegates

-(NSTimeInterval)approximateProgress:(NSTimeInterval)progress {
    return (int)progress; // roundf(100 * progress) / 100;
}

-(void)spotifyStreamInitialized:(SLSpotifyStream *)stream {
    
}

-(void)spotifyStream:(id)stream updatedProgress:(NSTimeInterval)progress {
    NSLog(@"SPOTIFY ATTEMPTED TO UPDATE PROGRESS: %f", progress);
    NSTimeInterval approximateProgress = [self approximateProgress:progress];
    if (_progress == approximateProgress) return;
    
    _progress = approximateProgress;
    NSLog(@"SPOTIFY UPDATED PROGRESS: %f", progress);
    // handle server here
    if (self.node) {
        [_server setProgress:_progress];
    } else {
        [self.delegate streamUpdatedProgress:self];
    }
}

-(void)spotifyStreamFinishedCurrentSong:(SLSpotifyStream *)stream {
    [self startNextSong];
}

#pragma mark Network Utility

- (void)startStream {
    SLStreamSettings settings;
    settings.live = YES;
    settings.hidden = NO;
    settings.autopilot = NO;
    settings.voting = NO;
    settings.limited = NO;
    [_server hostStream:nil settings:settings];
}

#pragma mark Utility

- (BOOL)node {
    return [self.currentUser equalToPerson:self.host];
}

- (BOOL)progressShouldSynchronize:(NSTimeInterval)progress {
    double delta = fabs(progress - _progress);
    return delta > SYNCHRONIZATION_DELTA;
}

#pragma mark Prototyping

-(void)updatePeople:(NSArray<SLPerson *> *)people {
    _people = people;
}

+(SLStream *)generateTemplateStream {
    SLStream *stream = [[SLStream alloc] initWithNetworkAccess:NO];
    [stream updateName:@"party 🎉😏"];
    [stream updatePeople:@[[SLPerson personWithUsername:@"rooz"],
                           [SLPerson personWithUsername:@"ramos"],
                           [SLPerson personWithUsername:@"sanj"],
                           [SLPerson personWithUsername:@"breezy"],
                           [SLPerson personWithUsername:@"nmgoel"],
                           [SLPerson personWithUsername:@"kgainey"],
                           [SLPerson personWithUsername:@"csimmons"],
                           [SLPerson personWithUsername:@"harrym"],
                           [SLPerson personWithUsername:@"jseaton"],
                           [SLPerson personWithUsername:@"nikki"],
                           [SLPerson personWithUsername:@"gio"],
                           [SLPerson personWithUsername:@"klynch"]]];
    
    SLQueue *queue = [SLQueue new];
    SLSong *s1 = [SLSong songWithTitle:@"Hey Mama"
                                artist:@"Kanye West"
                                 album:@"Late Registration"
                               artwork:[UIImage imageNamed:@"Design/Templates/registration.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s2 = [SLSong songWithTitle:@"Good Morning"
                                artist:@"Kanye West"
                                 album:@"Graduation"
                               artwork:[UIImage imageNamed:@"Design/Templates/graduation.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s3 = [SLSong songWithTitle:@"School Spirit"
                                artist:@"Kanye West"
                                 album:@"College Dropout"
                               artwork:[UIImage imageNamed:@"Design/Templates/dropout.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s4 = [SLSong songWithTitle:@"Wesley's Theory"
                                artist:@"Kendrick Lamar"
                                 album:@"To Pimp a Butterfly"
                               artwork:[UIImage imageNamed:@"Design/Templates/butterfly.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s5 = [SLSong songWithTitle:@"Good Ass Intro"
                                artist:@"Chance The Rapper"
                                 album:@"Acid Rap"
                               artwork:[UIImage imageNamed:@"Design/Templates/acid.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s6 = [SLSong songWithTitle:@"Hey Ma"
                                artist:@"Chance The Rapper"
                                 album:@"10 Day"
                               artwork:[UIImage imageNamed:@"Design/Templates/10day.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s7 = [SLSong songWithTitle:@"Jesus Walks"
                                artist:@"Kanye West"
                                 album:@"College Dropout"
                               artwork:[UIImage imageNamed:@"Design/Templates/dropout.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s8 = [SLSong songWithTitle:@"Amazing"
                                artist:@"Kanye West"
                                 album:@"808s and Heartbreak"
                               artwork:[UIImage imageNamed:@"Design/Templates/heartbreak.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s9 = [SLSong songWithTitle:@"King Kunta"
                                artist:@"Kendrick Lamar"
                                 album:@"To Pimp a Butterfly"
                               artwork:[UIImage imageNamed:@"Design/Templates/butterfly.jpg"]
                              duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s10 = [SLSong songWithTitle:@"Roses"
                                 artist:@"Kanye West"
                                  album:@"Late Registration"
                                artwork:[UIImage imageNamed:@"Design/Templates/registration.jpg"]
                               duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s11 = [SLSong songWithTitle:@"Stronger"
                                 artist:@"Kanye West"
                                  album:@"Graduation"
                                artwork:[UIImage imageNamed:@"Design/Templates/graduation.jpg"]
                               duration:(60.0f * 3.0f + 20.0f)];
    SLSong *s12 = [SLSong songWithTitle:@"Cocoa Butter Kisses"
                                 artist:@"Chance The Rapper"
                                  album:@"Acid Rap"
                                artwork:[UIImage imageNamed:@"Design/Templates/acid.jpg"]
                               duration:(60.0f * 3.0f + 20.0f)];
        
    [queue updateQueueList:SLQueueListQueue withSongs:@[s1, s2, s3, s4, s5]];
    [queue updateQueueList:SLQueueListUpNext withSongs:@[s6, s7, s8, s9, s10, s11, s12]];
    
    [stream updateQueue:queue];
    return stream;
}



-(void)broadcast {
    // [[NSNotificationCenter defaultCenter] postNotificationName:kStreamUpdateNotification object:self userInfo:nil];
}

@end
