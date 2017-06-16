//
//  SLServer.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/4/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SLStream.h"

@class SLServer;

@protocol SLClient <NSObject>

-(void)serverInitialized:(SLServer *)server;
-(void)server:(SLServer *)server loggedIn:(BOOL)success;
-(void)server:(SLServer *)server loggedOut:(BOOL)success;
-(void)server:(SLServer *)server updatedQueue:(SLQueueListType)type withSongs:(NSArray<SLSong *>*)songs;
-(void)server:(SLServer *)server updatedSongAtIndex:(SLQueueIndex)index;
-(void)server:(SLServer *)server updatedProgress:(CGFloat)progress;
-(void)server:(SLServer *)server updatedCurrentSong:(SLSong *)song;
-(void)server:(SLServer *)server updatedPaused:(BOOL)paused;
// meta
-(void)server:(SLServer *)server updatedName:(NSString *)name;
-(void)server:(SLServer *)server updatedPeople:(NSArray<SLPerson *>*)people;
-(void)server:(SLServer *)server updatedSettings:(SLStreamSettings)settings;

@end

@interface SLServer : NSObject

@property (nonatomic) id<SLClient> client;
// needs to be embedded in a view context for proper functionality
@property (nonatomic) UIView *context;

-(void)initialize;
-(void)loginWithUsername:(NSString *)username UUID:(NSString *)UUID;
-(void)logout;
-(void)hostStream:(NSString *)name settings:(SLStreamSettings)settings;
-(void)joinStream:(NSString *)name;
-(void)leaveStream;
-(void)setCurrentSong:(SLSong *)song;
-(void)setProgress:(NSTimeInterval)progress;
-(void)setPaused:(BOOL)paused;
-(void)setQueue:(SLQueueListType)queue songs:(NSArray<SLSong *>*)songs;
-(void)upvote:(BOOL)upvote song:(SLSong *)song inQueue:(SLQueueListType)queue;

@end
