//
//  SLServerExpectationQueue.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/10/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLServerExpectationQueue.h"

@interface SLServerExpectationQueue () {
    NSMutableArray<id<SLServerUpdate>> *_expectations;
}

@end


@implementation SLServerExpectationQueue

-(instancetype)init {
    if (self = [super init]) {
        _expectations = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)expected:(id<SLServerUpdate>)update {
    id<SLServerUpdate> expectedUpdate = [_expectations firstObject];
    if (expectedUpdate && [expectedUpdate equalToUpdate:update]) {
        [_expectations removeObjectAtIndex:0];
        return YES;
    }
    return NO;
}

-(void)push:(id<SLServerUpdate>)expectedUpdate {
    [_expectations addObject:expectedUpdate];
}

@end
