//
//  SLServerExpectationQueue.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/10/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLServerUpdate.h"

@interface SLServerExpectationQueue : NSObject

-(BOOL)expected:(id<SLServerUpdate>)update;
-(void)push:(id<SLServerUpdate>)expectedUpdate;

@end
