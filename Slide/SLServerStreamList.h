//
//  SLServerStreamList.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/7/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSong.h"
#import "SLServerUpdate.h"
#import "SLQueue.h"
#import "SLServerUpdateOperation.h"

@interface SLServerStreamList : NSObject <SLServerUpdate>

@property (nonatomic) NSArray<SLSong *>*list;
@property (nonatomic) SLQueueListType type;

-(instancetype)initWithType:(SLQueueListType)type songs:(NSArray<SLSong *>*)songs;
-(NSArray<NSArray<SLSong *> *>*)inferUpdates:(SLServerStreamList *)newList;
-(NSInteger)findSong:(NSString *)identifier;
-(NSString *)serialize;

// updates
-(BOOL)readyForUpdate;
-(BOOL)equalToUpdate:(id<SLServerUpdate>)update;

// utility
+(instancetype)parse:(NSArray *)serverObject;
+(instancetype)emptyListForType:(SLQueueListType)type;
+(NSString *)convertQueueListTypeToString:(SLQueueListType)type;


@end
