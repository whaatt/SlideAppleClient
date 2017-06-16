//
//  SLPerson.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/8/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLPerson : NSObject

@property (nonatomic) NSString *username;

+(instancetype)personWithUsername:(NSString *)username;
-(BOOL)equalToPerson:(SLPerson *)person;

@end
