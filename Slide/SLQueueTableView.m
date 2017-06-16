//
//  SLQueueTableView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/26/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueTableView.h"

@interface SLQueueTableView () {
    __weak UIView *wrapperView; // for shadow adjustments
}

@end

@implementation SLQueueTableView

- (void) didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    // finds container view for shadow layers
    if(wrapperView == nil && [[[subview class] description] isEqualToString:@"UITableViewWrapperView"])
        wrapperView = subview;

}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // removes shadowing
    for(UIView* subview in wrapperView.subviews) {
        if([[[subview class] description] isEqualToString:@"UIShadowView"])
            [subview setHidden:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
