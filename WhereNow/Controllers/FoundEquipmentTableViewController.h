//
//  FoundEquipmentTableViewController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 29/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoundEquipmentTableViewController;

@protocol FoundEquipmentTableViewControllerDelegate <NSObject>

@required
- (void)didFoundEquipmentDone:(FoundEquipmentTableViewController *)vc;

@end

@interface FoundEquipmentTableViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *arrayEquipments;
@property (nonatomic, weak) id<FoundEquipmentTableViewControllerDelegate> delegate;

@end
