//
//  SLQueueTableViewController.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/18/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLQueueTableViewController.h"
#import "SLQueueItemCell.h"
#import "SLQueueTableView.h"
#import "SLUXController.h"
#import "SLQueueHeaderView.h"

@interface UITableView (Private)
-(void) _setAllowsReorderingWhenNotEditing:(BOOL)allow;
@end

@interface SLQueueTableViewController ()

@end

@implementation SLQueueTableViewController

- (void) loadView {
    SLQueueTableView *queue = [[SLQueueTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    queue.dataSource = self;
    queue.delegate = self;
    self.view = queue;
    self.tableView = queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = DARK_MODE ? UIColor.blackColor : UIColor.whiteColor;
    // self.tableView.layer.cornerRadius = 5.0f;
    [self.tableView registerClass:SLQueueItemCell.class forCellReuseIdentifier:@"QueueItem"];
    // [self.tableView setEditing:YES animated:NO];
    [self.tableView _setAllowsReorderingWhenNotEditing:YES]; // Note - Private API
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setData:(NSMutableArray<NSMutableArray<SLSong *>*> *)data {
    if (_data && [_data isEqualToArray:data]) {
        return;
    }
    _data = data;
    [self.tableView reloadData];
}

- (void)updateSongAtIndex:(SLQueueIndex)index {
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForQueueIndex:index]]
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLQueueItemCell *cell = (SLQueueItemCell *)[tableView dequeueReusableCellWithIdentifier:@"QueueItem" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.song = self.data[indexPath.section][indexPath.row];
    cell.hideBorder = ((indexPath.row + 1) == self.data[indexPath.section].count); // hide the border on the final element
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate queueTable:self requestedIndex:[self queueIndexForIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
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
                     }];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL queue = (section == 0);
    SLQueueHeaderView *header = [[SLQueueHeaderView alloc] init];
    header.title = queue? @"queue" : @"up next";
    return header;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
    
    }];
    return @[delete];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //(1 + ([_data[1] count] > 0)); uncomment to hide up-next when empty
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data[section].count;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSUInteger sourceSection = sourceIndexPath.section;
    NSUInteger sourceRow = sourceIndexPath.row;
    NSUInteger targetSection = destinationIndexPath.section;
    NSUInteger targetRow = destinationIndexPath.row;
    
    if (sourceIndexPath == destinationIndexPath) return;
    SLSong *source = self.data[sourceSection][sourceRow];
    [self.data[sourceSection] removeObjectAtIndex:sourceRow];
    [self.data[targetSection] insertObject:source atIndex:targetRow];
    // TODO: (Maybe) Wait for this update to register in Stream model.
    SLQueueIndex sourceQueueIndex = [self queueIndexForIndexPath:sourceIndexPath];
    SLQueueIndex targetQueueIndex = [self queueIndexForIndexPath:destinationIndexPath];
    [self.delegate queueTable:self requestedMoveIndex:sourceQueueIndex toIndex:targetQueueIndex];
}

// Utility Functions

-(NSIndexPath *)indexPathForQueueIndex:(SLQueueIndex)index {
    return [NSIndexPath indexPathForRow:index.position
                              inSection:((index.list == SLQueueListQueue)? 0 : 1)];
}

-(SLQueueIndex)queueIndexForIndexPath:(NSIndexPath *)indexPath {
    SLQueueIndex index;
    index.list = (indexPath.section == 0)? SLQueueListQueue : SLQueueListUpNext;
    index.position = indexPath.row;
    return index;
}

/**- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}*/


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
