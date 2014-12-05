//
//  NearMeViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "NearMeViewController.h"
#import "SwipeTableView.h"
#import "AppContext.h"
#import "UIManager.h"
#import "EquipmentTabBarController.h"
#import "ModelManager.h"
#import "BackgroundTaskManager.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "CommonGenericTableViewCell.h"
#import "CommonEquipmentTableViewCell.h"
#import "PagingManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface NearMeViewController () <SwipeTableViewDelegate, CommonEquipmentTableViewCellDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    int editingSection;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    BOOL _firstLoad;
    BOOL _isShowing;
}

@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *nearmeVicinityEquipments;
@property (nonatomic, strong) NSMutableArray *nearmeLocationEquipments;

@property (nonatomic, weak) UIRefreshControl *refresh;

@end

@implementation NearMeViewController

- (void)loadData
{
    BackgroundTaskManager *taskManager = [BackgroundTaskManager sharedManager];

    self.nearmeVicinityEquipments = [[NSMutableArray alloc] initWithArray:taskManager.arrayVicinityEquipments];
    self.nearmeLocationEquipments = [[NSMutableArray alloc] initWithArray:taskManager.arrayLocationEquipments];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"nearmeicon_selected"]];
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingSection = -1;
    editingCell = nil;
    editingIndexPath = nil;
    
    [self loadData];
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    //refresh.tintColor = [UIColor whiteColor];
    [refresh addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    self.refresh = refresh;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonEquipmentTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChanged:) name:kBackgroundUpdateLocationInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScannedBeaconChanged:) name:kBackgroundScannedBeaconChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFoundEquipmentsChanged:) name:kFoundEquipmentsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChanged:) name:kEquipmentsForGenericChanged object:nil];
    
    _isShowing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBar.barStyle = [UIManager navbarStyle];
    //self.navigationController.navigationBar.tintColor = [UIManager navbarTintColor];
    self.navigationController.navigationBar.titleTextAttributes = [UIManager navbarTitleTextAttributes];
    //self.navigationController.navigationBar.barTintColor = [UIManager navbarBarTintColor];
    
    if (!_firstLoad)
    {
        editingSection = -1;
        editingCell = nil;
        editingIndexPath = nil;
        
        //[_expandingLocationArray removeAllObjects];
        [self loadData];
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
    _isShowing = YES;
    
    //[[BackgroundTaskManager sharedManager] setConsumeScanning:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _isShowing = NO;
    //[[BackgroundTaskManager sharedManager] setConsumeScanning:NO];
}


#pragma mark - tableview data source

static CommonGenericTableViewCell *_prototypeGenericsTableViewCell = nil;
static CommonEquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;

- (CommonGenericTableViewCell *)prototypeGenericsTableViewCell
{
    if (_prototypeGenericsTableViewCell == nil)
    {
        _prototypeGenericsTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
        if (_prototypeGenericsTableViewCell == nil)
        {
            _prototypeGenericsTableViewCell = [[CommonGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
        }
    }
    return _prototypeGenericsTableViewCell;
}

- (CommonEquipmentTableViewCell *)prototypeEquipmentTableViewCell
{
    if (_prototypeEquipmentTableViewCell == nil)
    {
        _prototypeEquipmentTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        if (_prototypeEquipmentTableViewCell == nil)
        {
            _prototypeEquipmentTableViewCell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        }
    }
    return _prototypeEquipmentTableViewCell;
}

- (NSMutableArray *)dataForTableView:(UITableView *)tableView withSection:(int)section
{
    if (section == 0)
        return self.nearmeVicinityEquipments;
    else
        return self.nearmeLocationEquipments;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
    NSString *string = kLocationTypeImmediateVicinity;
    if (section > 0)
        string = kLocationTypeCurrentLocation;

    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrayData = [self dataForTableView:tableView withSection:(int)section];
    return arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView withSection:(int)indexPath.section];

    CommonEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    if (cell == nil)
    {
        cell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    }
    cell.delegate = self;
    Equipment *equipment = [arrayData objectAtIndex:indexPath.row];
    if (equipment == nil || equipment.serial_no == nil)
        equipment = equipment;
    [cell bind:[arrayData objectAtIndex:indexPath.row] generic:nil type:CommonEquipmentCellTypeNearme];
    
    if (editingIndexPath != nil && editingIndexPath.row == indexPath.row && editingSection == indexPath.section)
    {
        editingIndexPath = indexPath;
        editingCell = cell;
        editingSection = (int)indexPath.section;
        [cell setEditor:YES animate:NO];
    }
     return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
            return [[self prototypeEquipmentTableViewCell] heightForCell];
    }
    return 30.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView withSection:(int)indexPath.section];
    
    Equipment *equipment = nil;
    if (arrayData.count <= indexPath.row)
        return;
    equipment = [arrayData objectAtIndex:indexPath.row];

    // save selected equipment to recent list
    [[ModelManager sharedManager] addRecentEquipment:equipment];

    // push new tab bar
    EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
    equipTabBar.equipment = equipment;
    
    // set animation style
#if USE_PUSHANIMATION_FOR_DETAILVIEW
    //equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
    equipTabBar.transitioningDelegate = [UIManager pushTransitioingDelegate];
    [self presentViewController:equipTabBar animated:YES completion:nil];
#else
    equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
    //equipTabBar.transitioningDelegate = [UIManager pushTransitioingDelegate];
    [self presentViewController:equipTabBar animated:YES completion:nil];
#endif

    
}

#pragma mark - swipe table view delegate
- (void)setEditing:(BOOL)editing atIndexPath:(id)indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell animate:(BOOL)animate
{
    CommonEquipmentTableViewCell *tableCell = (CommonEquipmentTableViewCell *)cell;
    [tableCell setEditor:editing];

    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
        editingSection = (int)((NSIndexPath*)indexPath).section;
    }
    else
    {
        editingSection = -1;
        editingCell = nil;
        editingIndexPath = nil;
    }
}

- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    //NSIndexPath *curIndexPath = (NSIndexPath *)indexPath;
    //int curRow = curIndexPath.row;
    //int calcingRow = recalcIndexPath.row;

    if (editing)
    {
        editingSection = (int)indexPath.section;
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    CommonEquipmentTableViewCell *tableCell = (CommonEquipmentTableViewCell *)cell;
    [tableCell setEditor:editing];
    
    
    if (!editing)
    {
        editingSection = -1;
        editingCell = nil;
        editingIndexPath = nil;
    }
    
    return calcedIndexPath;
}

- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
        return YES;
    return NO;
}

#pragma mark - Refresh pulled
- (void) refreshPulled
{
    NSLog(@"refreshPulled");
    [self.refresh beginRefreshing];
    
    // rerequest with nearme request
    NSMutableArray *arrayBeacons = [[BackgroundTaskManager sharedManager] nearmeBeacons];
#ifdef DEBUG
    if (arrayBeacons.count == 0)
    {
        [self.refresh endRefreshing];
    }
#endif
    [[BackgroundTaskManager sharedManager] requestLocationInfo:arrayBeacons complete:^() {
        
        // reload data
        [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
            
            [self loadData];
            
            // call end refreshing when get response
            [self.refresh endRefreshing];
            
            editingSection = 0;
            editingIndexPath = nil;
            editingCell = nil;
            
            [self.tableView reloadData];
        }];
        
    }];
}

- (void) onChanged:(id)sender
{
    if (_firstLoad)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self loadData];
        
        editingCell = nil;
        editingIndexPath = nil;
        editingSection = 0;
        
        [self.tableView reloadData];
    });
}

- (void)onScannedBeaconChanged:(NSNotification *)sender
{
    // get beacons from
    dispatch_async(dispatch_get_main_queue(), ^() {

        if (_isShowing) {
            if ([sender.object isEqual:@(YES)])
            {
                // audio service play
                //AudioServicesPlaySystemSound(1315);
                AudioServicesPlaySystemSound(1054);
                //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
        
        // refresh table
        self.nearmeVicinityEquipments = [[NSMutableArray alloc] initWithArray:[BackgroundTaskManager sharedManager].arrayVicinityEquipments];
        
        [self.tableView reloadData];
        
        if ([self.refresh isRefreshing])
            [self.refresh endRefreshing];
    });
}

- (void)onFoundEquipmentsChanged:(id)sender
{
    if (_firstLoad)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self loadData];
        
        editingCell = nil;
        editingIndexPath = nil;
        editingSection = 0;
        
        [self.tableView reloadData];
    });
}

#pragma mark - CommonEquipmentTableViewCellDelegate
- (void)onEquipmentPage:(Equipment *)equipment
{
    [[PagingManager sharedInstance] startPaging:equipment];
}

- (void)onSwipeLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    //
}

- (void)onSwipeRight:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    //
}

@end
