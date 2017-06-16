//
//  SLServerStreamUpdateQueue.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/9/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLServerStreamList.h"
#import "SLServerUpdateOperation.h"
#import "SLServerUpdate.h"

@interface SLServerUpdateQueue : NSObject

-(void)push:(SLServerUpdateOperation *)update;
-(void)run;

@end
