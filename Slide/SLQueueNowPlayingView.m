//
//  SLQueueNowPlayingView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/27/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueNowPlayingView.h"
#import "SLUXController.h"
#import "SLVisualizerView.h"
#import "SLArtworkCache.h"

#define VISUALIZER_DIMENSIONS 3

@interface SLQueueNowPlayingView () {
    UIView *_containerView;
    
    UIView *_borderView;
    UILabel *_titleView;
    UILabel *_nowPlayingView;
    UIImageView *_artworkView;
    
    UIImageView *_backgroundView;
    UIImageView *_temp;
    
    UIView *_gradientView;
    CAGradientLayer *_gradient;
    UIVisualEffectView *_blurView;
    UIVisualEffectView *_vibrancyView;
    
    SLVisualizerView *_visualizer;
}

@end

@implementation SLQueueNowPlayingView

-(instancetype) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
        
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundView.clipsToBounds = YES;
        _backgroundView.layer.opacity = 1.0f;
        [self addSubview:_backgroundView];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        
        _containerView = [[UIView alloc] init];
        
        float titleFontSize = 14.0f;
        float subtitleFontSize = 16.0f;
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:titleFontSize weight:UIFontWeightBold];
        _titleView.textColor =  [UIColor colorWithWhite:1.0f alpha:1.0f];
        _titleView.text = @"Now Playing";
        //_titleView.layer.shadowColor = [UIColor colorWithWhite:0.1f alpha:1.0f].CGColor;
        //_titleView.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
        //_titleView.layer.shadowOpacity = 1.0f;
        
        _artworkView = [[UIImageView alloc] init];
        _artworkView.contentMode = UIViewContentModeScaleAspectFit;
        _artworkView.layer.cornerRadius = 5.0f;
        _artworkView.layer.borderWidth = 0.0f;
        _artworkView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
        _artworkView.clipsToBounds = YES;
        _artworkView.layer.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
        _artworkView.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
        _artworkView.layer.shadowOpacity = 0.75f;
        _artworkView.layer.opacity = 1.00f;
        [_containerView addSubview:_artworkView];
        
        _visualizer = [[SLVisualizerView alloc] initWithDimensionality:VISUALIZER_DIMENSIONS];
        _visualizer.layer.opacity = 0.5f;
        [_containerView addSubview:_visualizer];
        
        _nowPlayingView = [[UILabel alloc] init];
        _nowPlayingView.font = [UIFont systemFontOfSize:subtitleFontSize weight:UIFontWeightBold];
        _nowPlayingView.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _nowPlayingView.text = @"NOW PLAYING";
        
        [_vibrancyView.contentView addSubview:_titleView];
        [_containerView addSubview:_nowPlayingView];
        
        _gradientView = [[UIView alloc] init];
        _gradient = [CAGradientLayer layer];
        _gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor];
        [_gradientView.layer insertSublayer:_gradient atIndex:0];
        
        //[_blurView.contentView addSubview:_gradientView];
        //[_blurView.contentView addSubview:_titleView];
        [_containerView addSubview:_vibrancyView];
        [_blurView.contentView addSubview:_containerView];
        _blurView.layer.opacity = 1.0f;
        
        [self addSubview:_blurView];
        
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];
        //[self addSubview:_borderView];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float leftOffset = 5.0f;
    _backgroundView.frame = self.frame;
    _blurView.frame = self.frame;
    
    _containerView.frame = CGRectMake(0, 0, self.frame.size.width, 75.0f); //_blurView.frame;
    _vibrancyView.frame = _containerView.frame;
    
    float gradientHeight = self.frame.size.height * 3.5f;
    _gradientView.frame = CGRectMake(0, -(gradientHeight - self.frame.size.height), self.frame.size.width, gradientHeight);
    _gradient.frame = _gradientView.bounds;

    float borderSize = 1;
    _borderView.frame = CGRectMake(0,
                                   self.frame.size.height - borderSize,
                                   self.frame.size.width,
                                   borderSize);
    
    float artworkSize = 0.0f;
    _artworkView.frame = CGRectMake(leftOffset, //-(artworkSize-targetOffset+artworkPadding),
                                    _blurView.contentView.frame.size.height/2 - artworkSize/2,
                                    artworkSize,
                                    artworkSize);
    
    float visualizerContainerSize = 55.0f;
    float visualizerHeight = 20.0f;
    float visualizerWidth = 25.0f;
    _visualizer.frame = CGRectMake((visualizerContainerSize/2 - visualizerWidth/2), //-(artworkSize-targetOffset+artworkPadding),
                                   _containerView.frame.size.height/2 - visualizerHeight/2,
                                   visualizerWidth,
                                   visualizerHeight);
    
    float titleViewHeight = _titleView.intrinsicContentSize.height;
    // float titleViewWidth = _titleView.intrinsicContentSize.width;
    float titleOffset = 10.0f;
    _titleView.frame = CGRectMake(visualizerContainerSize + titleOffset, //self.frame.size.width/2 - _titleView.intrinsicContentSize.width/2,
                                  _vibrancyView.contentView.frame.size.height/2 - titleViewHeight/2 - 11.0f,
                                  _titleView.intrinsicContentSize.width,
                                  _titleView.intrinsicContentSize.height);
    _nowPlayingView.frame = CGRectMake(_titleView.frame.origin.x,//self.frame.size.width/2 - _nowPlayingView.intrinsicContentSize.width/2,
                                       _titleView.frame.origin.y + _titleView.frame.size.height + 1.0f,
                                       _nowPlayingView.intrinsicContentSize.width,
                                       _nowPlayingView.intrinsicContentSize.height);
    
}

- (void)setSong:(SLSong *)song {
    _song = song;
    _titleView.text = song.artist;
    _nowPlayingView.text = song.title;
    
    [[SLArtworkCache sharedInstance] loadArtwork:song size:SLArtworkLarge
                                      completion:^(UIImage *artwork){
                                          _artworkView.image = artwork;
                                          [UIView transitionWithView:_backgroundView
                                                            duration:0.3f
                                                             options:UIViewAnimationOptionTransitionCrossDissolve
                                                          animations:^{
                                                              _backgroundView.image = artwork;
                                                          } completion:nil];
                                      }];
    
    
    [self setNeedsLayout];
}

#pragma mark User Interaction

-(void)handleTap:(UITapGestureRecognizer *)gr {
    [self.delegate shouldMinimize:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
