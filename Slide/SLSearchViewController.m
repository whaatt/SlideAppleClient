//
//  SLSearchViewController.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLSearchViewController.h"
#import "SLSearchTableViewController.h"
#import "SLStreamControl.h"
#import "SLSpotifyStream.h"
#import "SLUXController.h"

@interface SLSearchViewController () <UITextFieldDelegate, SLSearchTableManager, SLStreamControlManager> {
    SLSearchTableViewController *_searchTable;
    
    UIView *_searchHeader;
    UIView *_searchBorder;
    NSTimer *_searchTimer;
    UITextField *_searchInput;
    
    SLStreamControl *_closeButton;
    UIView *_closeButtonContainer;
}

@end

@implementation SLSearchViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    
    float searchHeaderHeight = 75.0f;
    _searchHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, searchHeaderHeight)];
    _searchHeader.backgroundColor = DARK_MODE? UIColor.blackColor : UIColor.whiteColor;
    [view addSubview:_searchHeader];
    
    float closeButtonSize = 45.0f;
    _closeButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width - closeButtonSize - 10.0f,
                                                                     searchHeaderHeight/2 - closeButtonSize/2,
                                                                     closeButtonSize, closeButtonSize)];
    _closeButtonContainer.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:1.0f alpha:0.05f] : [UIColor colorWithWhite:0.0f alpha:0.05f];
    _closeButtonContainer.layer.cornerRadius = 8.0f;
    [view addSubview:_closeButtonContainer];
    
    float closeButtonPadding = 10.0f;
    _closeButton = [SLStreamControl buttonWithIcon:[UIImage imageNamed:@"Design/arrow_icon.png"]];
    _closeButton.frame = CGRectMake(closeButtonPadding, closeButtonPadding,
                                    closeButtonSize - closeButtonPadding * 2, closeButtonSize - closeButtonPadding * 2);
    _closeButton.tintColor = DARK_MODE ? [UIColor colorWithWhite:0.9f alpha:0.5f] : [UIColor colorWithWhite:0.1f alpha:0.5f];
    _closeButton.delegate = self;
    [_closeButtonContainer addSubview:_closeButton];
    
    
    int borderSize = 1;
    _searchBorder = [[UIView alloc] init];
    _searchBorder.layer.backgroundColor = DARK_MODE ? [UIColor colorWithWhite:0.1f alpha:1.0f].CGColor : [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    _searchBorder.frame = CGRectMake(0,
                                   searchHeaderHeight - borderSize,
                                   view.frame.size.width,
                                   borderSize);
    // [view addSubview:_searchBorder];
    
    float inputPadding = 9.0f;
    _searchInput = [[UITextField alloc] initWithFrame:CGRectMake(inputPadding, 0, view.frame.size.width - inputPadding, searchHeaderHeight)];
    _searchInput.delegate = self;
    _searchInput.keyboardAppearance = DARK_MODE? UIKeyboardAppearanceDark : UIKeyboardAppearanceLight;
    _searchInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchInput.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"search"
                                                                         attributes:@{
                                                                                      NSForegroundColorAttributeName: (DARK_MODE? [UIColor colorWithWhite:0.5f alpha:1.0f]:[UIColor colorWithWhite:0.5f alpha:1.0f])
                                                                                      }];
    _searchInput.textColor = DARK_MODE? UIColor.whiteColor : UIColor.blackColor;
    _searchInput.textAlignment = NSTextAlignmentLeft;
    _searchInput.font = [UIFont systemFontOfSize:28.0f weight:UIFontWeightBold];
    _searchInput.tintColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    [_searchHeader addSubview:_searchInput];
    
    _searchTable = [[SLSearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _searchTable.tableView.frame = CGRectMake(0, searchHeaderHeight, view.frame.size.width, view.frame.size.height - searchHeaderHeight);
    _searchTable.delegate = self;
    [view addSubview:_searchTable.tableView];
    
    self.view = view;
}

#pragma mark Public

-(void)focus {
    [_searchInput becomeFirstResponder];
}

#pragma mark Buttons

- (void)buttonPressed:(SLStreamControl *)button {
    [_searchInput resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggle:(SLStreamControl *)toggle changedState:(SLStreamControlState)newState {
    
}

- (void)controlWillBeginInteraction:(SLStreamControl *)control {
    
}

- (void)controlWillEndInteraction:(SLStreamControl *)control {
    
}

#pragma mark Input

- (void)search {
    NSString *query = _searchInput.text;
    if (query.length == 0) return;
    [[SLSpotifyStream sharedInstance] search:query
                                  completion:^(NSArray<SLSong *>*results) {
                                      _searchTable.data = results;
                                  }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
                                                       replacementString:(nonnull NSString *)string {
    if (_searchTimer) {
        [_searchTimer invalidate];
    }

    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f
                                                   repeats:NO
                                                     block:^(NSTimer *timer){
                                                         [self search];
                                                     }];
    
    return YES;
}

#pragma mark Delegates

- (void)searchTable:(SLSearchTableViewController *)searchTable selectedSong:(SLSong *)song {
    [self.delegate searchController:self requestedSong:song];
}

#pragma mark Lifecycle

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
