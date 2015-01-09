//
//  MainTabBarController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "MainTabBarController.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "ScanManager.h"
#import "BackgroundTaskManager.h"
#import "LocatingManager.h"
#import "ServerManagerHelper.h"

static MainTabBarController *_sharedMainTabBarController = nil;

@interface MainTabBarController ()

@end

@implementation MainTabBarController

+ (MainTabBarController *)sharedInstance
{
    return _sharedMainTabBarController;
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
    
    _sharedMainTabBarController = self;
    
    self.navigationController.navigationBarHidden = YES;
    
    // request generics again
    [[ServerManagerHelper sharedInstance] refreshWholeEquipments];
    
    
    // check location service enabled
    if ([ScanManager locationServiceEnabled]) {
        
        NSLog(@"Location Services Enabled");
        
        if(![ScanManager permissionEnabled]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        NSLog(@"Location Services Disabled");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"To enable, please go to Settings and turn on Location Service."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVicinityBeaconsChanged:) name:kVicinityBeaconsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFoundEquipmentsChanged:) name:kFoundEquipmentsChanged object:nil];
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
}

- (void)setBadgeOnNearMe:(NSString *)badgeValue
{
    [[[self.tabBar items] objectAtIndex:3] setBadgeValue:badgeValue];
}

- (void)onVicinityBeaconsChanged:(id)sender
{
    [self onFoundEquipmentsChanged:sender];
}

- (void)onFoundEquipmentsChanged:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        if ([BackgroundTaskManager sharedManager].arrayVicinityEquipments.count == 0)
            [self setBadgeOnNearMe:nil];
        else if ([LocatingManager sharedInstance].arrayFoundTrackingEquipments.count == 0)
            [self setBadgeOnNearMe:nil];
        else
        {
            int count = 0;
            for (CLBeacon *foundBeacon in [BackgroundTaskManager sharedManager].arrayVicinityEquipments) {
                if ([[LocatingManager sharedInstance].arrayFoundTrackingEquipments containsObject:foundBeacon])
                    count ++;
            }
            
            if (count == 0)
                [self setBadgeOnNearMe:nil];
            else
                [self setBadgeOnNearMe:[NSString stringWithFormat:@"%d", count]];
        }
    });
}

@end
