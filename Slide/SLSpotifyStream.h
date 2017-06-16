//
//  SLSpotifyStream.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLStream.h"

@class SLSpotifyStream;
@protocol SLSpotifyStreamManager <NSObject>

-(void)spotifyStreamInitialized:(SLSpotifyStream *)stream;
-(void)spotifyStream:(SLSpotifyStream *)stream updatedProgress:(NSTimeInterval)progress;
-(void)spotifyStreamFinishedCurrentSong:(SLSpotifyStream *)stream;

@end

typedef void (^SLSpotifySearchCallback)(NSArray<SLSong *> *results);

@interface SLSpotifyStream : NSObject

@property (nonatomic) id<SLSpotifyStreamManager> delegate;

+(instancetype)sharedInstance;
-(BOOL)handleRedirect:(NSURL *)redirect;
-(void)authenticate;

// playback
-(void)updateSong:(SLSong *)song;
-(void)updateProgress:(CGFloat)progress;
-(void)play;
-(void)pause;

// search
-(void)search:(NSString *)query completion:(SLSpotifySearchCallback)completion;

// perf
-(void)prewarm:(NSArray<SLSong *>*)songs;

@end
