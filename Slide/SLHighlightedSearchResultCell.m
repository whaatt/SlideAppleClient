//
//  SLHighlightedSearchResultCell.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLHighlightedSearchResultCell.h"
#import "SLUXController.h"
#import "SLArtworkCache.h"

@interface SLHighlightedSearchResultCell () {
    UIView *_borderView;
    UILabel *_titleView;
    UILabel *_subtitleView;
    UIImageView *_artworkView;
    UIImageView *_backgroundView;
    UIVisualEffectView *_blurView;
}

@end

@implementation SLHighlightedSearchResultCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = NO;
        self.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundView.clipsToBounds = YES;
        _backgroundView.layer.opacity = 1.0f;
        [self addSubview:_backgroundView];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self addSubview:_blurView];
        
        _artworkView = [[UIImageView alloc] init];
        _artworkView.contentMode = UIViewContentModeScaleAspectFit;
        _artworkView.layer.cornerRadius = 5.0f;
        _artworkView.layer.borderWidth = 0.0f;
        _artworkView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
        _artworkView.clipsToBounds = YES;
        //[_blurView.contentView addSubview:_artworkView];
        
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:22.0f weight:UIFontWeightBold];
        _titleView.textColor = UIColor.whiteColor; //DARK_MODE ? UIColor.whiteColor : [UIColor colorWithWhite:0.0f alpha:1.0f];
        _titleView.text = @"Title";
        [_blurView.contentView addSubview:_titleView];
        
        _subtitleView = [[UILabel alloc] init];
        _subtitleView.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
        _subtitleView.textColor = [UIColor colorWithWhite:1.0f alpha:0.75f]; //DARK_MODE ? [UIColor colorWithWhite:0.7f alpha:1.0f] : [UIColor colorWithWhite:0.3f alpha:1.0f];
        _subtitleView.text = @"Artist";
        [_blurView.contentView addSubview:_subtitleView];
        
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];
        [_blurView.contentView addSubview:_borderView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _backgroundView.frame = self.frame;
    _blurView.frame = self.frame;
    
    float leftOffset = 5.0f;
    
    float borderSize = 1;
    _borderView.frame = CGRectMake(0,
                                   self.frame.size.height - borderSize,
                                   self.frame.size.width,
                                   borderSize);
    
    float artworkSize = 0.0f;
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
                                          _backgroundView.image = artwork;
                                      }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
