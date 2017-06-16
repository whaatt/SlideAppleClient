//
//  SLVisualizerView.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/28/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLVisualizerView.h"
#import "SLVisualizerDimensionView.h"

@interface SLVisualizerView () {
    NSMutableArray<SLVisualizerDimensionView *> *_dimensions;
}

@end

@implementation SLVisualizerView

-(instancetype)initWithDimensionality:(NSUInteger)dimensionality {
    if(self = [super initWithFrame:CGRectZero]){
        _dimensions = [[NSMutableArray alloc] initWithCapacity:dimensionality];
        for(int i = 0; i < dimensionality; i++){
            SLVisualizerDimensionView *dimension = [[SLVisualizerDimensionView alloc] init];
            [_dimensions addObject:dimension];
            [self addSubview:dimension];
            [dimension start];
        }
    }
    return self;
}

-(void)layoutSubviews {
    float padding = 0.10f * self.frame.size.width;
    NSUInteger dimensionality = _dimensions.count;
    float width = (self.frame.size.width - padding * (dimensionality - 1))/dimensionality;
    for (int d = 0; d < dimensionality; d++) {
        float offset = d * width + d * padding;
        SLVisualizerDimensionView *dimension = _dimensions[d];
        dimension.frame = CGRectMake(offset, 0, width, self.frame.size.height);
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
