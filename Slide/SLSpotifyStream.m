//
//  SLSpotifyStream.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLSpotifyStream.h"
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SafariServices/SafariServices.h>

#define BYTES_PER_MEGABYTE 1024
#define CACHE_SIZE BYTES_PER_MEGABYTE * 100

@interface SLSpotifyStream () <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate> {
    BOOL _paused;
    
}

@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) UIViewController *authController;
@property (nonatomic, strong) SPTAudioStreamingController *stream;
@property (nonatomic, strong) SPTDiskCache *cache;

@end

@implementation SLSpotifyStream

+(instancetype)sharedInstance {
    static SLSpotifyStream *sharedSpotifyStream = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSpotifyStream = [self new];
    });
    return sharedSpotifyStream;
}

-(instancetype)init {
    if (self = [super init]) {
        [self initialize];
        _paused = NO;
    }
    return self;
}

-(BOOL)handleRedirect:(NSURL *)redirect {
    if ([self.auth canHandleURL:redirect]) {
        if (self.authController) {
            [self.authController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            self.authController = nil;
        }
        [self.auth handleAuthCallbackWithTriggeredAuthURL:redirect callback:^(NSError *error, SPTSession *session) {
            if (session) {
                [self login];
            }
        }];
        return YES;
    }
    return NO;
}

-(void)initialize {
    self.auth = [SPTAuth defaultInstance];
    self.auth.clientID = @"498438580ac7478f86064c411d32457a";
    self.auth.redirectURL = [NSURL URLWithString:@"slide-login://callback"];
    self.auth.sessionUserDefaultsKey = @"slide-sdk-session";
    self.auth.requestedScopes = @[SPTAuthStreamingScope, SPTAuthUserReadEmailScope, SPTAuthUserLibraryReadScope];
    
    self.cache = [[SPTDiskCache alloc] initWithCapacity:CACHE_SIZE];
    
    self.stream = [SPTAudioStreamingController sharedInstance];
    self.stream.delegate = self;
    self.stream.playbackDelegate = self;
    self.stream.diskCache = self.cache;
    NSError *audioStreamingInitError;
    [self.stream startWithClientId:self.auth.clientID error:&audioStreamingInitError];
}

-(void)authenticate {
    if ([self.auth.session isValid]) {
        [self login];
    } else {
        if ([SPTAuth supportsApplicationAuthentication]) {
            [[UIApplication sharedApplication] openURL:[self.auth spotifyAppAuthenticationURL]];
        } else {
            self.authController = [[SFSafariViewController alloc] initWithURL:[self.auth spotifyWebAuthenticationURL]];
            [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:self.authController
                                                                                           animated:YES
                                                                                         completion:nil];
        }
    }
}

-(void)logout {
    [self.stream logout];
}

-(void)login {
    [self.stream loginWithAccessToken:self.auth.session.accessToken];
}

#pragma mark Playback

-(void)updateSong:(SLSong *)song {
    _paused = NO;
    [self.stream playSpotifyURI:song.URI.absoluteString
              startingWithIndex:0
           startingWithPosition:0
                       callback:^(NSError *error) {
                           if (error != nil) {
                               NSLog(@"*** failed to update song: %@", error);
                               return;
                           }
                       }];
}

-(void)updateProgress:(CGFloat)progress {
    [self.stream seekTo:(NSTimeInterval)progress
               callback:^(NSError *error) {
                   if (error != nil) {
                       NSLog(@"*** failed to update progress: %@", error);
                       return;
                   }
               }];
}

-(void)play {
    _paused = NO;
    [self.stream setIsPlaying:YES callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** failed to play: %@", error);
            return;
        }
    }];
}

-(void)pause {
    if (_paused) return;
    _paused = YES;
    [self.stream setIsPlaying:NO callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** failed to pause: %@", error);
            return;
        }
    }];
}

#pragma mark Search

-(void)search:(NSString *)query completion:(SLSpotifySearchCallback)completion {
    [SPTSearch performSearchWithQuery:query
                            queryType:SPTQueryTypeTrack
                          accessToken:self.auth.session.accessToken
                               market:@"US"
                             callback:^(NSError *error, id result){
                                 SPTListPage *results = (SPTListPage *)result;
                                 NSMutableArray *songs = [[NSMutableArray alloc] init];
                                 for (SPTTrack *track in results.items) {
                                     [songs addObject:[self convertTrackToSong:track]];
                                 }
                                 completion(songs);
                             }];
}

#pragma mark Performance

-(void)prewarm:(NSArray<SLSong *> *)songs {
    
}

#pragma mark Delegate


- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    [self.delegate spotifyStreamInitialized:self];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToPosition:(NSTimeInterval)position {
    [self.delegate spotifyStream:self updatedProgress:position];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSString *)trackUri {
    [self.delegate spotifyStreamFinishedCurrentSong:self]; // TODO: investigate
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePosition:(NSTimeInterval)position {
    [self.delegate spotifyStream:self updatedProgress:position];
}

#pragma mark Utility

-(SLSong *)convertTrackToSong:(SPTTrack *)track {
    SLSong *song = [SLSong new];
    song.title = track.name;
    song.album = track.album.name;
    song.artist = ((SPTArtist *)([track.artists firstObject])).name;
    song.URI = track.uri;
    song.smallArtworkURI = track.album.smallestCover.imageURL;
    song.largeArtworkURI = track.album.largestCover.imageURL;
    song.duration = track.duration;
    return song;
}


@end
