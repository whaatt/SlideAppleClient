//
//  SLServerTrackProgress.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLServerUpdate.h"

@interface SLServerTrackProgress : NSObject <SLServerUpdate>

@property (nonatomic) NSTimeInterval progress;

-(instancetype)initWithProgress:(NSTimeInterval)progress;

@end
