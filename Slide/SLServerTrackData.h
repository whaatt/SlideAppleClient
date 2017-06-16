//
//  SLServerTrackData.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/6/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSong.h"
#import "SLServerUpdate.h"

@interface SLServerTrackData : NSObject <SLServerUpdate>

@property (nonatomic) NSString *uri;
@property (nonatomic) NSString *largeArtworkURI;
@property (nonatomic) NSString *smallArtworkURI;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *album;
@property (nonatomic) NSTimeInterval duration;

-(instancetype)initWithSong:(SLSong *)song;
-(void)updateSong:(SLSong *)song;
-(NSString *)serialize;
+(instancetype)parse:(NSDictionary *)serverObject;
-(SLSong *)song;

@end
