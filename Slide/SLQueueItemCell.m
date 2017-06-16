//
//  SLQueueItemCell.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/26/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueItemCell.h"
#import "SLUXController.h"
#import "SLArtworkCache.h"

@interface SLQueueItemCell () {
    UIView *_borderView;
    UILabel *_titleView;
    UILabel *_subtitleView;
    UIImageView *_artworkView;
}

@end

@implementation SLQueueItemCell

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
        
        /**_borderView = [[UIImageView alloc] init];
        _borderView.contentMode = UIViewContentModeScaleToFill;
        _borderView.tintColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        _borderView.image = [[UIImage imageNamed:@"Design/pixel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];*/
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
}

- (void)setSong:(SLSong *)song {
    _song = song;
    _titleView.text = song.title;
    _subtitleView.text = song.artist;
    [[SLArtworkCache sharedInstance] loadArtwork:song size:SLArtworkLarge
                                      completion:^(UIImage *artwork){
                                          if (![self.song.URI.absoluteString isEqual:song.URI.absoluteString]) {
                                              return;
                                          }
                                          _artworkView.image = artwork;
                                      }];
}

- (void)setHideBorder:(BOOL)hideBorder {
    _hideBorder = hideBorder;
    _borderView.hidden = hideBorder;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
