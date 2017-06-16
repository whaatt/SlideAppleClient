//
//  SLServerUpdate.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/10/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLServerUpdate <NSObject>

-(BOOL)readyForUpdate;
-(BOOL)equalToUpdate:(id<SLServerUpdate>)update;

@end
