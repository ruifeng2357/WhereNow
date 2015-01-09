//
//  AppDelegate.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AppDelegate.h"
#import "UserContext.h"
#import "AppContext.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "ResponseParseStrategy.h"
#import "BackgroundTaskManager.h"
#import "AdvertisingManager.h"
#import "ServerManagerHelper.h"

#import "TriggeredAlertsTableViewController.h"
#import "FoundEquipmentTableViewController.h"

#import "EquipmentTabBarController.h"
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate () <UIAlertViewDelegate, TriggeredAlertsTableViewControllerDelegate, FoundEquipmentTableViewControllerDelegate>

@property (nonatomic) BOOL bShownTriggeredAlerts;
@property (nonatomic) BOOL bShownFoundEquipment;
@property (nonatomic, retain) UIAlertView *alertViewTriggeredAlerts;
@property (nonatomic, retain) UIAlertView *alertViewFoundEquipments;
@property (nonatomic, retain) UIAlertView *alertViewElse;
@property (nonatomic, retain) NSMutableArray *arrayFoundEquipments;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // crashlytics
    [Crashlytics startWithAPIKey:@"e467cd6020d75f85b44de28ff41ad8839ce00efd"];
    
    // Override point for customization after application launch.
    [[ModelManager sharedManager] initModelManager];
    [ServerManager sharedManager].parser = [ResponseParseStrategy sharedParseStrategy];
    
    // have to start scanning after logged in
    //[[BackgroundTaskManager sharedManager] startScanning];
    
    if ([UIApplication sharedApplication].backgroundRefreshStatus)
        NSLog(@"backgroundRefreshStatus : YES");
    else
        NSLog(@"backgroundRefreshStatus : NO");
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
#else
    // register push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    
    if (launchOptions != nil) {
        // Launched from push notification
        NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"Launched from push notification : %@", notification);
        
        NSString *alert_type = [notification objectForKey:kRemoteNotificationTypeKey];
        if (alert_type != nil && [alert_type isEqualToString:kRemoteNotificationTypeAlert])
        {
            NSObject *obj = [notification objectForKey:@"alert_id"];
            if (obj != nil)
            {
                int alert_id = [(NSNumber *)obj intValue];
                [[ModelManager sharedManager] addTriggeredAlert:alert_id];
            }

            [self performSelectorOnMainThread:@selector(showTriggeredAlerts) withObject:nil waitUntilDone:NO];
        }
    }
    
    return YES;
}

- (void)showTriggeredAlerts
{
    if (self.bShownTriggeredAlerts)
        return;
    
    self.bShownTriggeredAlerts = YES;
    
    // show
    UINavigationController *vcNav = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"TriggeredNavViewController"];
    TriggeredAlertsTableViewController *vc = [vcNav.viewControllers objectAtIndex:0];
    vc.delegate = self;
    
    if ([EquipmentTabBarController sharedInstance])
        [[EquipmentTabBarController sharedInstance] presentViewController:vcNav animated:YES completion:nil];
    else
        [self.window.rootViewController presentViewController:vcNav animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // save contex
    // [[ModelManager sharedManager] saveContext];
    
    // cancel stick beacon mode
    [[BackgroundTaskManager sharedManager] cancelStickBeaconMode];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // request data
    if ([UserContext sharedUserContext].isLoggedIn)
    {
        // get generics again
        [[ServerManagerHelper sharedInstance] getGenerics];
        
        // get device activate state
        [[ServerManager sharedManager] checkDeviceRemoved:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId tokenId:[UserContext sharedUserContext].tokenId success:^(BOOL removed) {
            if (removed)
            {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self logout];
                });
            }
        } failure:^(NSString *msg) {
            NSLog(@"checkDeviceRemove on didBecomeActive failed : %@", msg);
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // save context
    // [[ModelManager sharedManager] saveContext];
}

#pragma mark - APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
#if TARGET_IPHONE_SIMULATOR
    
#else

    NSString* cleanDeviceToken = [[[[deviceToken description]
                                    stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                   stringByReplacingOccurrencesOfString: @">" withString: @""]
                                  stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [AppContext sharedAppContext].cleanDeviceToken = cleanDeviceToken;
    
    NSLog(@"Registered for remote notifications  %@", cleanDeviceToken);
    
    // update device token
    if ([UserContext sharedUserContext].isLoggedIn)
    {
        [[ServerManager sharedManager] updateDeviceToken:cleanDeviceToken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId deviceName:[[UIDevice currentDevice] name] success:^(NSString *tokenId, NSString *locname, NSString *locid) {
            NSLog(@"device token registered : %@", cleanDeviceToken);
            [UserContext sharedUserContext].tokenId = tokenId;
            [UserContext sharedUserContext].currentLocation = locname;
            [UserContext sharedUserContext].currentLocationId = locid;
        } failure:^(NSString *msg) {
            NSLog(@"device token registering failed - %@", msg);
        }];
    }
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification ---------- \n%@", userInfo);
    
    NSString *alert_type = [userInfo objectForKey:kRemoteNotificationTypeKey];
    if (alert_type == nil)
    {
        completionHandler(UIBackgroundFetchResultFailed);
        return;
    }
    
    
    // alert
    if ([alert_type isEqualToString:kRemoteNotificationTypeAlert])
    {
        // store to local
        NSObject *obj = [userInfo objectForKey:@"alert_id"];
        if (obj != nil)
        {
            int alert_id = [(NSNumber *)obj intValue];
            [[ModelManager sharedManager] addTriggeredAlert:alert_id];
        }
        
        
        if (application.applicationState == UIApplicationStateActive) {
            
            completionHandler(UIBackgroundFetchResultNewData);
            
            // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
            if (!self.bShownTriggeredAlerts)
            {
                if (self.alertViewFoundEquipments != nil)
                    [self.alertViewFoundEquipments dismissWithClickedButtonIndex:0 animated:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                self.alertViewTriggeredAlerts = alertView;
                [alertView show];
            }
        }
        else {
            NSLog(@"application is not active ---");
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
    else if ([alert_type isEqualToString:kRemoteNotificationTypeWatch])
    {
        // watch
        if (application.applicationState == UIApplicationStateActive) {
            
            completionHandler(UIBackgroundFetchResultNewData);
            
            if (self.alertViewElse)
                [self.alertViewElse dismissWithClickedButtonIndex:0 animated:NO];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            self.alertViewElse = alertView;
            [alertView show];
        }
        else {
            NSLog(@"application is not active ---");
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
    else if ([alert_type isEqualToString:kRemoteNotificationTypeForcedLogout])
    {
        [self logout];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([alert_type isEqualToString:kRemoteNotificationLocation])
    {
        // current location changed -----------------
        /*
         {
             "alert_type" = locationtracked;
             aps =     {
                alert = "You have entered Delivery, open app to locate device";
                badge = 1;
                "content-available" = 1;
                sound = default;
             };
             "location_id" = 73;
             "location_name" = Delivery;
         }
         */
        NSObject *obj = [userInfo objectForKey:@"location_id"];
        if (obj != nil) {
            NSString *locationId = (NSString *)obj;
            
            obj = [userInfo objectForKey:@"location_name"];
            NSString *locationName = (NSString *)obj;

            // changed current location
            [UserContext sharedUserContext].currentLocation = locationName;
            [UserContext sharedUserContext].currentLocationId = locationId;
            [AppContext sharedAppContext].locationId = locationId;

            [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentLocationChanged object:nil];
            
            // rerequest with nearme request
            NSMutableArray *arrayBeacons = [[BackgroundTaskManager sharedManager] nearmeBeacons];
            [[BackgroundTaskManager sharedManager] requestLocationInfo:arrayBeacons complete:^() {
                completionHandler(UIBackgroundFetchResultNewData);
            }];
        }
        else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }
    else if ([alert_type isEqualToString:kRemoteNotificationEquipmentTracked])
    {
        // equipment moved
        NSObject *obj = [userInfo objectForKey:@"location_id"];
        NSString *obj1 = [userInfo objectForKey:@"equipment_id"];
        if (obj == nil || obj1 == nil || [obj isEqual:[NSNull null]] || [obj1 isEqual:[NSNull null]]) {
            NSLog(@"ignoring this message");
            // ignore this message
            completionHandler(UIBackgroundFetchResultNoData);
        }
        else {
            NSString *locationId = (NSString *)obj;
            int equipmentId = [(NSNumber *)obj1 intValue];
            // get equipment
            Equipment *equipment = [[ModelManager sharedManager] equipmentById:equipmentId];
            if (equipment == nil) {
                // ignore this message
                completionHandler(UIBackgroundFetchResultNoData);
            }
            else {
                // request movements for equipment
                [[ServerManager sharedManager] getMovementsForEquipment:equipment sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMovementsForEquipmentChanged object:equipment.equipment_id];
                    completionHandler(UIBackgroundFetchResultNewData);
                } failure:^(NSString *msg) {
                    NSLog(@"movements for equipment failed : %@", msg);
                    completionHandler(UIBackgroundFetchResultFailed);
                }];

            }
        }
    }
    else
    {
        completionHandler(UIBackgroundFetchResultFailed);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error != nil)
        NSLog(@"registering for remote notification failed : %@", [error description]);
    else
        NSLog(@"registering for remote notification failed");
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.alertViewTriggeredAlerts)
        [self showTriggeredAlerts];
    else if (alertView == self.alertViewFoundEquipments)
    {
        //[self showFoundEquipments];
        self.bShownFoundEquipment = NO;
    }
    else if (alertView == self.alertViewElse)
        self.alertViewElse = nil;
}

#pragma mark - TriggeredAlertsDelegate
- (void)didTriggeredAlertsDone:(TriggeredAlertsTableViewController *)vc
{
    [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    self.bShownTriggeredAlerts = NO;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // reset badge count
    NSString *token = [AppContext sharedAppContext].cleanDeviceToken;
    if (token != nil && token.length > 0)
    {
        [[ServerManager sharedManager] resetBadgeCountWithToken:token sessionId:[UserContext sharedUserContext].sessionId success:^{
            NSLog(@"resetbadge success!");
        } failure:^(NSString *msg) {
            NSLog(@"reset badge failed : %@", msg);
        }];
    }
}

#pragma mark - found equipments
- (void)foundEquipments:(NSMutableArray *)arrayFoundEquipments
{
    NSLog(@"foundEquipments : %@", arrayFoundEquipments);
    if (arrayFoundEquipments.count == 0)
        return;
    
    Equipment *firstEquipment = [arrayFoundEquipments objectAtIndex:0];
    NSString *equipmentNames = [NSString stringWithFormat:@"%@:%@", firstEquipment.model_name_no, firstEquipment.serial_no];
    for (int i = 1; i < arrayFoundEquipments.count; i++) {
        Equipment *equipment = [arrayFoundEquipments objectAtIndex:i];
        equipmentNames = [NSString stringWithFormat:@"%@, %@:%@", equipmentNames, equipment.model_name_no, equipment.serial_no];
    }
    
    NSString *msg = [NSString stringWithFormat:@"You are near by equipment %@!", equipmentNames];
    NSLog(@"notification locally : %@", msg);
    
    self.arrayFoundEquipments = [[NSMutableArray alloc] initWithArray:arrayFoundEquipments];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        
        if (!self.bShownFoundEquipment)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Found Equipments"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            self.alertViewFoundEquipments = alertView;
            self.bShownFoundEquipment = YES;
            [alertView show];
        }
    }
    else {
        NSLog(@"application is not active ---");
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.repeatInterval = NSDayCalendarUnit;
        [notification setAlertBody:msg];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }

}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
    if (!self.bShownFoundEquipment)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Found Equipments"
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        self.alertViewFoundEquipments = alertView;
        self.bShownFoundEquipment = YES;
        [alertView show];
    }

}

- (void)showFoundEquipments
{
    if (self.bShownFoundEquipment)
        return;
    
    self.bShownFoundEquipment = YES;
    
    // show
    UINavigationController *vcNav = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"FoundEquipmentNavViewController"];
    FoundEquipmentTableViewController *vc = [vcNav.viewControllers objectAtIndex:0];
    vc.arrayEquipments = self.arrayFoundEquipments;
    vc.delegate = self;
    
    if ([EquipmentTabBarController sharedInstance])
        [[EquipmentTabBarController sharedInstance] presentViewController:vcNav animated:YES completion:nil];
    else
        [self.window.rootViewController presentViewController:vcNav animated:YES completion:nil];
}

#pragma mark - FoundEquipmentTableViewControllerDelegate
- (void)didFoundEquipmentDone:(FoundEquipmentTableViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
    self.bShownFoundEquipment = NO;
}

#pragma mark - logout
- (void)logout
{
    // call api
    [[ServerManager sharedManager] userLogout:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId tokenId:[UserContext sharedUserContext].tokenId isRemote:NO success:^(NSString *tokenId) {
        //
    } failure:^(NSString * msg) {
        //
    }];
    
    // save status
    [UserContext sharedUserContext].isLoggedIn = NO;
    [UserContext sharedUserContext].isLastLoggedin = NO;
    
    // stop scanning
    [[BackgroundTaskManager sharedManager] stopScanning];
    
    // stop advertising
    [[AdvertisingManager sharedInstance] stop];
    
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav popToRootViewControllerAnimated:YES];
}


@end
