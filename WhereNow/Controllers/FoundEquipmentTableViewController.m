//
//  FoundEquipmentTableViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 29/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "FoundEquipmentTableViewController.h"
#import "ModelManager.h"
#import "Equipment.h"
#import "EquipmentImage.h"
#import <snfsdk/snfsdk.h>
#import "BackgroundTaskManager.h"
#import "StickerManager.h"
#import "FoundEquipmentTableViewCell.h"

@interface FoundEquipmentTableViewController () <StickerManagerDelegate>

@end

@implementation FoundEquipmentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [BackgroundTaskManager sharedManager].stickBeaconManager.delegate = self;
    [[BackgroundTaskManager sharedManager] changeToStickBeaconMode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

static FoundEquipmentTableViewCell *_prototypeFoundEquipmentTableViewCell = nil;
- (FoundEquipmentTableViewCell *)prototypeFoundEquipmentTableViewCell
{
    if (_prototypeFoundEquipmentTableViewCell == nil)
        _prototypeFoundEquipmentTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"foundequipmentcell"];
    return _prototypeFoundEquipmentTableViewCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arrayEquipments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 162.0;
    /*
    CGFloat height = [self prototypeFoundEquipmentTableViewCell].frame.size.height;
    return height;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoundEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"foundequipmentcell" forIndexPath:indexPath];
    Equipment *equipment = [self.arrayEquipments objectAtIndex:indexPath.row];
    cell.equipment = equipment;
    
    cell.sticker = nil;
    for (Sticker *sticker in [BackgroundTaskManager sharedManager].stickBeaconManager.arrayStickers) {
        if (sticker.sid == [equipment.sticknfind_id intValue])
            cell.sticker = sticker;
    }
    
    return cell;
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

#pragma mark - Done
- (void)onDone:(id)sender
{
    [[BackgroundTaskManager sharedManager] cancelStickBeaconMode];
    
    if (self.delegate)
        [self.delegate didFoundEquipmentDone:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - StickerManagerDelegate
- (void)stickerManager:(StickerManager *)stickerManager didDiscoverSticker:(Sticker *)sticker
{
    //
}

- (void)stickerManager:(StickerManager *)stickerManager didGetSidForSticker:(Sticker *)sticker sid:(int)sid
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

@end
