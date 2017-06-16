//
//  SLQueueHeaderView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/27/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueHeaderView.h"
#import "SLUXController.h"

@interface SLQueueHeaderView () {
    UIView *_borderView;
    UILabel *_titleView;
}

@end

@implementation SLQueueHeaderView

- (instancetype) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightBold];
        _titleView.textColor = DARK_MODE ? [UIColor colorWithWhite:0.9f alpha:1.0f] : [UIColor colorWithWhite:0.25f alpha:1.0f];
        [self addSubview:_titleView];
        
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];
        [self addSubview:_borderView];
    }
    return self;
}

- (void)layoutSubviews {
    float borderSize = 1;
    _borderView.frame = CGRectMake(0,
                                   self.frame.size.height - borderSize,
                                   self.frame.size.width,
                                   borderSize);
    
    float titleViewHeight = self.frame.size.height;
    float titleOffset = 9.0f;
    _titleView.frame = CGRectMake(titleOffset, 0,
                                  self.frame.size.width - titleOffset,
                                  titleViewHeight);
}

- (void)setTitle:(NSString *)title {
    _titleView.text = [title uppercaseString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
