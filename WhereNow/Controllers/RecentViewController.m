//
//  RecentViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "RecentViewController.h"
#import "SwipeTableView.h"
#import "AppContext.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ModelManager.h"

#import "RecentEquipmentsViewController.h"
#import "CommonGenericTableViewCell.h"
#import "CommonEquipmentTableViewCell.h"
#import "CommonLocationTableViewCell.h"

@interface RecentViewController () <SwipeTableViewDelegate, CommonGenericTableViewCellDelegate, CommonEquipmentTableViewCellDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    NSMutableArray *_expandingLocationArray;
    BOOL _firstLoad;
    NSMutableArray *_equipmentArray;
}

@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSMutableArray *recentGenericsArray;
@property (nonatomic, strong) NSMutableArray *recentEquipmentArray;
@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation RecentViewController

- (void)loadData
{
    self.recentGenericsArray = [[ModelManager sharedManager] retrieveRecentGenerics];
    self.recentEquipmentArray = [[ModelManager sharedManager] retrieveRecentEquipments];
    
    if (self.recentGenericsArray == nil || self.recentGenericsArray.count == 0)
    {
        if (self.recentEquipmentArray == nil || self.recentEquipmentArray.count == 0)
            self.arrayData = [[NSMutableArray alloc] init];
        else
            self.arrayData = [self.recentEquipmentArray mutableCopy];
    }
    else
    {
        if (self.recentEquipmentArray == nil || self.recentEquipmentArray.count == 0)
            self.arrayData = [self.recentGenericsArray mutableCopy];
        else
        {
            self.arrayData = [[NSMutableArray alloc] init];
            int i = 0;
            int j = 0;
            while (i < self.recentGenericsArray.count && j < self.recentEquipmentArray.count) {
                Generic *generic = [self.recentGenericsArray objectAtIndex:i];
                Equipment *equipment = [self.recentEquipmentArray objectAtIndex:j];
                if ([generic.recenttime compare:equipment.recenttime] == NSOrderedDescending)
                {
                    [self.arrayData addObject:generic];
                    i++;
                }
                else
                {
                    [self.arrayData addObject:equipment];
                    j++;
                }
            }
            
            if (i == self.recentGenericsArray.count)
            {
                if (j == self.recentEquipmentArray.count)
                {
                    //
                }
                else
                {
                    for (int k = j; k < self.recentEquipmentArray.count; k++) {
                        [self.arrayData addObject:[self.recentEquipmentArray objectAtIndex:k]];
                    }
                }
            }
            else
            {
                for (int k = i; k < self.recentGenericsArray.count; k++) {
                    [self.arrayData addObject:[self.recentGenericsArray objectAtIndex:k]];
                }
            }
        }
    }
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
        
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingCell = nil;
    editingIndexPath = nil;
    
    
    [self loadData];
    
    _equipmentArray = self.recentEquipmentArray;
    
    // expandingLocationArray
    _expandingLocationArray = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonGenericTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonEquipmentTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonLocationTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChanged:) name:kGenericsChanged object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChanged:) name:kEquipmentsForGenericChanged object:nil];
    
    [self.indicator stopAnimating];
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
        editingCell = nil;
        editingIndexPath = nil;
        
        [_expandingLocationArray removeAllObjects];
        
        [self loadData];
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
    
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
    int count = (int)self.arrayData.count;
    count += _expandingLocationArray.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([self isGenericCell:indexPath])
    {
        NSManagedObject *obj = nil;
        if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
            obj = [self.arrayData objectAtIndex:indexPath.row];
        else
            obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
        
        NSString *entityName = [obj entity].name;
        if ([entityName isEqualToString:@"Generic"])
        {
            CommonGenericTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
            if (cell == nil)
            {
                cell = [[CommonGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
            }
            
            [cell bind:(Generic *)obj type:CommonGenericsCellTypeRecent];
            
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
            CommonEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
            if (cell == nil)
            {
                cell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
            }
            [cell bind:(Equipment *)obj generic:nil type:CommonEquipmentCellTypeRecent];
            cell.delegate = self;
            
            if (editingIndexPath != nil && editingIndexPath.row == indexPath.row)
            {
                editingIndexPath = indexPath;
                editingCell = cell;
                [cell setEditor:YES animate:NO];
            }
            return cell;
        }
    }
    else
    {
        CommonLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
        if (cell == nil)
        {
            cell = [[CommonLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonLocationTableViewCellIdentifier];
        }
        [cell bind:[_expandingLocationArray objectAtIndex:indexPath.row - editingIndexPath.row - 1]];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if ([self isGenericCell:indexPath])
        {
            NSManagedObject *obj = nil;
            if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
                obj = [self.arrayData objectAtIndex:indexPath.row];
            else
                obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
            
            NSString *entityName = [obj entity].name;
            if ([entityName isEqualToString:@"Generic"])
                return [[self prototypeGenericsTableViewCell] heightForCell];
            else
                return [[self prototypeEquipmentTableViewCell] heightForCell];
        }
        else
            return [[self prototypeLocationTableViewCell] heightForCell];
    }
    return 30.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if ([self isGenericCell:indexPath])
    {
        NSManagedObject *obj = nil;
        if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
            obj = [self.arrayData objectAtIndex:indexPath.row];
        else
            obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
        
        NSString *entityName = [obj entity].name;
        if ([entityName isEqualToString:@"Generic"])
        {
            RecentEquipmentsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentEquipmentsViewController"];
            vc.generic = (Generic *)obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            Equipment *equipment = nil;
            equipment = (Equipment *)obj;
            
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
    }
    else
    {
        // location cell
    }
}

#pragma mark - swipe table view delegate
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    if ([self isGenericCell:indexPath])
        return YES;
    return NO;
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
    

    if (![self isGenericCell:indexPath])
    {
        return recalcIndexPath;
    }

    
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    

    if (![self isGenericCell:indexPath])
    {
        //
    }
    else
    {
        NSManagedObject *obj = nil;
        if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
            obj = [self.arrayData objectAtIndex:indexPath.row];
        else
            obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
        
        NSString *entityName = [obj entity].name;
        if ([entityName isEqualToString:@"Generic"])
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
        else
        {
            CommonEquipmentTableViewCell *tableCell = (CommonEquipmentTableViewCell *)cell;
            [tableCell setEditor:editing];
        }
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

#pragma mark - CommonGenericTableViewCellDelegate
- (void)onGenericDelete:(Generic *)generic
{
}

- (void)onGenericLocate:(Generic *)generic
{
}

- (void)onGenericFavorite:(Generic *)generic
{
}

#pragma mark - CommonEquipmentTableViewCellDelegate
- (void)onEquipmentDelete:(Equipment *)equipment
{
}

- (void)onEquipmentLocate:(Equipment *)equipment
{
}

- (void)onEquipmentFavorite:(Equipment *)equipment
{
}

- (void)onDataChanged:(id)sender
{
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
    
    
    [self loadData];
    
    _equipmentArray = self.recentEquipmentArray;
    
    // expandingLocationArray
    _expandingLocationArray = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
    [self.indicator stopAnimating];
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
}

- (void)onSwipeLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    //
}


@end
