//
//  SLUXController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/18/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLUXController.h"
#import "SLHeaderNavigationController.h"
#import "SLStreamController.h"

@interface SLUXController () {
    SLHeaderNavigationController *_headerController;
    SLStreamController *_streamController;
}

@end

@implementation SLUXController

- (instancetype)init {
    if(self = [super init]){
        _headerController = [[SLHeaderNavigationController alloc] init];
        [self addChildViewController:_headerController];
        
        _streamController = [[SLStreamController alloc] init];
        [self addChildViewController:_streamController];
    }
    return self;
}


- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [view addSubview:_streamController.view];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark Perf

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
