//
//  SLPlayerView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLPlayerView.h"
#import "SLStreamProgressView.h"
#import "SLUXController.h"
#import "UIImage+AverageColor.h"
#import "SLStreamControl.h"
#import "SLArtworkCache.h"

#define REPLAY_THRESHOLD 5.0f

@interface SLPlayerView () <SLStreamControlManager, SLStreamProgressManager> {
    // Song
    UIImageView *_artworkView;
    UIView *_artworkContainer;
    UILabel *_songTitleView;
    UILabel *_songSubtitleView;
    
    // Vinyl Mode
    UIView *_vinylContainer;
    UIImageView *_vinylTextureView;
    UIImageView *_vinylArtworkView;
    
    // Stream
    UILabel *_streamName;
    UILabel *_streamInformation;
    UIView *_streamInformationContainer;
    
    // Queue
    UIView *_queueButtonContainer;
    UILabel *_queueTitle;
    UIImageView *_queueIcon;
    UIView *_queueIconContainer;
    
    // Meta
    UIImageView *_closeButton;
    SLStreamControl *_queueButton;
    
    // Blurs
    UIImageView *_backgroundView;
    UIVisualEffectView *_blurView;
    UIVisualEffectView *_vibrancyView;
    
    // State
    BOOL _isPlaying;
    SLSong *_currentSong;
    
    // Vinyl Mode
    BOOL _vinylMode;
    
    // Controls
    UIView *_playPauseContainer;
    SLStreamControl *_playToggle;
    SLStreamControl *_nextButton;
    SLStreamControl *_prevButton;
    SLStreamProgressView *_progressControl;
    BOOL _isInteracting;
}

@end

@implementation SLPlayerView

#pragma mark Public

/** Note: These methods *only* change the internal visual state of the stream, and are exposed publicly. */

-(void)play {
    _isPlaying = YES;
    [_playToggle setCurrentState:SLStreamControlStateActive];
    if (_vinylMode) {
        [self startVinylAnimation];
    }
}

-(void)pause {
    _isPlaying = NO;
    [_playToggle setCurrentState:SLStreamControlStatePassive];
    if (_vinylMode) {
        [self stopVinylAnimation];
    }
}

- (void)updateProgress:(CGFloat)progress {
    [_progressControl updateElapsed:(NSTimeInterval)progress];
}

- (void)playNextEnabled:(BOOL)enabled {
    
}

- (void)playPreviousEnabled:(BOOL)enabled {
    
}

-(void)updateSong:(SLSong *)song {
    [[SLArtworkCache sharedInstance] loadArtwork:song size:SLArtworkLarge
                                      completion:^(UIImage *artwork){
                                          if (![song.URI.absoluteString isEqualToString:_currentSong.URI.absoluteString]) {
                                              return;
                                          }
                                          // Blurs
                                          [UIView transitionWithView:_backgroundView
                                                            duration:0.5f
                                                             options:UIViewAnimationOptionTransitionCrossDissolve
                                                          animations:^{
                                                              _backgroundView.image = artwork;
                                                          } completion:nil];
                                          
                                          _artworkView.image = artwork;
                                          _vinylArtworkView.image = artwork;
                                          // Shadowing
                                          UIColor *shadowColor = [artwork averageColor];
                                          _artworkContainer.layer.shadowColor = shadowColor.CGColor;

                                      }];
    
    _songTitleView.text = song.title;
    _songSubtitleView.text = song.artist;
    
    // Vinyl
    [self resetVinylAnimation];
    
    _progressControl.song = song;
    if (_isPlaying) {
        // [_progressControl play];
        if (_vinylMode) [self startVinylAnimation];
    }
    _currentSong = song;
    [self setNeedsLayout];
}

-(void)updateStreamMetadata:(SLStream *)stream {
    _streamName.text = stream.name;
    _streamInformation.text = [NSString stringWithFormat:@"%i people here", (int)stream.people.count];
    
}

#pragma mark Stream Control

/** Note: These methods do not actually change internal state. They only notify the delegate
          of the actions requested. It is the delegate's responsibility to act on their 
          behalf, and update the state appropiately via the methods in State Control. */

-(void)shouldPlay {
    [self.delegate playerShouldPlay:self];
}

-(void)shouldPause {
    [self.delegate playerShouldPause:self];
}

-(void)shouldPlayNextSong {
    [self.delegate playerShouldPlayNextSong:self];
}

-(void)shouldPlayPreviousSong {
    if (_progressControl.elapsed >= REPLAY_THRESHOLD) {
        [self.delegate playerShouldReplayCurrentSong:self];
    } else {
        [self.delegate playerShouldPlayPreviousSong:self];
    }
}

-(void)shouldChangeProgress:(CGFloat)progress {
    [self.delegate player:self shouldChangeProgress:progress];
}

#pragma mark Delegates

-(void)controlWillBeginInteraction:(SLStreamControl *)control {
    _isInteracting = YES;
}

-(void)controlWillEndInteraction:(SLStreamControl *)control {
    _isInteracting = NO;
}

-(void)progressViewWillBeginInteraction:(SLStreamProgressView *)progressView {
    _isInteracting = YES;
}

-(void)progressViewWillEndInteraction:(SLStreamProgressView *)progressView {
    _isInteracting = NO;
}

-(void)progressView:(SLStreamProgressView *)progressView changedElapsed:(NSTimeInterval)elapsed {
    [self shouldChangeProgress:elapsed];
}

-(void)progressViewDidFinish:(SLStreamProgressView *)progressView {
    // [self shouldPlayNextSong];
}

-(void)toggle:(SLStreamControl *)toggle changedState:(SLStreamControlState)newState {
    if (newState == SLStreamControlStateActive) {
        [self shouldPlay];
    } else if (newState == SLStreamControlStatePassive) {
        [self shouldPause];
    }
}

-(void)buttonPressed:(SLStreamControl *)button {
    if (button == _prevButton) {
        [self shouldPlayPreviousSong];
    } else if (button == _nextButton) {
        [self shouldPlayNextSong];
    } else if (button == _queueButton){
        [self.delegate playerShouldDisplayQueue:self];
    }
}

#pragma mark Gestures

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)gestureRecognizer {
    if(!_isInteracting) [self.delegate playerShouldDisplayQueue:self];
}
    
- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"Swiped down.");
}


#pragma mark Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
        
        _isPlaying = NO;
        
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundView.clipsToBounds = YES;
        _backgroundView.layer.opacity = 0.3f;
        [self addSubview:_backgroundView];
        
        UIBlurEffectStyle blurStyle = DARK_MODE? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self addSubview:_blurView];
        
        _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blurEffect]];
        [_blurView addSubview:_vibrancyView];
        
        _artworkContainer = [[UIView alloc] init];
        _artworkContainer.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _artworkContainer.layer.shadowRadius = 30.0f;
        // _artworkContainer.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        _artworkContainer.layer.shadowOpacity = 0.5f;
        [_blurView.contentView addSubview:_artworkContainer];
        
        /** Vinyl Mode */
        _vinylMode = NO;
        _vinylContainer = [[UIView alloc] init];
        // _vinylContainer.backgroundColor = UIColor.blackColor;
        _vinylContainer.hidden = !_vinylMode;
        [_blurView.contentView addSubview:_vinylContainer];
        _vinylTextureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Design/vinyl_texture.png"]];
        _vinylTextureView.contentMode = UIViewContentModeScaleAspectFit;
        _vinylTextureView.layer.opacity = 0.25f;
        [_vinylContainer addSubview:_vinylTextureView];
        _vinylArtworkView = [[UIImageView alloc] init];
        _vinylArtworkView.contentMode = UIViewContentModeScaleAspectFit;
        _vinylArtworkView.clipsToBounds = YES;
        [_vinylContainer addSubview:_vinylArtworkView];
        
        _streamInformationContainer = [[UIView alloc] init];
        _streamInformationContainer.layer.cornerRadius = 10.0f;
        //_streamInformationContainer.layer.borderColor = UIColor.whiteColor.CGColor;
        //_streamInformationContainer.layer.borderWidth = 0.0f;
        //_streamInformationContainer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        [_vibrancyView.contentView addSubview:_streamInformationContainer];
        
        _streamName = [[UILabel alloc] init];
        _streamName.font = [UIFont systemFontOfSize:26.0f weight:UIFontWeightBold];
        _streamName.textColor = DARK_MODE ? UIColor.whiteColor : [UIColor colorWithWhite:0.0f alpha:1.0f];
        _streamName.layer.opacity = 1.0f;
        [_blurView.contentView addSubview:_streamName];
        
        _streamInformation = [[UILabel alloc] init];
        _streamInformation.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightSemibold];
        _streamInformation.textColor = DARK_MODE ? UIColor.whiteColor : [UIColor colorWithWhite:0.0f alpha:1.0f];
        _streamInformation.layer.opacity = 0.6f;
        [_blurView.contentView addSubview:_streamInformation];
        
        _closeButton = [[UIImageView alloc] init];
        _closeButton.image = [[UIImage imageNamed:@"Design/arrow_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _closeButton.tintColor = DARK_MODE ? [UIColor colorWithWhite:0.9f alpha:1.0f] : [UIColor colorWithWhite:0.1f alpha:1.0f];
        _closeButton.contentMode = UIViewContentModeScaleAspectFit;
        [_blurView.contentView addSubview:_closeButton];
        
        _queueIconContainer = [[UIView alloc] init];
        _queueIconContainer.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:1.0f alpha:0.05f] : [UIColor colorWithWhite:0.0f alpha:0.05f];
        _queueIconContainer.layer.cornerRadius = 8.0f;
        [_blurView.contentView addSubview:_queueIconContainer];
        
        _queueButton = [SLStreamControl buttonWithIcon:[UIImage imageNamed:@"Design/queue_icon.png"]];
        _queueButton.tintColor = DARK_MODE ? [UIColor colorWithWhite:0.9f alpha:0.5f] : [UIColor colorWithWhite:0.1f alpha:0.5f];
        _queueButton.delegate = self;
        [_queueIconContainer addSubview:_queueButton];
        
        _playPauseContainer = [[UIView alloc] init];
        [_blurView.contentView addSubview:_playPauseContainer];
        
        _playToggle = [SLStreamControl toggleWithActiveIcon:[UIImage imageNamed:@"Design/pause_icon.png"]
                                                passiveIcon:[UIImage imageNamed:@"Design/play_icon.png"]];
        _playToggle.tintColor = DARK_MODE ? UIColor.whiteColor : UIColor.blackColor;
        _playToggle.delegate = self;
        [_playPauseContainer addSubview:_playToggle];
        
        
        _nextButton = [SLStreamControl buttonWithIcon:[UIImage imageNamed:@"Design/play_next_icon.png"]];
        _nextButton.tintColor = DARK_MODE ? UIColor.whiteColor : UIColor.blackColor;
        _nextButton.delegate = self;
        [_blurView.contentView addSubview:_nextButton];
        
        _prevButton = [SLStreamControl buttonWithIcon:[UIImage imageNamed:@"Design/play_prev_icon.png"]];
        _prevButton.tintColor = DARK_MODE ? UIColor.whiteColor : UIColor.blackColor;
        _prevButton.delegate = self;
        [_blurView.contentView addSubview:_prevButton];
        
        _isInteracting = NO;
        
        _artworkView = [[UIImageView alloc] init];
        _artworkView.contentMode = UIViewContentModeScaleAspectFit;
        _artworkView.layer.borderWidth = 0.0f;
        _artworkView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
        _artworkView.layer.cornerRadius = 10.0f;
        _artworkView.clipsToBounds = YES;
        _artworkView.hidden = _vinylMode;
        [_artworkContainer addSubview:_artworkView];
        
        _songTitleView = [[UILabel alloc] init];
        _songTitleView.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
        _songTitleView.textColor = DARK_MODE ? UIColor.whiteColor : [UIColor colorWithWhite:0.0f alpha:1.0f];
        _songTitleView.text = @"Title";
        [_blurView.contentView addSubview:_songTitleView];
        
        _songSubtitleView = [[UILabel alloc] init];
        _songSubtitleView.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightSemibold];
        _songSubtitleView.textColor = DARK_MODE ? [UIColor colorWithWhite:1.0f alpha:0.8f] : [UIColor colorWithWhite:0.0f alpha:0.6f];
        _songSubtitleView.text = @"Artist";
        [_blurView.contentView addSubview:_songSubtitleView];
        
        _progressControl = [[SLStreamProgressView alloc] init];
        _progressControl.tintColor = DARK_MODE ? [UIColor colorWithWhite:0.9f alpha:1.0f] : [UIColor colorWithWhite:0.25f alpha:1.0f];
        _progressControl.size = 10.0f;
        _progressControl.delegate = self;
        [_blurView.contentView addSubview:_progressControl];
        
        _queueButtonContainer = [[UIView alloc] init];
        // [_blurView.contentView addSubview:_queueButtonContainer];
        
        _queueIcon = [[UIImageView alloc] init];
        _queueIcon.image = [[UIImage imageNamed:@"Design/queue_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _queueIcon.tintColor = DARK_MODE ? [UIColor colorWithWhite:0.75f alpha:1.0f] : [UIColor colorWithWhite:0.5f alpha:1.0f];
        _queueIcon.contentMode = UIViewContentModeScaleAspectFit;
        [_queueButtonContainer addSubview:_queueIcon];
        
        _queueTitle = [[UILabel alloc] init];
        _queueTitle.text = @"😏    😮    😱    🔥    👌🏻";
        _queueTitle.textColor = DARK_MODE ? [UIColor colorWithWhite:0.75f alpha:1.0f] : [UIColor colorWithWhite:0.4f alpha:1.0f];
        _queueTitle.font = [UIFont systemFontOfSize:24.0f weight:UIFontWeightBold];
        _queueTitle.layer.opacity = 0.5f;
        [_queueButtonContainer addSubview:_queueTitle];
        
        // Gestures
        UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
        swipeUpGesture.cancelsTouchesInView = NO;
        [swipeUpGesture setNumberOfTouchesRequired:1];
        [swipeUpGesture setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:swipeUpGesture];
        
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
        swipeDownGesture.cancelsTouchesInView = NO;
        [swipeDownGesture setNumberOfTouchesRequired:1];
        [swipeDownGesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [self addGestureRecognizer:swipeDownGesture];
        
    }
    return self;
}

#pragma mark Vinyl Mode

-(void)startVinylAnimation {
    if ([_vinylContainer.layer animationForKey:@"spin"] == nil) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        CGFloat current = [(NSNumber *)[_vinylContainer.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
        animation.fromValue = [NSNumber numberWithFloat:current];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI + current];
        animation.duration = 5.0f;
        animation.repeatCount = HUGE_VALF;
        animation.removedOnCompletion = NO;
        [_vinylContainer.layer addAnimation:animation forKey:@"spin"];
    }
}

-(void)stopVinylAnimation {
    _vinylContainer.layer.transform = [(CALayer *)[_vinylContainer.layer presentationLayer] transform];
    [_vinylContainer.layer removeAnimationForKey:@"spin"];
}

-(void)resetVinylAnimation {
    [self stopVinylAnimation];
    _vinylContainer.layer.transform = CATransform3DIdentity;
}

#pragma mark Layout

-(void)layoutSubviews {
    _backgroundView.frame = self.bounds;
    _blurView.frame = self.bounds;
    _vibrancyView.frame = _blurView.bounds;
    
    float leftOffset = 25.0f;
    
    float headerHeight = 80.0f;
    float headerPadding = headerHeight;
    float streamInformationWidth = headerPadding + MAX(_streamName.intrinsicContentSize.width, _streamInformation.intrinsicContentSize.width);
    float streamInformationHeight = 45.0f;
    _streamInformationContainer.frame = CGRectMake(self.frame.size.width/2 - streamInformationWidth/2,
                                                   headerHeight/2 - streamInformationHeight/2,
                                                   streamInformationWidth,
                                                   streamInformationHeight);
    
    _streamName.frame = CGRectMake(leftOffset, //self.frame.size.width/2 - _streamName.intrinsicContentSize.width/2,
                                   headerHeight/2 - _streamName.intrinsicContentSize.height/2 - 8.0f,
                                   _streamName.intrinsicContentSize.width,
                                   _streamName.intrinsicContentSize.height);
    _streamInformation.frame = CGRectMake(leftOffset, //self.frame.size.width/2 - _streamInformation.intrinsicContentSize.width/2,
                                          CGRectGetMaxY(_streamName.frame),
                                          _streamInformation.intrinsicContentSize.width,
                                          _streamInformation.intrinsicContentSize.height);
    
    float closeButtonSize = 0.0f;
    _closeButton.frame = CGRectMake(leftOffset,
                                    headerHeight/2 - closeButtonSize/2,
                                    closeButtonSize, closeButtonSize);
    
    float queueButtonSize = 45.0f;
    _queueIconContainer.frame = CGRectMake(self.frame.size.width - queueButtonSize - leftOffset + 5.0f,
                                           headerHeight/2 - queueButtonSize/2,
                                           queueButtonSize, queueButtonSize);
    float padding = 10.0f;
    _queueButton.frame = CGRectMake(padding,
                                    padding,
                                    queueButtonSize - padding * 2, queueButtonSize - padding * 2);
    
    float artworkOffset = headerHeight;
    float artworkPadding = 15.0f;
    float artworkSize = self.frame.size.width - artworkPadding * 2;
    _artworkContainer.frame = CGRectMake(artworkPadding, artworkOffset, artworkSize, artworkSize);
    _artworkView.frame = CGRectMake(0, 0, artworkSize, artworkSize);
    
    /** vinyl mode */
    float vinylTextureSize = 1000.0f;// 380.0f;
    float vinylArtworkSize = 320.0f;
    float vinylVerticalOffset = -80.0f;
    _vinylContainer.frame = CGRectMake(CGRectGetMidX(self.bounds) - vinylTextureSize/2,
                                       CGRectGetMidY(self.bounds) - vinylTextureSize/2 + vinylVerticalOffset,
                                       vinylTextureSize, vinylTextureSize);
    _vinylTextureView.frame = CGRectMake(0, 0, vinylTextureSize, vinylTextureSize);
    _vinylArtworkView.frame = CGRectMake(vinylTextureSize/2 - vinylArtworkSize/2,
                                         vinylTextureSize/2 - vinylArtworkSize/2,
                                         vinylArtworkSize, vinylArtworkSize);
    _vinylArtworkView.layer.cornerRadius = vinylArtworkSize/2;
    
    
    float progressPadding = 10.0f;
    float progressWidth = _artworkView.frame.size.width - 15.0f;
    float progressHeight = 40.0f;
    _progressControl.frame = CGRectMake(self.frame.size.width/2 - progressWidth/2,
                                        CGRectGetMaxY(_artworkContainer.frame) + progressPadding,
                                        progressWidth,
                                        progressHeight);
    
    _songTitleView.frame = CGRectMake(self.frame.size.width/2 - _songTitleView.intrinsicContentSize.width/2,
                                      CGRectGetMaxY(_progressControl.frame) + 5.0f,
                                      _songTitleView.intrinsicContentSize.width,
                                      _songTitleView.intrinsicContentSize.height);
    _songSubtitleView.frame = CGRectMake(self.frame.size.width/2 - _songSubtitleView.intrinsicContentSize.width/2,
                                         CGRectGetMaxY(_songTitleView.frame),
                                         _songSubtitleView.intrinsicContentSize.width,
                                         _songSubtitleView.intrinsicContentSize.height);
    
    
    float playContainerSize = 50.0f;
    _playPauseContainer.frame = CGRectMake(self.frame.size.width/2 - playContainerSize/2,
                                           CGRectGetMaxY(_songSubtitleView.frame) + 22.5f,
                                           playContainerSize, playContainerSize);
    _playPauseContainer.layer.cornerRadius = playContainerSize/2;
    
    float playPauseIconSize = 50.0f;
    _playToggle.frame = CGRectMake(_playPauseContainer.frame.size.width/2 - playPauseIconSize/2,
                                   _playPauseContainer.frame.size.height/2 - playPauseIconSize/2,
                                   playPauseIconSize, playPauseIconSize);
    
    float skipIconSize = 40.0f;
    float skipIconPadding = 50.0f;
    float skipIconOffset = CGRectGetMinY(_playPauseContainer.frame) + (playContainerSize/2 - skipIconSize/2);
    _prevButton.frame = CGRectMake(CGRectGetMinX(_playPauseContainer.frame) - skipIconSize - skipIconPadding,
                                   skipIconOffset,
                                   skipIconSize, skipIconSize);
    _nextButton.frame = CGRectMake(CGRectGetMaxX(_playPauseContainer.frame) + skipIconPadding - 1.5f,
                                   skipIconOffset,
                                   skipIconSize, skipIconSize);
    
    float queueIconSize = 0.0f;
    float queuePadding = 5.0f;
    float queueContainerWidth = queueIconSize + queuePadding + _queueTitle.intrinsicContentSize.width;
    _queueButtonContainer.frame = CGRectMake(self.frame.size.width/2 - queueContainerWidth/2,
                                             CGRectGetMaxY(_playPauseContainer.frame) + 25.0f,
                                             queueContainerWidth,
                                             queueIconSize);
    _queueIcon.frame = CGRectMake(0, 0, queueIconSize, queueIconSize);
    _queueTitle.frame = CGRectMake(queueIconSize + queuePadding, 0, _queueTitle.intrinsicContentSize.width, 20.0f);
    
    /**UIView *temp = [UIView new];
     temp.backgroundColor = UIColor.blackColor;
     temp.layer.opacity = 0.05f;
     temp.layer.cornerRadius = 10.0f;
     //temp.layer.borderWidth = 1.0f;
     //temp.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
     float tempPadding = 20.0f;
     temp.frame = CGRectMake(tempPadding,
     CGRectGetMaxY(_playPauseContainer.frame) + 20.0f,
     self.frame.size.width - tempPadding * 2,
     40.0f);
     [self addSubview:temp];*/
}

@end
