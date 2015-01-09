//
//  HistoryViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "HistoryViewController.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "EquipmentImage.h"
#import "ServerManagerHelper.h"

@interface HistoryViewController ()
{
    UIBarButtonItem *_backButton;
    Equipment *_equipment;
    NSTimer *_timerForAlert;
    UIImage *images[11];
}

@property (nonatomic, strong) NSMutableArray *arrayMovements;
@property (nonatomic, strong) NSMutableDictionary *groupedMovements;
@property (nonatomic, strong) NSMutableArray *groupedDates;
@property (nonatomic, strong) MovementCount *movementCount;

@property (nonatomic, weak) IBOutlet UIImageView *ivImg1;
@property (nonatomic, weak) IBOutlet UIImageView *ivImg2;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;



@end

@implementation HistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self.navigationController.tabBarItem setImage:[UIImage imageNamed:@"historyicon"]];
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"historyicon_selected"]];
    
    // back button
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    UIBarButtonItem *_menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navigationItem.rightBarButtonItem = _menuButton;
    self.menuItem = _menuButton;
    
    EquipmentTabBarController *tabbarController = (EquipmentTabBarController *)self.tabBarController;
    _equipment = tabbarController.equipment;
    if (_equipment != nil)
    {
        self.navigationItem.title = [ModelManager getEquipmentName:_equipment];
        
    }
    
    [self loadData];
    
    // set images
    //[[ServerManager sharedManager] setImageContent:self.ivImg1 urlString:_equipment.equipment_file_location];
    [EquipmentImage setModelImageOfEquipment:_equipment toImageView:self.ivImg1 completed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.ivImg1 layoutIfNeeded];
        });
    }];
    
    //[[ServerManager sharedManager] setImageContent:self.ivImg2 urlString:_equipment.model_file_location];
    [EquipmentImage setManufacturerImageOfEquipment:_equipment toImageView:self.ivImg2 completed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.ivImg2 layoutIfNeeded];
        });
    }];
    
   
    // init percent image array
    images[0] = [UIImage imageNamed:@"movepercent0"];
    images[1] = [UIImage imageNamed:@"movepercent1"];
    images[2] = [UIImage imageNamed:@"movepercent2"];
    images[3] = [UIImage imageNamed:@"movepercent3"];
    images[4] = [UIImage imageNamed:@"movepercent4"];
    images[5] = [UIImage imageNamed:@"movepercent5"];
    images[6] = [UIImage imageNamed:@"movepercent6"];
    images[7] = [UIImage imageNamed:@"movepercent7"];
    images[8] = [UIImage imageNamed:@"movepercent8"];
    images[9] = [UIImage imageNamed:@"movepercent9"];
    images[10] = [UIImage imageNamed:@"movepercent10"];
    
    // request movement
    [[ServerManagerHelper sharedInstance] getMovementsForEquipment:_equipment];
}

- (void)loadData
{
    EquipmentTabBarController *tabbarController = (EquipmentTabBarController *)self.tabBarController;
    _equipment = [[ModelManager sharedManager] equipmentById:[tabbarController.equipment.equipment_id intValue]];
    
    if (_equipment != nil)
    {
        self.arrayMovements = [[ModelManager sharedManager] equipmovementsForEquipment:_equipment];
        
        self.groupedMovements = [[NSMutableDictionary alloc] init];
        self.groupedDates = [[NSMutableArray alloc] init];
        
        // group by date
        for (EquipMovement *movement in self.arrayMovements) {
            NSMutableArray *array = [self.groupedMovements objectForKey:movement.date];
            if (array == nil)
            {
                array = [[NSMutableArray alloc] init];
                [self.groupedDates addObject:movement.date];
            }
            [array addObject:movement];
            [self.groupedMovements setObject:array forKey:movement.date];
        }
    }
    else
    {
        self.arrayMovements = [[NSMutableArray alloc] init];
        self.groupedMovements = [[NSMutableDictionary alloc] init];
        self.groupedDates = [[NSMutableArray alloc] init];
    }
    
    NSArray *arrayMovementCount = [[ModelManager sharedManager] retrieveMovementCountForEquipment:_equipment];
    if (arrayMovementCount != nil && arrayMovementCount.count > 0)
        self.movementCount = [arrayMovementCount objectAtIndex:0];
    else
        self.movementCount = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBar.barStyle = [UIManager navbarStyle];
    //self.navigationController.navigationBar.tintColor = [UIManager navbarTintColor];
    self.navigationController.navigationBar.titleTextAttributes = [UIManager navbarTitleTextAttributes];
    //self.navigationController.navigationBar.barTintColor = [UIManager navbarBarTintColor];
}

#pragma mark - Table view data source

static UITableViewCell *_prototypeMovementsCell = nil;
static UITableViewCell *_prototypeHistoryCell = nil;

- (UITableViewCell *)prototypeMovementsCell
{
    if (_prototypeMovementsCell == nil)
        _prototypeMovementsCell = [self.tableView dequeueReusableCellWithIdentifier:@"movementscell"];
    return _prototypeMovementsCell;
}

- (UITableViewCell *)prototypeHistoryCell
{
    if (_prototypeHistoryCell == nil)
        _prototypeHistoryCell = [self.tableView dequeueReusableCellWithIdentifier:@"historycell"];
    return _prototypeHistoryCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1 + self.groupedDates.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 27;
    else
        return 27;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, tableView.frame.size.width, 22)];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    NSString *string = @"Movements";
    if (section > 0)
    {
        string = [self.groupedDates objectAtIndex:section - 1];
        
        NSDate *today = [NSDate date];
        NSDate *yesterday = [today dateByAddingTimeInterval:- 60 * 60 * 24];
        
        if ([string isEqualToString:[Common date2str:today withFormat:DATE_FORMAT]])
            string = @"Today";
        else if ([string isEqualToString:[Common date2str:yesterday withFormat:DATE_FORMAT]])
            string = @"Yesterday";
    }
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else
    {
        NSString *date = [self.groupedDates objectAtIndex:section - 1];
        NSArray *array = [self.groupedMovements objectForKey:date];
        return array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return [self prototypeMovementsCell].bounds.size.height;
    else
        return [self prototypeHistoryCell].bounds.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"movementscell"];
        int moves[7];
        moves[0] = [self.movementCount.mon intValue];
        moves[1] = [self.movementCount.tue intValue];
        moves[2] = [self.movementCount.wed intValue];
        moves[3] = [self.movementCount.thu intValue];
        moves[4] = [self.movementCount.fri intValue];
        moves[5] = [self.movementCount.sat intValue];
        moves[6] = [self.movementCount.sun intValue];
        int min = 10000;
        int max = 0;
        for (int i = 0; i < 7; i++) {
            if (moves[i] > max)
                max = moves[i];
            if (moves[i] < min)
                min = moves[i];
        }
        
        // get weekday
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *date = [NSDate date];
        NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
        int weekday = (int)[comps weekday];
        if (weekday >= 2)
            weekday = weekday - 1 - 1;
        else
            weekday = weekday - 1 - 1 + 7;
        
        NSMutableArray *arrayWeekdays = [[NSMutableArray alloc] initWithObjects:@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun", nil];
        
        int indexForUI = 6; // right hand side
        int indexForVal = weekday;
        for (int i = 0; i < 7; i++) {
            UIImageView *ivProgress = (UIImageView *)[cell viewWithTag:(100 + indexForUI)];
            UILabel *labelWeekday = (UILabel *)[cell viewWithTag:(200 + indexForUI)];
            
            if (max == 0)
                ivProgress.image = images[0];
            else
            {
                int index = (int)(((CGFloat)moves[indexForVal] / (CGFloat)max) * 10);
                if (index == 0 && moves[indexForVal] > 0)
                    index = 1;
                ivProgress.image = images[index];
            }
            
            labelWeekday.text = arrayWeekdays[indexForVal];
            
            indexForUI--;
            indexForVal--;
            if (indexForVal < 0)
                indexForVal = 6;
        }
    }
    else
    {
        NSString *date = [self.groupedDates objectAtIndex:indexPath.section - 1];
        NSArray *array = [self.groupedMovements objectForKey:date];
        
        int index = (int)indexPath.row;
        EquipMovement *movement = [array objectAtIndex:index];
        cell = [tableView dequeueReusableCellWithIdentifier:@"historycell"];
        UILabel *lblLevel = (UILabel *)[cell viewWithTag:100];
        UILabel *lblLocation = (UILabel *)[cell viewWithTag:101];
        UILabel *stay_time1 = (UILabel *)[cell viewWithTag:102];
        UILabel *stay_time2 = (UILabel *)[cell viewWithTag:103];
        
        lblLevel.text = movement.parent_location_name;
        lblLocation.text = movement.location_name;
        stay_time1.text = [NSString stringWithFormat:@"arrived at %@", movement.time];
        stay_time2.text = [NSString stringWithFormat:@"at location for %@", movement.stay_time];
    }
    
    // Configure the cell...
    
    return cell;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Back button
- (void)onBack:(id)sender
{
    if (self.delegate)
        [self.delegate onBack:sender];
}

#pragma mark - Menu button
- (void)onMenu:(id)sender
{
    if (self.delegate)
        [self.delegate onMenu:self];
    
}

- (void)onMovementDataChanged:(NSNotification *)note {
    NSLog(@"historyview - onMovementDataChanged");
    if ([note.object intValue] != [_equipment.equipment_id intValue])
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self loadData];
        
        [self.tableView reloadData];
        
        [self.indicator stopAnimating];
    });
}

@end
