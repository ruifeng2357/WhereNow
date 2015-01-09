//
//  RecentEquipmentsViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 19/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "RecentEquipmentsViewController.h"
#import "ModelManager.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "CommonEquipmentTableViewCell.h"
#import "ServerManagerHelper.h"

@interface RecentEquipmentsViewController () {
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    
    UIBarButtonItem *_backButton;
}

@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSMutableArray *arrayEquipments;

@end

@implementation RecentEquipmentsViewController

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
    
    editingCell = nil;
    editingIndexPath = nil;
    
    if (self.generic)
        self.arrayEquipments = [[ModelManager sharedManager] equipmentsForGeneric:self.generic withBeacon:YES];
    else
        self.arrayEquipments = [[NSMutableArray alloc] init];
    
    // back button
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    // set title of navigation item
    if (self.generic)
    {
        self.navigationItem.title = self.generic.generic_name;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonEquipmentTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEquipmentsChanged:) name:kEquipmentsForGenericChanged object:nil];
    
    [[ServerManagerHelper sharedInstance] getEquipmentsForGeneric:self.generic];

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

#pragma mark Table View Data Source
static CommonEquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayEquipments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self prototypeEquipmentTableViewCell] heightForCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    if (cell == nil)
    {
        cell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    }
    [cell bind:[self.arrayEquipments objectAtIndex:indexPath.row] generic:self.generic type:CommonEquipmentCellTypeRecent];
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Equipment *equipment = nil;
    equipment = [self.arrayEquipments objectAtIndex:indexPath.row];
    
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
    
    equipTabBar.view.frame = [MainTabBarController sharedInstance].view.bounds;
    equipTabBar.providesPresentationContextTransitionStyle = YES;
    equipTabBar.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:equipTabBar animated:YES completion:nil];
#endif
    
}

#pragma mark - swipe table view delegate
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)setEditing:(BOOL)editing atIndexPath:(id)indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    if (editing)
    {
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
        editingCell = nil;
        editingIndexPath = nil;
    }
    
    return calcedIndexPath;
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell animate:(BOOL)animate
{
    [self setEditing:editing atIndexPath:indexPath cell:cell recalcIndexPath:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Back button
- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - swipetableview swipe delegate
- (void)onSwipeRight:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
//    if (self.segment.selectedSegmentIndex == 0)
//        return;
//    
//    self.segment.selectedSegmentIndex = 0;
//    
//    self.selectedGenerics = nil;
//    if (editingCell)
//        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
//    
//    editingIndexPath = nil;
//    editingCell = nil;
//    
//    [_expandingLocationArray removeAllObjects];
//    
//    if (_isSearching)
//    {
//        if (self.segment.selectedSegmentIndex == 0)
//            [self updateFilteredContentOfGenericsForName:_customSearchBar.text];
//        else
//            [self updateFilteredContentOfEquipmentForName:_customSearchBar.text];
//    }
//    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    [self onBack:nil];
}

- (void)onSwipeLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    //
}

- (void)onEquipmentsChanged:(NSNotification *)note {
    
    NSNumber *generic_id = (NSNumber *)note.object;
    if (generic_id == nil)
        return;
    if (generic_id.intValue != self.generic.generic_id.intValue)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        
        [self.indicator stopAnimating];
    });
}


@end
