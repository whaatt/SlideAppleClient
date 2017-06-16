//
//  SLStreamProgressView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/29/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLStreamProgressView.h"
#import "SLUXController.h"

#define UPDATE_INTERVAL 0.1f
#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)

@interface SLStreamProgressView () {
    UIView *_track;
    UIView *_completedTrack;
    UIImageView *_handle;
    
    CGPoint _previousTouchPoint;
    CGFloat _value;
    
    /** NSTimer *_progressTimer;
    BOOL _playing;
    BOOL _wasPlaying; */
    
    BOOL _scrubbing;
    
    UIView *_elapsedContainer;
    UILabel *_elapsedView;
    UILabel *_remainingView;
    
    CGFloat _baseline; // TODO: find a cleaner solution
}

@end

@implementation SLStreamProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _track = [[UIView alloc] initWithFrame:frame];
        _track.layer.cornerRadius = 3.0f;
        _track.clipsToBounds = YES;
        _track.userInteractionEnabled = NO;
        [self addSubview:_track];
        
        _completedTrack = [[UIView alloc] initWithFrame:frame];
        _completedTrack.layer.cornerRadius = 2.5f;
        _completedTrack.clipsToBounds = YES;
        _completedTrack.userInteractionEnabled = NO;
        [self addSubview:_completedTrack];
        
        _handle = [[UIImageView alloc] initWithFrame:frame];
        _handle.contentMode = UIViewContentModeScaleAspectFit;
        _handle.image = [[UIImage imageNamed:@"Design/handle_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _handle.userInteractionEnabled = NO;
        [self addSubview:_handle];
        
        _elapsedContainer = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_elapsedContainer];
        
        float timeFontSize = 12.0f;
        _elapsedView = [[UILabel alloc] init];
        _elapsedView.font = [UIFont systemFontOfSize:timeFontSize weight:UIFontWeightSemibold];
        _elapsedView.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _elapsedView.textAlignment = NSTextAlignmentLeft;
        _remainingView = [[UILabel alloc] init];
        _remainingView.font = [UIFont systemFontOfSize:timeFontSize weight:UIFontWeightSemibold];
        _remainingView.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _remainingView.textAlignment = NSTextAlignmentRight;
        [_elapsedContainer addSubview:_elapsedView];
        [_elapsedContainer addSubview:_remainingView];
        
        
        /**_progressTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL repeats:YES block:^(NSTimer *timer){
            [self progressTimerFired:timer];
        }];*/
        
        _scrubbing = NO;
    
        [self setSong:nil];
    }
    return self;
}

#pragma mark Layout

- (void)layoutSubviews {
    float trackWidth = self.frame.size.width;
    float trackHeight = 2.5f;
    float trackOffset = self.frame.size.height/2 - trackHeight/2;
    _track.frame = CGRectMake(0, trackOffset, trackWidth, trackHeight);
    _completedTrack.frame = CGRectMake(CGRectGetMinX(_track.frame),
                                       CGRectGetMinY(_track.frame),
                                       CGRectGetWidth(_completedTrack.frame),
                                       CGRectGetHeight(_track.frame));
    float handleSize = _handle.frame.size.width;
    _handle.frame = CGRectMake(_handle.frame.origin.x,
                               trackOffset + trackHeight/2 - handleSize/2,
                               handleSize, handleSize);
    
    float elapsedContainerPadding = 2.5f;
    _elapsedContainer.frame = CGRectMake(elapsedContainerPadding, CGRectGetMaxY(_track.frame) + 2.5f, CGRectGetWidth(_track.frame) - elapsedContainerPadding * 2, 20.0f);
    float timeWidth = 50.0f;
    _elapsedView.frame = CGRectMake(0, 0, timeWidth, CGRectGetHeight(_elapsedContainer.frame));
    _remainingView.frame = CGRectMake(CGRectGetWidth(_elapsedContainer.frame) - timeWidth, 0, timeWidth, CGRectGetHeight(_elapsedContainer.frame));
}

-(void)updateLayout {
    float progressOffset = [self positionForValue:_value];
    _handle.frame = CGRectMake(progressOffset - _handle.frame.size.width/2,
                               CGRectGetMinY(_handle.frame),
                               CGRectGetWidth(_handle.frame),
                               CGRectGetHeight(_handle.frame));
    _completedTrack.frame = CGRectMake(CGRectGetMinX(_track.frame),
                                       CGRectGetMinY(_track.frame),
                                       progressOffset,
                                       CGRectGetHeight(_track.frame));
    _elapsedView.text = [self formatTime:self.elapsed];
    _remainingView.text = [NSString stringWithFormat:@"-%@",[self formatTime:(self.song.duration - self.elapsed)]];
}

#pragma mark Config

- (void)setSong:(SLSong *)song {
    _song = song;
    _value = 0.0f;
    // _playing = NO;
    [self updateLayout];
}

- (void)setSize:(CGFloat)size {
    _size = size;
    //float previousSize = _handle.frame.size.width;
    _handle.frame = CGRectMake(CGRectGetMinX(_handle.frame),// + (previousSize/2 - size/2),
                               CGRectGetMinY(_handle.frame),// + (previousSize/2 - size/2),
                               size, size);
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    _track.backgroundColor = [tintColor colorWithAlphaComponent:0.5f];
    _completedTrack.backgroundColor = tintColor;
    _handle.tintColor = tintColor;
    _elapsedView.textColor = tintColor;
    _remainingView.textColor = tintColor;
}

#pragma mark Public

- (void)updateElapsed:(NSTimeInterval)elapsed {
    if (_scrubbing) return;
    _value = elapsed/self.song.duration;
    [self updateProgress];
}

#pragma mark State Control

- (void)updateProgress {
    _value = BOUND(_value, 1.0f, 0.0f);
    [self updateLayout]; // TODO: Investigate issues with layoutSubviews
    
    if(_value == 1.0f){
        [self.delegate progressViewDidFinish:self];
    }
}

/**
 - (void)play {
 _playing = YES;
 }
 
 - (void)pause {
 _playing = NO;
 }
 */

#pragma mark State Information

- (NSTimeInterval)elapsed {
    return _value * self.song.duration;
}

- (float)positionForValue:(float)value
{
    return _track.frame.size.width * value/1.0f;
}
/**
#pragma mark Timer

- (void)progressTimerFired:(NSTimer *)timer {
    if (_playing) {
        _value = (self.elapsed + UPDATE_INTERVAL)/self.song.duration;
        [self updateProgress];
    }
}
*/
#pragma mark Interaction Handling

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self];
    float effectiveSize = self.size * 5.0f;
    CGPoint center = CGPointMake(CGRectGetMidX(_handle.frame), CGRectGetMidY(_handle.frame));
    CGRect effectiveFrame = CGRectMake(center.x - effectiveSize/2, center.y - effectiveSize/2, effectiveSize, effectiveSize);
    if(CGRectContainsPoint(effectiveFrame, _previousTouchPoint)){
        _scrubbing = YES;
        [self.delegate progressViewWillBeginInteraction:self];
        /** _wasPlaying = _playing;
        [self pause]; */
        [self animateSize:YES];
        return YES;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    float trackLength = _track.frame.size.width;
    
    float delta = touchPoint.x - _previousTouchPoint.x;
    float valueDelta = delta / trackLength;
    
    _previousTouchPoint = touchPoint;
    
    _value += valueDelta;
    [self updateProgress];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _scrubbing = NO;
    [self.delegate progressViewWillEndInteraction:self];
    [self animateSize:NO];
    /** if (_wasPlaying) {
        [self play];
    } */
    [self.delegate progressView:self changedElapsed:self.elapsed];
}

#pragma mark Animations

- (void)animateSize:(BOOL)larger {
    float scaleFactor = 2.5f;
    if (larger) {
        _baseline = self.size;
    }
    float newSize = (larger) ? self.size * scaleFactor : _baseline;
    UIColor *newColor = DARK_MODE? UIColor.whiteColor : UIColor.blackColor;
    if (!larger) newColor = _tintColor;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         _handle.frame = CGRectMake(CGRectGetMidX(_handle.frame) - newSize/2,
                                                    CGRectGetMidY(_track.frame) - newSize/2,
                                                    newSize,
                                                    newSize);
                         _handle.tintColor = newColor;
                         _completedTrack.backgroundColor = newColor;
                         _elapsedView.textColor = newColor;
                     } completion:^(BOOL finished){
                         self.size = newSize;
                     }];
}

#pragma mark Utilities

- (NSString *)formatTime:(NSTimeInterval)time {
    unsigned int seconds = (unsigned int)round(time);
    return [NSString stringWithFormat:@"%u:%02u", (seconds / 60) % 60, seconds % 60];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
