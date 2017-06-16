//
//  SLStreamControl.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/29/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLStreamControl.h"

#define SCALE_FACTOR 0.75f

@interface SLStreamControl () {
    UIImageView *_iconView;
    CGFloat _size;
    
}

@property (nonatomic) UIImage *activeIcon;
@property (nonatomic) UIImage *passiveIcon;
@property (nonatomic) BOOL isToggle;
@property (nonatomic) SLStreamControlState currentState;

@end

@implementation SLStreamControl

+(instancetype)buttonWithIcon:(UIImage *)icon {
    SLStreamControl *control = [SLStreamControl new];
    control.activeIcon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    control.passiveIcon = nil;
    control.currentState = SLStreamControlStateActive;
    return control;
}

+(instancetype)toggleWithActiveIcon:(UIImage *)activeIcon passiveIcon:(UIImage *)passiveIcon {
    SLStreamControl *control = [SLStreamControl new];
    control.activeIcon = [activeIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    control.passiveIcon = [passiveIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    control.currentState = SLStreamControlStatePassive;
    return control;
}

-(BOOL)isToggle {
    return !(self.passiveIcon == nil);
}

-(void)setCurrentState:(SLStreamControlState)currentState {
    _currentState = currentState;
    if (currentState == SLStreamControlStateActive) {
        _iconView.image = _activeIcon;
    } else if (_passiveIcon != nil) {
        _iconView.image = _passiveIcon;
    }
}

-(void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    _iconView.tintColor = tintColor;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _iconView = [[UIImageView alloc] initWithFrame:frame];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconView];
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _iconView.frame = self.bounds; // TODO: fix, potentially hacky
}

-(void)layoutSubviews {
    // TODO: investigate how to handle layout subviews and user interaction (same issue as before)
}

-(void)interact {
    if(self.isToggle){
        if (self.currentState == SLStreamControlStateActive) {
            self.currentState = SLStreamControlStatePassive;
        } else {
            self.currentState = SLStreamControlStateActive;
        }
        [self.delegate toggle:self changedState:self.currentState];
    } else {
        [self.delegate buttonPressed:self];
    }
}

-(void)startAnimation {
    float originalSize = CGRectGetWidth(_iconView.frame);
    _size = originalSize;
    float newSize = SCALE_FACTOR * originalSize;
    float delta = originalSize - newSize;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         _iconView.frame = CGRectMake(CGRectGetMinX(_iconView.frame) + delta/2,
                                                      CGRectGetMinY(_iconView.frame) + delta/2,
                                                      newSize,
                                                      newSize);
                     } completion:^(BOOL finished){

                     }];
}

-(void)endAnimation:(BOOL)successful {
    float newSize = _size;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         _iconView.frame = CGRectMake(0, 0, newSize, newSize);
                         _iconView.tintColor = _tintColor;
                     } completion:^(BOOL finished){
                     }];
    
    successful = NO; // uncomment to enable tapViews
    if (successful){
        UIImageView *tapView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Design/circle.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        tapView.contentMode = UIViewContentModeScaleAspectFit;
        tapView.userInteractionEnabled = NO;
        tapView.frame = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 0, 0);
        tapView.hidden = NO;
        tapView.layer.opacity = 1.0f;
        tapView.tintColor = [_tintColor colorWithAlphaComponent:0.05f];
        [self addSubview:tapView];
        [UIView animateWithDuration:1.0f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             tapView.frame = CGRectMake(-self.bounds.size.width * 4.5f,
                                                         -self.bounds.size.height * 4.5f,
                                                         self.bounds.size.width * 10,
                                                         self.bounds.size.height * 10);
                             tapView.layer.opacity = 0.0f;
                         } completion:^(BOOL finished){
                             [tapView removeFromSuperview];
                         }];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // CGPoint touchPoint = [touch locationInView:self];
    [self.delegate controlWillBeginInteraction:self];
    [self startAnimation];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    /**CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        return YES;
    }
    NSLog(@"Touch Canceled");*/
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.delegate controlWillEndInteraction:self];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL success = NO;
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        [self interact];
        success = YES;
    }
    [self endAnimation:success];
}

@end
