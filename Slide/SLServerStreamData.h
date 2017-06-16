//
//  SLServerStreamData.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/6/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLStream.h"
#import "SLServerTrackData.h"
#import "SLServerCurrentTrack.h"

typedef enum {
    SLServerStreamUser,
    SLServerStreamOther
} SLServerStreamType;

@interface SLServerStreamData : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) SLStreamSettings settings;
@property (nonatomic) NSString *password;
@property (nonatomic) SLServerCurrentTrack *currentTrack;
@property (nonatomic) CGFloat timestamp;
@property (nonatomic) SLServerStreamType type;
@property (nonatomic) SLPerson *source;
@property (nonatomic) NSArray<SLPerson *> *people;

//utility
+(instancetype)parse:(NSDictionary *)serverObject;
-(SLStreamUpdateType)inferUpdates:(SLServerStreamData *)update;

@end
