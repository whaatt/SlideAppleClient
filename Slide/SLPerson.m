//
//  SLPerson.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/8/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLPerson.h"

@implementation SLPerson

+(instancetype)personWithUsername:(NSString *)username {
    SLPerson *person = [SLPerson new];
    person.username = username;
    return person;
}

-(BOOL)equalToPerson:(SLPerson *)person {
    return [person.username isEqualToString:self.username];
}

@end
