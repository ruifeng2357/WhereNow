//
//  EquipmentTabBarController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "EquipmentTabBarController.h"
#import "DetailBaseTableViewController.h"
#import "BackgroundTaskManager.h"
#import "LocatingManager.h"
#import "PagingManager.h"
#import "ServerManager.h"
#import "UserContext.h"

static EquipmentTabBarController *_sharedEquipmentTabBarController = nil;

@interface EquipmentTabBarController () <UIActionSheetDelegate>
{
    DetailBaseTableViewController *menuSender;
}

@end

@implementation EquipmentTabBarController

+ (EquipmentTabBarController *)sharedInstance
{
    return _sharedEquipmentTabBarController;
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
    
    for (UINavigationController *nav in self.viewControllers) {
        DetailBaseTableViewController *vc = (DetailBaseTableViewController *)[[nav viewControllers] objectAtIndex:0];
        vc.delegate = self;
    }
    
    _sharedEquipmentTabBarController = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _sharedEquipmentTabBarController = nil;
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


#pragma mark - menu delegate
- (void)onMenu:(id)sender
{
    NSString *title;
    if ([[BackgroundTaskManager sharedManager].arrayVicinityEquipments containsObject:self.equipment])
    {
        title = @"Alert Device";
    }
    else
    {
        if ([self.equipment.islocating boolValue])
        {
            title = @"Cancel Device Page";
        }
        else
            title = @"Page Device";
    }
    
    menuSender = sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  title,
                                  @"Report for Service",
                                  nil];
    //    [actionSheet setTintColor:[UIColor darkGrayColor]];
    
    if (menuSender.menuItem == nil)
        [actionSheet showFromBarButtonItem:sender animated:YES];
    else
        [actionSheet showFromBarButtonItem:menuSender.menuItem animated:YES];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Page Device
        [self onPageDevice:self.equipment];
    }
    else if (buttonIndex == 1){
        // Report for Service
        [self onReportForService:self.equipment];
    }
}

- (void)onPageDevice:(Equipment *)equipment
{
    if ([[BackgroundTaskManager sharedManager].arrayVicinityEquipments containsObject:equipment])
    {
        // start paging
        [[PagingManager sharedInstance] startPaging:equipment];
        return;
    }
    else
    {
        if ([self.equipment.islocating boolValue])
        {
            [[LocatingManager sharedInstance] cancelLocatingEquipment:equipment];
            [menuSender didPagedDevice];
        }
        else
        {
            [[LocatingManager sharedInstance] locatingEquipment:equipment];
            [menuSender didPagedDevice];
        }
    }
}

- (void)onReportForService:(Equipment *)equipment
{
    //
}

- (void)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onMovementDataChanged:(NSNotification *)note
{
    
}

@end
