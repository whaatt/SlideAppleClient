//
//  SLSearchTableViewController.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/12/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLSearchTableViewController.h"
#import "SLSearchResultCell.h"
#import "SLHighlightedSearchResultCell.h"
#import "SLUXController.h"

@interface SLSearchTableViewController () {
    
}

@end

@implementation SLSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
    [self.tableView registerClass:SLSearchResultCell.class forCellReuseIdentifier:@"SearchResult"];
    [self.tableView registerClass:SLHighlightedSearchResultCell.class forCellReuseIdentifier:@"HighlightedSearchResult"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)setData:(NSArray<SLSong *> *)data {
    _data = data;
    self.tableView.contentOffset = CGPointZero;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *identifier = (indexPath.row == 0)? @"HighlightedSearchResult" : @"SearchResult";
    SLSearchResultCell *cell = (SLSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResult"
                                                                                     forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.song = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /**if (indexPath.row == 0)
        return 150.0f;*/
    return 75.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate searchTable:self selectedSong:[_data objectAtIndex:indexPath.row]];
    SLSearchResultCell *result = (SLSearchResultCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [result addAnimation];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    /**UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIColor *prevColor = cell.backgroundColor;
    float duration = 0.6f;
    [UIView animateWithDuration:0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         cell.backgroundColor = DARK_MODE? [UIColor colorWithWhite:0.05f alpha:1.0f] : [UIColor colorWithWhite:0.95f alpha:1.0f];
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^(){
                                              cell.backgroundColor = prevColor;
                                          } completion:nil];
                     }];*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
