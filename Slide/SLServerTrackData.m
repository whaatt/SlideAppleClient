//
//  SLServerTrackData.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/6/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerTrackData.h"

@implementation SLServerTrackData

-(instancetype)initWithSong:(SLSong *)song {
    if(self = [super init]){
        self.name = song.title;
        self.artist = song.artist;
        self.album = song.album;
        self.duration = song.duration;
        self.uri = song.URI.absoluteString;
        self.smallArtworkURI = song.smallArtworkURI.absoluteString;
        self.largeArtworkURI = song.largeArtworkURI.absoluteString;
    }
    return self;
}

-(NSString *)serialize {
    return [NSString stringWithFormat:@"{name:\"%@\",artist:\"%@\",album:\"%@\",duration:%f, uri:\"%@\", artwork_large: \"%@\", artwork_small: \"%@\"}",
            self.name, self.artist, self.album, self.duration, self.uri, self.largeArtworkURI, self.smallArtworkURI];
}

-(void)updateSong:(SLSong *)song {
    song.title = self.name;
    song.artist = self.artist;
    song.album = self.album;
    song.duration = self.duration;
    song.URI = [NSURL URLWithString:self.uri];
    song.largeArtworkURI = [NSURL URLWithString:self.largeArtworkURI];
    song.smallArtworkURI = [NSURL URLWithString:self.smallArtworkURI];
}

-(SLSong *)song {
    SLSong *song = [SLSong new];
    song.title = self.name;
    song.artist = self.artist;
    song.album = self.album;
    song.duration = self.duration;
    song.URI = [NSURL URLWithString:self.uri];
    song.largeArtworkURI = [NSURL URLWithString:self.largeArtworkURI];
    song.smallArtworkURI = [NSURL URLWithString:self.smallArtworkURI];
    return song;
}

+(instancetype)parse:(NSDictionary *)serverObject {
    SLServerTrackData *trackData = [SLServerTrackData new];
    if (![serverObject isEqual:[NSNull null]]) {
        trackData.name = serverObject[@"name"];
        trackData.artist = serverObject[@"artist"];
        trackData.album = serverObject[@"album"];
        trackData.duration = [serverObject[@"duration"] doubleValue];
        trackData.smallArtworkURI = serverObject[@"artwork_small"];
        trackData.largeArtworkURI = serverObject[@"artwork_large"];
        trackData.uri = serverObject[@"uri"];
    }
    return trackData;
}

#pragma mark updates

-(BOOL)equalToUpdate:(id<SLServerUpdate>)update {
    SLServerTrackData *trackUpdate = (SLServerTrackData *)update;
    if ([trackUpdate.uri isEqualToString:self.uri]) {
        return YES;
    }
    return NO;
}

-(BOOL)readyForUpdate {
    return YES;
}


@end
