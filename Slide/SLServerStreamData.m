//
//  SLServerStreamData.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/6/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerStreamData.h"
#import "SLServerCurrentTrack.h"
#import "SLServerTrackData.h"
#import "SLStream.h"

@implementation SLServerStreamData

+(instancetype)parse:(NSDictionary *)serverObject {
    SLServerStreamData *data = [SLServerStreamData new];
    data.name = serverObject[@"display"];
    data.password = serverObject[@"password"];
    data.source = [SLPerson personWithUsername:serverObject[@"source"]];
    data.timestamp = [serverObject[@"timestamp"] integerValue];
    data.type = [serverObject[@"type"] isEqualToString:@"user"] ? SLServerStreamUser : SLServerStreamOther;

    // parse now playing
    SLServerCurrentTrack *currentTrack = [[SLServerCurrentTrack alloc] init];
    if (![serverObject[@"playing"] isEqual:[NSNull null]]) {
        currentTrack.trackData = [SLServerTrackData parse:serverObject[@"playing"]];
        if (![serverObject[@"seek"] isEqual:[NSNull null]]) {
            currentTrack.progress = [[SLServerTrackProgress alloc] initWithProgress:[serverObject[@"seek"] floatValue]];
        }
        SLServerCurrentTrackState state = [serverObject[@"state"] isEqualToString:@"paused"]? SLServerCurrentTrackPaused : SLServerCurrentTrackPlaying;
        currentTrack.state = [[SLServerTrackState alloc] initWithState:state];
        data.currentTrack = currentTrack;
    } else {
        currentTrack.trackData = nil;
        currentTrack.progress = nil;
        currentTrack.state = nil;
    }
    
    // parse users
    NSMutableArray<SLPerson *> *people = [[NSMutableArray alloc] initWithCapacity:[serverObject[@"users"] count]];
    for(NSString *username in serverObject[@"users"]){
        [people addObject:[SLPerson personWithUsername:username]];
    }
    data.people = people;
    
    // parse settings
    SLStreamSettings settings;
    settings.live = [serverObject[@"live"] boolValue];
    settings.hidden = [serverObject[@"private"] boolValue];
    settings.limited = [serverObject[@"limited"] boolValue];
    settings.voting = [serverObject[@"voting"] boolValue];
    settings.autopilot = [serverObject[@"autopilot"] boolValue];
    data.settings = settings;
    
    return data;
}

// Utility

-(BOOL)streamSettingsAreEqualTo:(SLStreamSettings)settings {
    return (self.settings.autopilot == settings.autopilot) &&
           (self.settings.hidden == settings.hidden) &&
           (self.settings.limited == settings.limited) &&
           (self.settings.live == settings.live) &&
           (self.settings.voting == settings.voting);
}

-(SLStreamUpdateType)inferUpdates:(SLServerStreamData *)update {
    SLStreamUpdateType updates = 0;
    if (![self.currentTrack.trackData.uri isEqual:update.currentTrack.trackData.uri]) {
        updates |= SLStreamUpdateCurrentSong;
    }
    NSLog(@"Received progress: %f currentProgress: %f", update.currentTrack.progress.progress, self.currentTrack.progress.progress);
    if (self.currentTrack.progress.progress != update.currentTrack.progress.progress) {
        updates |= SLStreamUpdateProgress;
    }
    if (self.currentTrack.state.state != update.currentTrack.state.state) {
        updates |= SLStreamUpdatePaused;
    }
    if (![self.people isEqualToArray:update.people]) {
        updates |= SLStreamUpdatePeople;
    }
    if ([self streamSettingsAreEqualTo:update.settings]) {
        updates |= SLStreamUpdateSettings;
    }
    return updates;
}

@end
