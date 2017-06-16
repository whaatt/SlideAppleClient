//
//  SLVisualizerDimensionView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLVisualizerDimensionView.h"

#define MIN_DURATION 0.25f
#define MAX_DURATION 0.75f
#define MIN_SIZE 5.0f

@interface SLVisualizerDimensionView () {
    UIView *_enigma;
}

@end

@implementation SLVisualizerDimensionView

-(float)randomFloatBetween:(float)min and:(float)max {
    return (((float)rand())/RAND_MAX) * (max - min) + min;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        _enigma = [[UIView alloc] init];
        _enigma.backgroundColor = UIColor.whiteColor;
        _enigma.layer.cornerRadius = 1.0f;
        [self addSubview:_enigma];
    }
    return self;
}

-(void)layoutSubviews {
    // Note: issue exists with perpual relayout, investigate
}

-(void)animate:(BOOL)repeat {
    float maxHeight = self.frame.size.height;
    float targetHeight = [self randomFloatBetween:MIN_SIZE and:maxHeight];
    float targetDuration = [self randomFloatBetween:MIN_DURATION and:MAX_DURATION];
    
    _enigma.frame = CGRectMake(0, self.frame.size.height - MIN_SIZE, self.frame.size.width, MIN_SIZE);
    [UIView animateWithDuration:targetDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         _enigma.frame = CGRectMake(0, maxHeight - targetHeight, _enigma.frame.size.width, targetHeight);
                     } completion:^(BOOL finished){
                         [self reverse:repeat];
                     }];
}

-(void)reverse:(BOOL)repeat {
    float targetDuration = [self randomFloatBetween:MIN_DURATION and:MAX_DURATION];
    [UIView animateWithDuration:targetDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         _enigma.frame = CGRectMake(0, self.frame.size.height - MIN_SIZE, self.frame.size.width, MIN_SIZE);
                     } completion:^(BOOL finished){
                         if(repeat){
                             [self animate:repeat];
                         }
                     }];
}

-(void)start {
    [self animate:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
