//
//  SLAppController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/18/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLAppController.h"
#import "SLUXController.h"

@interface SLAppController () {
    SLUXController *_mainController;
}

@end

@implementation SLAppController

- (instancetype)init {
    if(self = [super init]){
        _mainController = [[SLUXController alloc] init];
        [self addChildViewController:_mainController];
        
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [view addSubview:_mainController.view];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
