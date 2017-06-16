//
//  SLServerUpdateOperation.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/9/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLServerUpdate.h"

typedef void (^SLServerStreamUpdate)();

@interface SLServerUpdateOperation : NSObject

@property (nonatomic) id<SLServerUpdate> executionDelegate;
@property (nonatomic) SLServerStreamUpdate operation;

@end
