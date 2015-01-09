//
//  FavoritesViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "FavoritesViewController.h"

#import "AppContext.h"
#import "SwipeTableView.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ModelManager.h"
#import "CommonGenericTableViewCell.h"
#import "CommonEquipmentTableViewCell.h"
#import "CommonLocationTableViewCell.h"
#import "ServerManagerHelper.h"

@interface FavoritesViewController () <SwipeTableViewDelegate, CommonGenericTableViewCellDelegate, CommonEquipmentTableViewCellDelegate> {
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    NSMutableArray *_expandingLocationArray;
    BOOL _firstLoad;
    NSMutableArray *_equipmentArray;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSMutableArray *favoritesGenericArray;
@property (nonatomic, strong) NSMutableArray *favoritesEquipmentArray;

@property (nonatomic, strong) Generic *selectedGeneric;

@end

@implementation FavoritesViewController

- (void)loadData
{
    ModelManager *manager = [ModelManager sharedManager];
    
    // generic array -----------
    self.favoritesGenericArray = [manager retrieveFavoritesGenerics];
    

    // equipment array -------------------
    self.favoritesEquipmentArray = [manager retrieveFavoritesEquipments];

   
    _equipmentArray = self.favoritesEquipmentArray;
    
   
    // expandingLocationArray
    _expandingLocationArray = [[NSMutableArray alloc] init];

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
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"favoriteicon_selected"]];
        
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingCell = nil;
    editingIndexPath = nil;
    
    [self loadData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonGenericTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonEquipmentTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonLocationTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGenericsChanged:) name:kGenericsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEquipmentsChanged:) name:kEquipmentsForGenericChanged object:nil];
    
    [self.indicator stopAnimating];
    
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
    
    if (!_firstLoad)
    {
        editingCell = nil;
        editingIndexPath = nil;
        
        self.favoritesGenericArray = [[ModelManager sharedManager] retrieveFavoritesGenerics];
        self.favoritesEquipmentArray = [[ModelManager sharedManager] retrieveFavoritesEquipments];
        
        if (self.segment.selectedSegmentIndex == 0)
        {
            //
        }
        else
        {
            if (self.selectedGeneric)
                _equipmentArray = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGeneric withBeacon:YES];
            else
                _equipmentArray = self.favoritesEquipmentArray;
        }
        
        [_expandingLocationArray removeAllObjects];
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
    
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

#pragma mark - actions
- (IBAction)onSegmentIndexChanged:(id)sender
{
    self.selectedGeneric = nil;
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    _equipmentArray = self.favoritesEquipmentArray;
    
    [_expandingLocationArray removeAllObjects];
    
    [self.tableView reloadData];
}

#pragma mark - tableview data source

static CommonGenericTableViewCell *_prototypeGenericsTableViewCell = nil;
static CommonEquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;
static CommonLocationTableViewCell *_prototypeLocationTableViewCell = nil;

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

- (CommonLocationTableViewCell *)prototypeLocationTableViewCell
{
    if (_prototypeLocationTableViewCell == nil)
    {
        _prototypeLocationTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
        if (_prototypeLocationTableViewCell == nil)
        {
            _prototypeLocationTableViewCell = [[CommonLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
        }
    }
    return _prototypeLocationTableViewCell;
}

- (NSArray *)dataForTableView:(UITableView *)tableView
{
    if (self.segment.selectedSegmentIndex == 0)
        return self.favoritesGenericArray;
    else
        return _equipmentArray;
}

- (BOOL)isGenericCell:(NSIndexPath *)indexPath
{
    BOOL isGenerics = YES;
    if (editingCell != nil)
    {
        if (indexPath.row <= editingIndexPath.row || indexPath.row > editingIndexPath.row + _expandingLocationArray.count)
            isGenerics = YES;
        else
            isGenerics = NO;
    }
    else
        isGenerics = YES;
    return isGenerics;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (int)[self dataForTableView:tableView].count;
    count += _expandingLocationArray.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if([self isGenericCell:indexPath])
        {
            CommonGenericTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
            if (cell == nil)
            {
                cell = [[CommonGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
            }
            
            if (indexPath.row <= editingIndexPath.row)
                [cell bind:[arrayData objectAtIndex:indexPath.row] type:CommonGenericsCellTypeFavorites];
            else
                [cell bind:[arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)] type:CommonGenericsCellTypeFavorites];
            
            cell.delegate = self;
            
            if (editingIndexPath != nil && editingIndexPath.row == indexPath.row)
            {
                editingIndexPath = indexPath;
                editingCell = cell;
                [cell setEditor:YES animate:NO];
            }
            return cell;
        }
        else
        {
            CommonLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
            if (cell == nil)
            {
                cell = [[CommonLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
            }
            if (_expandingLocationArray.count > indexPath.row - editingIndexPath.row - 1)
                [cell bind:[_expandingLocationArray objectAtIndex:indexPath.row - editingIndexPath.row - 1]];
            return cell;
        }
    }
    else
    {
        CommonEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        if (cell == nil)
        {
            cell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        }
        if (arrayData.count > indexPath.row)
        {
            [cell bind:[arrayData objectAtIndex:indexPath.row] generic:self.selectedGeneric type:CommonEquipmentCellTypeFavorites];
            cell.delegate = self;
            
            if (editingIndexPath != nil && editingIndexPath.row == indexPath.row)
            {
                editingIndexPath = indexPath;
                editingCell = cell;
                [cell setEditor:YES animate:NO];
            }
        }
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
        {
            if ([self isGenericCell:indexPath])
                return [[self prototypeGenericsTableViewCell] heightForCell];
            else
                return [[self prototypeLocationTableViewCell] heightForCell];
        }
        else
        {
            return [[self prototypeEquipmentTableViewCell] heightForCell];
        }
    }
    return 30.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //dispatch_async(dispatch_get_main_queue(), ^() {
    NSArray *arrayData = [self dataForTableView:tableView];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if ([self isGenericCell:indexPath])
        {
            self.selectedGeneric = ((CommonGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).generic;
            // set equipmentArray
            _equipmentArray = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGeneric withBeacon:YES];
            
            //[UIView animateWithDuration:0.3 animations:^{
                
                [self.segment setSelectedSegmentIndex:1];

                //[self.segment sendActionsForControlEvents:UIControlEventValueChanged];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            //}];
            
            // save selected generic to recent list
            [[ModelManager sharedManager] addRecentGeneric:self.selectedGeneric];
            
            // request equipment
            [[ServerManagerHelper sharedInstance] getEquipmentsForGeneric:self.selectedGeneric];
            self.indicator.hidden = NO;
            [self.indicator startAnimating];
        }
        else
        {
            // location cell
        }
    }
    else
    {
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
        
        equipTabBar.view.frame = [MainTabBarController sharedInstance].view.bounds;
        equipTabBar.providesPresentationContextTransitionStyle = YES;
        equipTabBar.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:equipTabBar animated:YES completion:nil];
#endif
    }
    //});
}

#pragma mark - swipe table view delegate
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    if (self.segment.selectedSegmentIndex == 0)
    {
        if ([self isGenericCell:indexPath])
            return YES;
        return NO;
    }
    else
        return YES;
}


- (void)setEditing:(BOOL)editing atIndexPath:(id)indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    //NSIndexPath *curIndexPath = (NSIndexPath *)indexPath;
    //int curRow = curIndexPath.row;
    //int calcingRow = recalcIndexPath.row;
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if (![self isGenericCell:indexPath])
        {
            return recalcIndexPath;
        }
    }
   
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if (![self isGenericCell:indexPath])
        {
            //
        }
        else
        {
            
            CommonGenericTableViewCell *tableCell = (CommonGenericTableViewCell *)cell;
            [tableCell setEditor:editing];
            
            
            if (editing)
            {
                // get location arrays
                [_expandingLocationArray removeAllObjects];
                
                _expandingLocationArray = [[ModelManager sharedManager] locationsForGeneric:tableCell.generic];
                
                
                // expand cell
                if (_expandingLocationArray.count > 0)
                {
                    [self.tableView beginUpdates];
                    NSMutableArray *newRows = [[NSMutableArray alloc] init];
                    for (int i = 0; i < _expandingLocationArray.count; i++) {
                        [newRows addObject:[NSIndexPath indexPathForRow:editingIndexPath.row + i + 1 inSection:0]];
                    }
                    [self.tableView insertRowsAtIndexPaths:newRows withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            }
            else
            {
                // collapse cell
                
                if (_expandingLocationArray.count > 0)
                {
                    NSMutableArray *deleteRows = [[NSMutableArray alloc] init];
                    for (int i = 0; i < _expandingLocationArray.count; i++) {
                        [deleteRows addObject:[NSIndexPath indexPathForRow:editingIndexPath.row + i + 1 inSection:0]];
                    }
                    
                    if (recalcIndexPath != nil && recalcIndexPath.section == editingIndexPath.section)
                    {
                        //int row1 = recalcIndexPath.row;
                        //int row2 = editingIndexPath.row;
                        if (recalcIndexPath.row >= editingIndexPath.row + _expandingLocationArray.count + 1)
                        {
                            calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row - _expandingLocationArray.count inSection:recalcIndexPath.section];
                        }
                    }
                    
                    [_expandingLocationArray removeAllObjects];
                    
                    
                    [self.tableView beginUpdates];
                    
                    [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            }
        }
    }
    else
    {
        CommonEquipmentTableViewCell *tableCell = (CommonEquipmentTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    
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
    if (tableView == self.tableView)
    {
        if (![self isGenericCell:indexPath])
            return NO;
        return YES;
    }
    return NO;
}

#pragma mark - GenericTableViewCellDelegate
- (void)onGenericDelete:(Generic *)generic
{
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    [_expandingLocationArray removeAllObjects];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        [self.favoritesGenericArray removeObject:generic];
    }
    else
    {
        //[_equipmentArray removeObject:generic];
    }
    
    [self.tableView reloadData];
}

- (void)onGenericLocate:(Generic *)generic
{
    //
}

- (void)onEquipmentDelete:(Equipment *)equipment
{
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    [_expandingLocationArray removeAllObjects];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        //[self.favoritesGenericArray removeObject:generic];
    }
    else
    {
        [_equipmentArray removeObject:equipment];
    }
    
    [self.tableView reloadData];
}

- (void)onEquipmentLocate:(Equipment *)equipment
{
    //
}

- (void)onGenericsChanged:(id)sender
{
    if (self.segment.selectedSegmentIndex == 1)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self reloadData];
        
        [self.indicator stopAnimating];
    });
}

- (void)onEquipmentsChanged:(id)sender
{
    if (self.segment.selectedSegmentIndex == 0)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self reloadData];
        
        [self.indicator stopAnimating];
    });
}

- (void)reloadData
{
    _firstLoad = YES;
    
    editingCell = nil;
    editingIndexPath = nil;
    
    self.selectedGeneric = nil;
    
    [self loadData];
    
    [self.tableView reloadData];
    
    [self.indicator stopAnimating];
}

#pragma mark - swipetableview swipe delegate
- (void)onSwipeRight:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (self.segment.selectedSegmentIndex == 0)
        return;
    
    self.segment.selectedSegmentIndex = 0;
    
    self.selectedGeneric = nil;
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    [_expandingLocationArray removeAllObjects];
    
//    if (_isSearching)
//    {
//        if (self.segment.selectedSegmentIndex == 0)
//            [self updateFilteredContentOfGenericsForName:_customSearchBar.text];
//        else
//            [self updateFilteredContentOfEquipmentForName:_customSearchBar.text];
//    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)onSwipeLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    //
}


@end
