//
//  SLSearchResultCell.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLSearchResultCell.h"
#import "SLUXController.h"
#import "SLArtworkCache.h"

@interface SLSearchResultCell () {
    UIView *_borderView;
    UILabel *_titleView;
    UILabel *_subtitleView;
    UIImageView *_artworkView;
    UILabel *_confirmationText;
    UIView *_confirmationBackground;
}

@end

@implementation SLSearchResultCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = NO;
        self.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _artworkView = [[UIImageView alloc] init];
        _artworkView.contentMode = UIViewContentModeScaleAspectFit;
        _artworkView.layer.cornerRadius = 5.0f;
        _artworkView.layer.borderWidth = 0.0f;
        _artworkView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
        _artworkView.clipsToBounds = YES;
        [self addSubview:_artworkView];
        
        
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightBold];
        _titleView.textColor = DARK_MODE ? UIColor.whiteColor : [UIColor colorWithWhite:0.0f alpha:1.0f];
        _titleView.text = @"Title";
        [self addSubview:_titleView];
        
        _subtitleView = [[UILabel alloc] init];
        _subtitleView.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
        _subtitleView.textColor = DARK_MODE ? [UIColor colorWithWhite:0.7f alpha:1.0f] : [UIColor colorWithWhite:0.3f alpha:1.0f];
        _subtitleView.text = @"Artist";
        [self addSubview:_subtitleView];
        
        _confirmationBackground = [[UIView alloc] init];
        _confirmationBackground.backgroundColor = DARK_MODE? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];// DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
        _confirmationBackground.layer.opacity = 0.0f;
        [self addSubview:_confirmationBackground];
        
        _confirmationText = [[UILabel alloc] init];
        _confirmationText.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightSemibold];
        _confirmationText.textColor = DARK_MODE ? [UIColor colorWithWhite:0.6f alpha:1.0f] : [UIColor colorWithWhite:0.4f alpha:1.0f];
        _confirmationText.text = @"Added";
        _confirmationText.layer.opacity = 0.0f;
        [self addSubview:_confirmationText];
        
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];
        [self addSubview:_borderView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float leftOffset = 5.0f;
    
    float borderSize = 1;
    _borderView.frame = CGRectMake(0,
                                   self.frame.size.height - borderSize,
                                   self.frame.size.width,
                                   borderSize);
    
    float artworkSize = 60.0f;
    _artworkView.frame = CGRectMake(leftOffset,
                                    self.frame.size.height/2 - artworkSize/2,
                                    artworkSize,
                                    artworkSize);
    
    float titleViewHeight = _titleView.intrinsicContentSize.height;
    float titleOffset = 10.0f;
    _titleView.frame = CGRectMake(leftOffset + artworkSize + titleOffset,
                                  self.frame.size.height/2 - titleViewHeight/2 - 7.5f,
                                  self.frame.size.width - 50,
                                  _titleView.intrinsicContentSize.height);
    _subtitleView.frame = CGRectMake(_titleView.frame.origin.x,
                                     _titleView.frame.origin.y + _titleView.intrinsicContentSize.height - 2.0f,
                                     _titleView.frame.size.width,
                                     _titleView.intrinsicContentSize.height);
    
    float confirmationTextHeight = _confirmationText.intrinsicContentSize.height;
    float confirmationOffset = leftOffset + artworkSize + titleOffset;
    _confirmationText.frame = CGRectMake(confirmationOffset,
                                         self.frame.size.height/2 - confirmationTextHeight/2,
                                         self.frame.size.width - 50,
                                         _confirmationText.intrinsicContentSize.height);
    
    _confirmationBackground.frame = CGRectMake(confirmationOffset, 0, _confirmationText.frame.size.width, self.bounds.size.height);
    
}

- (void)setSong:(SLSong *)song {
    _song = song;
    _titleView.text = song.title;
    _subtitleView.text = song.artist;
    _artworkView.image = nil;
    [[SLArtworkCache sharedInstance] loadArtwork:song size:SLArtworkLarge
                                      completion:^(UIImage *artwork){
                                          if (![self.song.URI.absoluteString isEqual:song.URI.absoluteString]) {
                                              return;
                                          }
                                          _artworkView.image = artwork;
                                      }];
}

- (void)addAnimation {
    float duration = 0.25f;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         _confirmationBackground.layer.opacity = 1.0f;
                         _confirmationText.layer.opacity = 1.0f;
                         self.backgroundColor = DARK_MODE? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:duration delay:2.0f options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^(){
                                              _confirmationBackground.layer.opacity = 0.0f;
                                              _confirmationText.layer.opacity = 0.0f;
                                              self.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
                                          } completion:nil];
                     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
