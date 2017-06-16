//
//  SLHeaderNavigationController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/26/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLHeaderNavigationController.h"
#import "SLUXController.h"

#define CENTERED NO

@interface SLHeaderNavigationController () {
    UIImageView *_iconView;
    UIView *_borderView;
}

@end

@implementation SLHeaderNavigationController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, HEADER_SIZE)];
    view.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
    view.clipsToBounds = YES;
    float iconWidth = 80.0f;
    float iconHeight = 40.0f;
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake((CENTERED? view.frame.size.width/2 - iconWidth/2 : 5.0f),
                                                              HEADER_OFFSET + HEADER_HEIGHT/2 - iconHeight/2 + 2.5f, // HEADER_SIZE - iconHeight - 5.0f
                                                              iconWidth,
                                                              iconHeight)];
    // _iconView.backgroundColor = UIColor.redColor;
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView.image = DARK_MODE ? [UIImage imageNamed:@"Design/logo.png"] : [UIImage imageNamed:@"Design/logo_dark.png"];
    [view addSubview:_iconView];
    
    int borderSize = 1;
    _borderView = [[UIView alloc] init];
    _borderView.layer.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:0.1f alpha:1.0f].CGColor : [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    _borderView.frame = CGRectMake(0,
                                   view.frame.size.height - borderSize,
                                   view.frame.size.width,
                                   borderSize);
    // [view addSubview:_borderView];
    
    self.view = view;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
