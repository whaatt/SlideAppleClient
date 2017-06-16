//
//  SLServer.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/4/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServer.h"
#import "SLServerStreamData.h"
#import "SLServerStreamList.h"
#import "SLServerUpdateQueue.h"
#import "SLServerExpectationQueue.h"
#import "SLServerTrackData.h"
#import "SLServerCurrentTrack.h"
#import <WebKit/WebKit.h>

typedef void (^SLDynamicClientCallback)(WKScriptMessage *);

static NSString * const kCallbackClientCreated = @"clientCreated";
static NSString * const kCallbackClientLoggedIn = @"clientLoggedIn";
static NSString * const kCallbackClientLoggedOut = @"clientLoggedOut";
static NSString * const kCallbackClientHostedStream = @"clientHostedStream";
static NSString * const kCallbackClientJoinedStream = @"clientJoinedStream";
static NSString * const kCallbackClientLeftStream = @"clientLeftStream";
static NSString * const kCallbackClientKilledStream = @"clientKilledStream";
static NSString * const kCallbackClientRegisteredTrack = @"clienRegisteredTrack";

static NSString * const kCallbackClientRegisteredStreamCallbacks = @"clientRegisteredStreamCallbacks";
static NSString * const kCallbackClientRegisteredTrackCallbacks = @"clientRegisteredTrackCallbacks";
static NSString * const kCallbackClientSetCurrentSong = @"clientSetCurrentSong";
static NSString * const kCallbackClientSetStreamList = @"clientSetStreamList";
static NSString * const kCallbackClientVotedOnSong = @"clientVotedOnSong";

static NSString * const kCallbackClientUpdatedStreamData = @"clientUpdatedStreamData";
static NSString * const kCallbackClientUpdatedTrackData = @"clientUpdatedTrackData";
static NSString * const kCallbackClientUpdatedStreamLockedList = @"clientUpdatedStreamLockedList";
static NSString * const kCallbackClientUpdatedStreamQueueList = @"clientUpdatedStreamQueueList";
static NSString * const kCallbackClientUpdatedStreamAutoplayList = @"clientUpdatedStreamAutoplayList";
static NSString * const kCallbackClientUpdatedStreamSuggestionList = @"clientUpdatedStreamSuggestionList";

@interface SLServer () <WKScriptMessageHandler, WKNavigationDelegate> {
    WKWebView *_v8;
    
    SLServerStreamData *_dataCache;
    SLServerStreamList *_queueListCache;
    SLServerStreamList *_lockedListCache;
    SLServerStreamList *_upNextListCache;
    SLServerStreamList *_suggestionsListCache;
    SLServerCurrentTrack *_nowPlayingCache;
    
    NSMutableDictionary *_dynamicCallbacks;
    WKUserContentController *_scriptEngine;
    
    // updates
    SLServerUpdateQueue *_queueListUpdateQueue;
    SLServerUpdateQueue *_upNextListUpdateQueue;
    SLServerUpdateQueue *_lockedListUpdateQueue;
    SLServerUpdateQueue *_suggestionsListUpdateQueue;
    SLServerUpdateQueue *_trackDataUpdateQueue;
    SLServerUpdateQueue *_trackStateUpdateQueue;
    SLServerUpdateQueue *_trackProgressUpdateQueue;
    // expectations
    SLServerExpectationQueue *_queueListExpectationQueue;
    SLServerExpectationQueue *_upNextListExpectationQueue;
    SLServerExpectationQueue *_lockedListExpectationQueue;
    SLServerExpectationQueue *_suggestionsListExpectationQueue;
    SLServerExpectationQueue *_trackDataExpectationQueue;
    SLServerExpectationQueue *_trackStateExpectationQueue;
    SLServerExpectationQueue *_trackProgressExpectationQueue;
}

@end

@implementation SLServer

#pragma mark Initialization

-(instancetype)init {
    if (self = [super init]) {
        // initialize list caches
        _queueListCache = [SLServerStreamList emptyListForType:SLQueueListQueue];
        _lockedListCache = [SLServerStreamList emptyListForType:SLQueueListLocked];
        _upNextListCache = [SLServerStreamList emptyListForType:SLQueueListUpNext];
        _suggestionsListCache = [SLServerStreamList emptyListForType:SLQueueListSuggestions];
        _dynamicCallbacks = [[NSMutableDictionary alloc] init];
        
        [self initializeUpdateQueues];
        [self loadAPI];
    } 
    return self;
}

-(void)initializeUpdateQueues {
    _queueListUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _queueListExpectationQueue = [[SLServerExpectationQueue alloc] init];
    
    _upNextListUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _upNextListExpectationQueue = [[SLServerExpectationQueue alloc] init];
    
    _lockedListUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _lockedListExpectationQueue = [[SLServerExpectationQueue alloc] init];
    
    _suggestionsListUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _suggestionsListExpectationQueue = [[SLServerExpectationQueue alloc] init];
    
    _trackDataUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _trackDataExpectationQueue = [[SLServerExpectationQueue alloc] init];
    
    _trackStateUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _trackStateExpectationQueue = [[SLServerExpectationQueue alloc] init];
    
    _trackProgressUpdateQueue = [[SLServerUpdateQueue alloc] init];
    _trackProgressExpectationQueue = [[SLServerExpectationQueue alloc] init];
}

-(void)dealloc {
    //NSLog(@"FATAL: Server Died.");
}

-(void)loadAPI {
    /** v8 Configuration */
    _scriptEngine = [[WKUserContentController alloc] init];
    
    /** Register callbacks */
    
    // meta
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientCreated];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientLoggedIn];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientLoggedOut];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientHostedStream];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientJoinedStream];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientLeftStream];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientKilledStream];
    
    // registers
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientRegisteredTrack];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientRegisteredTrackCallbacks];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientRegisteredStreamCallbacks];
    
    // proactive
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientSetCurrentSong];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientSetStreamList];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientVotedOnSong];
    
    // reactive
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientUpdatedStreamData];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientUpdatedTrackData];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientUpdatedStreamLockedList];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientUpdatedStreamQueueList];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientUpdatedStreamAutoplayList];
    [_scriptEngine addScriptMessageHandler:self name:kCallbackClientUpdatedStreamSuggestionList];
    
    /** Other Config */
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = _scriptEngine;
    
    _v8 = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    // embed in persistent view-context
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window]; // TODO: investigate
    [window addSubview:_v8];
    _v8.navigationDelegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"client-api" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@", html);
    [_v8 loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //NSLog(@"Finished Loading");
    [self initialize];
}

-(void)setContext:(UIView *)context {
    if(_v8.superview) [_v8 removeFromSuperview];
    [context addSubview:_v8];
}

#pragma mark Callbacks

/** Switchboard */

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // NSLog(@"Message Received: '%@': %@", message.name, message.body);
    
    if (message.name == kCallbackClientCreated) {
        [self clientCreated:message];
    } else if (message.name == kCallbackClientLoggedIn) {
        [self clientLoggedIn:message];
    } else if (message.name == kCallbackClientLoggedOut) {
        [self clientLoggedOut:message];
    } else if (message.name == kCallbackClientHostedStream) {
        [self clientHostedStream:message];
    } else if (message.name == kCallbackClientJoinedStream) {
        [self clientJoinedStream:message];
    } else if (message.name == kCallbackClientLeftStream) {
        [self clientLeftStream:message];
    } else if (message.name == kCallbackClientKilledStream) {
        [self clientKilledStream:message];
    } else if (message.name == kCallbackClientRegisteredTrack) {
        [self clientRegisteredTrack:message];
    } else if (message.name == kCallbackClientRegisteredTrackCallbacks) {
        [self clientRegisteredTrackCallbacks:message];
    } else if (message.name == kCallbackClientRegisteredStreamCallbacks) {
        [self clientRegisteredStreamCallbacks:message];
    } else if (message.name == kCallbackClientSetCurrentSong) {
        [self clientSetCurrentSong:message];
    } else if (message.name == kCallbackClientSetStreamList) {
        [self clientSetStreamList:message];
    } else if (message.name == kCallbackClientVotedOnSong) {
        [self clientVotedOnSong:message];
    } else if (message.name == kCallbackClientUpdatedStreamData) {
        [self clientUpdatedStreamData:message];
    } else if (message.name == kCallbackClientUpdatedTrackData) {
        [self clientUpdatedTrackData:message];
    } else if (message.name == kCallbackClientUpdatedStreamQueueList) {
        [self clientUpdatedStreamQueueList:message];
    } else if (message.name == kCallbackClientUpdatedStreamLockedList) {
        [self clientUpdatedStreamLockedList:message];
    } else if (message.name == kCallbackClientUpdatedStreamAutoplayList) {
        [self clientUpdatedStreamAutoplayList:message];
    } else if (message.name == kCallbackClientUpdatedStreamSuggestionList) {
        [self clientUpdatedStreamSuggestionList:message];
    } else {
        SLDynamicClientCallback dynamicCallback = _dynamicCallbacks[message.name];
        if (dynamicCallback) {
            dynamicCallback(message);
            [_dynamicCallbacks removeObjectForKey:message.name];
        }
    }
}

/** Callbacks */

-(void)clientCreated:(WKScriptMessage *)message {
    
}

-(void)clientLoggedIn:(WKScriptMessage *)message {
    [self.client server:self loggedIn:YES];
}

-(void)clientLoggedOut:(WKScriptMessage *)message {
    [self.client server:self loggedOut:YES];
}

-(void)clientHostedStream:(WKScriptMessage *)message {
   
}

-(void)clientJoinedStream:(WKScriptMessage *)message {
    
}

-(void)clientLeftStream:(WKScriptMessage *)message {
    
}

-(void)clientKilledStream:(WKScriptMessage *)message {
    
}

-(void)clientRegisteredTrack:(WKScriptMessage *)message {
    
}

-(void)clientRegisteredTrackCallbacks:(WKScriptMessage *)message {
    
}

-(void)clientRegisteredStreamCallbacks:(WKScriptMessage *)message {
    
}

-(void)clientSetCurrentSong:(WKScriptMessage *)message {
    
}

-(void)clientSetStreamList:(WKScriptMessage *)message {
    
}

-(void)clientVotedOnSong:(WKScriptMessage *)message {
    
}

-(void)clientUpdatedStreamData:(WKScriptMessage *)message {
    SLServerStreamData *data = [SLServerStreamData parse:message.body[@"data"]];
    SLStreamUpdateType updates;
    if (_dataCache) {
         updates = [_dataCache inferUpdates:data];
    } else {
        // all updates
        updates = SLStreamUpdateName | SLStreamUpdatePeople | SLStreamUpdateProgress | SLStreamUpdatePaused | SLStreamUpdateCurrentSong | SLStreamUpdateSettings;
    }
    _dataCache = data;
    
    if (updates & SLStreamUpdateName) {
        [self.client server:self updatedName:data.name];
    }
    if (updates & SLStreamUpdateCurrentSong) {
        if (![_trackDataExpectationQueue expected:data.currentTrack.trackData]) {
            NSLog(@"UNEXPECTED NEW SONG");
            [self.client server:self updatedCurrentSong:[data.currentTrack.trackData song]];
        }
    }
    if (updates & SLStreamUpdatePaused) {
        if (![_trackStateExpectationQueue expected:data.currentTrack.state]) {
            NSLog(@"UNEXPECTED NEW STATE");
            BOOL paused = (data.currentTrack.state.state == SLServerCurrentTrackPaused)? YES : NO;
            [self.client server:self updatedPaused:paused];
        }
    }
    if (updates & SLStreamUpdateProgress) {
        if (![_trackProgressExpectationQueue expected:data.currentTrack.progress]) {
            NSLog(@"UNEXPECTED NEW PROGRESS: %f", data.currentTrack.progress.progress);
            [self.client server:self updatedProgress:data.currentTrack.progress.progress];
        }
    }
    if (updates & SLStreamUpdatePeople) {
        [self.client server:self updatedPeople:data.people];
    }
    if (updates & SLStreamUpdateSettings) {
        [self.client server:self updatedSettings:data.settings];
    }
}

-(void)clientUpdatedTrackData:(WKScriptMessage *)message {
    SLQueueIndex index = [self findSongInCache:message.body[@"locator"]];
    if (index.position != -1) {
        SLSong *song = [self songAtCacheIndex:index];
        song.upvotes = [message.body[@"score"] intValue];
        SLServerTrackData *trackData = [SLServerTrackData parse:message.body[@"data"][@"trackData"]];
        [trackData updateSong:song];
        [self.client server:self updatedSongAtIndex:index];
    } //else //NSLog(@"Error: Song not in cache.");
}

-(void)clientUpdatedStreamQueueList:(WKScriptMessage *)message {
    SLServerStreamList *updatedList = [SLServerStreamList parse:(NSArray *)message.body[@"data"]];
    updatedList.type = SLQueueListQueue;
    [self clientUpdatedList:updatedList];
}

-(void)clientUpdatedStreamLockedList:(WKScriptMessage *)message {
    SLServerStreamList *updatedList = [SLServerStreamList parse:(NSArray *)message.body[@"data"]];
    updatedList.type = SLQueueListLocked;
    [self clientUpdatedList:updatedList];
}

-(void)clientUpdatedStreamSuggestionList:(WKScriptMessage *)message {
    SLServerStreamList *updatedList = [SLServerStreamList parse:(NSArray *)message.body[@"data"]];
    updatedList.type = SLQueueListSuggestions;
    [self clientUpdatedList:updatedList];
}

-(void)clientUpdatedStreamAutoplayList:(WKScriptMessage *)message {
    SLServerStreamList *updatedList = [SLServerStreamList parse:(NSArray *)message.body[@"data"]];
    updatedList.type = SLQueueListUpNext;
    [self clientUpdatedList:updatedList];
}

-(void)clientUpdatedList:(SLServerStreamList *)updatedList{
    SLServerStreamList *cache = [self cacheForListType:updatedList.type];
    NSArray<NSArray<SLSong *>*> *updates = [cache inferUpdates:updatedList];
    NSArray<SLSong *> *newList = updates[0];
    NSArray<SLSong *> *additions = updates[1];
    NSArray<SLSong *> *removals = updates[2];
    [self addTrackCallbacks:additions removeTrackCallbacks:removals];
    
    if ([[self expectationQueueForListType:updatedList.type] expected:updatedList]) {
        return;
    }
        
    [self setCache:(SLServerStreamList *)[[SLServerStreamList alloc] initWithType:updatedList.type songs:newList]
                                                                     forListType:updatedList.type];
    [self.client server:self updatedQueue:updatedList.type withSongs:newList];
}

#pragma mark Public

-(void)initialize {
    NSString *js = [NSString stringWithFormat:@"var Client = new SlideClient(\"wss://slide.ga\", \"%@\", true);", kCallbackClientCreated];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
        [self.client serverInitialized:self];
    }];
}

-(void)loginWithUsername:(NSString *)username UUID:(NSString *)UUID {
    NSString *js = [NSString stringWithFormat:@"Client.login(\"%@\", \"%@\", \"%@\");", username, UUID, kCallbackClientLoggedIn];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(void)logout {
    NSString *js = [NSString stringWithFormat:@"Client.logout(\"%@\");", kCallbackClientLoggedOut];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(void)hostStream:(NSString *)name settings:(SLStreamSettings)settings {
    NSString *js = [NSString stringWithFormat:@"Client.stream(%@, %@, \"%@\");",
                    [self generateStreamSettings:settings],
                    [self generateStreamCallbacks],
                    kCallbackClientHostedStream];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(void)joinStream:(NSString *)name {
    NSString *js = [NSString stringWithFormat:@"Client.join(\"%@\", %@, \"%@\", \"%@\");",
                    name,
                    [self generateStreamCallbacks],
                    kCallbackClientKilledStream,
                    kCallbackClientJoinedStream];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(void)leaveStream {
    NSString *js = [NSString stringWithFormat:@"Client.leave(false, \"%@\");",
                    kCallbackClientLeftStream];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(void)setQueue:(SLQueueListType)queue songs:(NSArray<SLSong *> *)songs {
    SLServerStreamList *updatedList = [[SLServerStreamList alloc] initWithType:queue songs:songs];
    SLServerStreamList *cache = [self cacheForListType:queue];
    NSArray<NSArray<SLSong *>*> *updates = [cache inferUpdates:updatedList];
    NSArray<SLSong *> *newList = updates[0];
    NSArray<SLSong *> *additions = updates[1];
    NSArray<SLSong *> *removals = updates[2];
    updatedList = [[SLServerStreamList alloc] initWithType:queue songs:newList];
    [self addTrackCallbacks:nil removeTrackCallbacks:removals];
    
    if ([additions count] > 0) {
         // all additions necessarily have missing or invalid identifiers
        for (SLSong *new in additions) {
            new.identifier = nil;
            [self createTrack:new inList:updatedList];
        }
    }
    
    SLServerUpdateOperation *update = [SLServerUpdateOperation new];
    update.executionDelegate = updatedList;
    update.operation =  ^(void){
        [self submitStreamList:updatedList];
    };
    [[self updateQueueForListType:updatedList.type] push:update];
}

-(void)setCurrentSong:(SLSong *)song {
    SLServerTrackData *trackData = [[SLServerTrackData alloc] initWithSong:song];
    
    SLServerUpdateOperation *update = [SLServerUpdateOperation new];
    update.executionDelegate = trackData;
    update.operation =  ^(void){
        [self submitTrackData:trackData];
    };
    [_trackDataUpdateQueue push:update];
}

-(void)setProgress:(NSTimeInterval)progress {
    SLServerTrackProgress *trackProgress = [[SLServerTrackProgress alloc] initWithProgress:progress];
    
    SLServerUpdateOperation *update = [SLServerUpdateOperation new];
    update.executionDelegate = trackProgress;
    update.operation =  ^(void){
        [self submitTrackProgress:trackProgress];
    };
    [_trackProgressUpdateQueue push:update];
}

-(void)setPaused:(BOOL)paused {
    SLServerTrackState *trackState = [[SLServerTrackState alloc] initWithState:(paused? SLServerCurrentTrackPaused : SLServerCurrentTrackPlaying)];
    
    SLServerUpdateOperation *update = [SLServerUpdateOperation new];
    update.executionDelegate = trackState;
    update.operation =  ^(void){
        [self submitTrackState:trackState];
    };
    [_trackStateUpdateQueue push:update];
}

-(void)upvote:(BOOL)upvote song:(SLSong *)song inQueue:(SLQueueListType)queue {
    NSString *js = [NSString stringWithFormat:@"Client.voteOnTrack(\"%@\", %@, \"%@\", \"%@\");",
                    song.identifier,
                    [self convertBooleanToString:upvote],
                    [SLServerStreamList convertQueueListTypeToString:queue],
                    kCallbackClientVotedOnSong];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

#pragma mark Private

-(void)submitTrackProgress:(SLServerTrackProgress *)trackProgress {
    [self.client server:self updatedProgress:trackProgress.progress];
    NSLog(@"Submitting track progress: %f", trackProgress.progress);
    [_trackProgressExpectationQueue push:trackProgress];
    
    SLServerCurrentTrack *currentTrack = [[SLServerCurrentTrack alloc] initWithTrackData:_dataCache.currentTrack.trackData
                                                                                progress:trackProgress
                                                                                   state:_dataCache.currentTrack.state];
    
    [self submitStreamCurrentTrack:currentTrack];
    
}

-(void)submitTrackState:(SLServerTrackState *)trackState {
    [self.client server:self updatedPaused:(trackState.state == SLServerCurrentTrackPaused)];
    [_trackStateExpectationQueue push:trackState];
    
    SLServerCurrentTrack *currentTrack = [[SLServerCurrentTrack alloc] initWithTrackData:_dataCache.currentTrack.trackData
                                                                                progress:_dataCache.currentTrack.progress
                                                                                   state:trackState];
    
    [self submitStreamCurrentTrack:currentTrack];
}

-(void)submitTrackData:(SLServerTrackData *)trackData {
    [self.client server:self updatedCurrentSong:[trackData song]];
    [_trackDataExpectationQueue push:trackData];
    
    SLServerCurrentTrack *currentTrack = [[SLServerCurrentTrack alloc] initWithTrackData:trackData
                                                                                progress:[[SLServerTrackProgress alloc] initWithProgress:0.0f]
                                                                                   state:_dataCache.currentTrack.state];
    [self submitStreamCurrentTrack:currentTrack];
}

-(void)submitStreamCurrentTrack:(SLServerCurrentTrack *)currentTrack {
    NSString *state = (currentTrack.state.state == SLServerCurrentTrackPaused)? @"paused" : @"playing";
    NSString *js = [NSString stringWithFormat:@"Client.playTrack(%@, %f, \"%@\", \"%@\");",
                    [currentTrack.trackData serialize],
                    currentTrack.progress.progress,
                    state,
                    kCallbackClientSetCurrentSong];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(void)submitStreamList:(SLServerStreamList *)list {
    NSString *js = [NSString stringWithFormat:@"Client.editStreamList(\"%@\", %@, %@, \"%@\");",
                    [SLServerStreamList convertQueueListTypeToString:list.type],
                    [[self cacheForListType:list.type] serialize],
                    [list serialize],
                    kCallbackClientSetStreamList];
    
    // update cache now, will be reset on error
    [self setCache:list forListType:list.type];
    [self.client server:self updatedQueue:list.type withSongs:list.list];
    [[self expectationQueueForListType:list.type] push:list];
    
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(NSString *)generateTrackCallback:(SLSong *)track forList:(SLServerStreamList *)list {
    NSString *name = [[NSProcessInfo processInfo] globallyUniqueString];
    SLDynamicClientCallback trackCreated = ^void(WKScriptMessage *message) {
        track.identifier = message.body[@"data"];
        if ([list readyForUpdate])
            [[self updateQueueForListType:list.type] run];
    };
    _dynamicCallbacks[name] = trackCreated;
    [_scriptEngine addScriptMessageHandler:self name:name];
    return name;
}

-(void)createTrack:(SLSong *)track inList:(SLServerStreamList *)list {
    NSString *callback = [self generateTrackCallback:track forList:list];
    NSString *js = [NSString stringWithFormat:@"Client.createTrack(%@, \"%@\");",
                    [[[SLServerTrackData alloc] initWithSong:track] serialize],
                    callback];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}


-(void)addTrackCallbacks:(NSArray<SLSong *>*)addTracks removeTrackCallbacks:(NSArray<SLSong *>*)removeTracks {
    NSString *js = [NSString stringWithFormat:@"Client.setTrackCallbacks(%@, %@, \"%@\");",
                    [self generateTrackCallbacks:addTracks],
                    [self generateTrackLocators:removeTracks],
                    kCallbackClientRegisteredTrackCallbacks];
    //NSLog(@"js call: %@", js);
    [_v8 evaluateJavaScript:js completionHandler:^(id result, NSError *error){
        //NSLog(@"Evaluated: %@", error);
    }];
}

-(NSString*)generateTrackCallbacks:(NSArray<SLSong *>*)tracks {
    NSMutableString *map = [[NSMutableString alloc] init];
    for(SLSong *track in tracks){
        [map appendFormat:@"\"%@\":\"%@\",", track.identifier, kCallbackClientUpdatedTrackData];
    }
    return [NSString stringWithFormat:@"{%@}", map];
}

-(NSString*)generateTrackLocators:(NSArray<SLSong *>*)tracks {
    NSMutableString *map = [[NSMutableString alloc] init];
    for(SLSong *track in tracks){
        [map appendFormat:@"\"%@\",", track.identifier];
    }
    return [NSString stringWithFormat:@"[%@]", map];
}

-(NSString *)generateStreamSettings:(SLStreamSettings)settings {
    return [NSString stringWithFormat:
            @"{live: %@, privateMode: %@, voting: %@, autopilot: %@, limited: %@}",
            [self convertBooleanToString:settings.live],
            [self convertBooleanToString:settings.hidden],
            [self convertBooleanToString:settings.voting],
            [self convertBooleanToString:settings.autopilot],
            [self convertBooleanToString:settings.limited]];
}

-(NSString *)generateStreamCallbacks {
    return [NSString stringWithFormat:
                     @"{streamData: \"%@\", locked: \"%@\", queue: \"%@\", autoplay: \"%@\", suggestion: \"%@\"}",
                     kCallbackClientUpdatedStreamData,
                     kCallbackClientUpdatedStreamLockedList,
                     kCallbackClientUpdatedStreamQueueList,
                     kCallbackClientUpdatedStreamAutoplayList,
                     kCallbackClientUpdatedStreamSuggestionList];
}

-(SLSong *)songAtCacheIndex:(SLQueueIndex)index {
    SLServerStreamList *target = [self cacheForListType:index.list];
    return [target.list objectAtIndex:index.position];
}

-(SLQueueIndex)findSongInCache:(NSString *)identifier {
    NSInteger position = [_queueListCache findSong:identifier];
    SLQueueListType list = SLQueueListQueue;
    if (position == -1) {
        position = [_upNextListCache findSong:identifier];
        list = SLQueueListUpNext;
        if (position == -1) {
            position = [_lockedListCache findSong:identifier];
            list = SLQueueListLocked;
            if (position == -1) {
                position = [_suggestionsListCache findSong:identifier];
                list = SLQueueListSuggestions;
            }
        }
    }
    
    SLQueueIndex index;
    index.list = list;
    index.position = position;
    return index;
}

-(SLServerStreamList *)cacheForListType:(SLQueueListType)type {
    if (type == SLQueueListLocked) return _lockedListCache;
    if (type == SLQueueListUpNext) return _upNextListCache;
    if (type == SLQueueListSuggestions) return _suggestionsListCache;
    return _queueListCache;
}

-(SLServerUpdateQueue *)updateQueueForListType:(SLQueueListType)type {
    if (type == SLQueueListLocked) return _lockedListUpdateQueue;
    if (type == SLQueueListUpNext) return _upNextListUpdateQueue;
    if (type == SLQueueListSuggestions) return _suggestionsListUpdateQueue;
    return _queueListUpdateQueue;
}

-(SLServerExpectationQueue *)expectationQueueForListType:(SLQueueListType)type {
    if (type == SLQueueListLocked) return _lockedListExpectationQueue;
    if (type == SLQueueListUpNext) return _upNextListExpectationQueue;
    if (type == SLQueueListSuggestions) return _suggestionsListExpectationQueue;
    return _queueListExpectationQueue;
}

-(void)setCache:(SLServerStreamList *)cache forListType:(SLQueueListType)type {
    if (type == SLQueueListLocked) _lockedListCache = cache;
    else if (type == SLQueueListUpNext) _upNextListCache = cache;
    else if (type == SLQueueListSuggestions) _suggestionsListCache = cache;
    else _queueListCache = cache;
}

#pragma mark Utility

-(NSString *)convertBooleanToString:(BOOL)boolean {
    NSString *string = boolean? @"true" : @"false";
    return string;
}

@end
