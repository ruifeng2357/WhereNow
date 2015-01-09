//
//  RecentEquipmentsViewController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 19/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Generic.h"
#import "SwipeTableView.h"
#import "MainTabBarController.h"

@interface RecentEquipmentsViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
SwipeTableViewDelegate
>

@property (nonatomic, strong) Generic *generic;

@end
