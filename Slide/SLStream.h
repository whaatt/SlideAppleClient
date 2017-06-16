//
//  SLStream.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SLSong.h"
#import "SLQueue.h"
#import "SLPerson.h"

typedef NS_OPTIONS(NSUInteger, SLStreamUpdateType) {
    SLStreamUpdateName          = (1 << 0),
    SLStreamUpdatePeople        = (1 << 1),
    SLStreamUpdateCurrentSong   = (1 << 2),
    SLStreamUpdateQueue         = (1 << 3),
    SLStreamUpdatePaused        = (1 << 4),
    SLStreamUpdateProgress      = (1 << 5),
    SLStreamUpdateSettings      = (1 << 6),
    SLStreamUpdateSong          = (1 << 6),
};

typedef struct {
    BOOL live;
    BOOL hidden;
    BOOL voting;
    BOOL autopilot;
    BOOL limited;
} SLStreamSettings;

@class SLStream;

@protocol SLStreamManager <NSObject>

// TODO: implement all possible stream updates

// unified: - (void)stream:(SLStream *)stream updated:(SLStreamUpdateType)updateType object:(id)object;
-(void)streamUpdatedName:(SLStream *)stream;
-(void)streamUpdatedPeople:(SLStream *)stream;
-(void)streamUpdatedCurrentSong:(SLStream *)stream;
-(void)streamUpdatedQueue:(SLStream *)stream;
-(void)streamUpdatedPaused:(SLStream *)stream;
-(void)streamUpdatedProgress:(SLStream *)stream;
-(void)streamUpdatedSettings:(SLStream *)stream;
-(void)stream:(SLStream *)stream updatedSongAtIndex:(SLQueueIndex)index;

@end

typedef void (^SLStreamUpdateCallback)(BOOL success);

@interface SLStream : NSObject

@property (nonatomic) NSUInteger identifier;
@property (nonatomic) id<SLStreamManager> delegate;

-(instancetype)initWithNetworkAccess:(BOOL)networkAccess;

/** State Information (Readonly) */

-(SLPerson *)currentUser;
-(SLPerson*)host;
-(SLQueue *)queue;
-(SLSong *)currentSong;
-(NSString *)name;
-(NSArray <SLSong *>*)history;
-(NSArray <SLPerson *>*)people;
-(BOOL)paused;
-(NSTimeInterval)progress;

/** State Modifiers (Persistent) */

// Playback
-(void)play;
-(void)pause;
-(void)enqueue:(SLSong *)song;
-(void)updateProgress:(CGFloat)progress;
-(void)startSongAtIndex:(SLQueueIndex)index;
-(void)moveSongAtIndex:(SLQueueIndex)sourceIndex toIndex:(SLQueueIndex)targetIndex;
-(void)startNextSong;
-(void)startPreviousSong;
-(void)restartCurrentSong;

// Meta
-(void)updateName:(NSString *)name;
-(void)updateQueue:(SLQueue *)queue;

/** Prototyping */

-(void)updatePeople:(NSArray<SLPerson *>*)people;
+(SLStream *)generateTemplateStream;

@end
