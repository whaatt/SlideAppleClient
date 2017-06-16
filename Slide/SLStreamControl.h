//
//  SLStreamControl.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/29/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SLStreamControlStateActive,
    SLStreamControlStatePassive
} SLStreamControlState;

@class SLStreamControl;

@protocol SLStreamControlManager <NSObject>

-(void)toggle:(SLStreamControl *)toggle changedState:(SLStreamControlState)newState;
-(void)buttonPressed:(SLStreamControl *)button;

-(void)controlWillBeginInteraction:(SLStreamControl *)control;
-(void)controlWillEndInteraction:(SLStreamControl *)control;

@end

@interface SLStreamControl : UIControl

@property (nonatomic, weak) id<SLStreamControlManager> delegate;
@property (nonatomic) UIColor *tintColor;

-(void)setCurrentState:(SLStreamControlState)state;

+(SLStreamControl *)buttonWithIcon:(UIImage *)icon;
+(SLStreamControl *)toggleWithActiveIcon:(UIImage *)activeIcon passiveIcon:(UIImage *)passiveIcon;

@end
