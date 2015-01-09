//
//  MainTabBarController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController

+ (MainTabBarController *)sharedInstance;

- (void)setBadgeOnNearMe:(NSString *)badgeValue;

@end
