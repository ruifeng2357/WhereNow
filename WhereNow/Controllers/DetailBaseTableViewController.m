//
//  DetailBaseTableViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 07/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "DetailBaseTableViewController.h"

@interface DetailBaseTableViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) UISwipeGestureRecognizer *rightGesture;

@end

@implementation DetailBaseTableViewController

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
    
    self.rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    self.rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    self.rightGesture.delegate = self;
    [self.tableView addGestureRecognizer:self.rightGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMovementDataChanged:) name:kMovementsForEquipmentChanged object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSwipeRight:(id)sender
{
    if (self.delegate)
        [self.delegate onBack:sender];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (void)didPagedDevice
{
    //
}

- (void)onMovementDataChanged:(NSNotification *)note
{
    
}

@end
