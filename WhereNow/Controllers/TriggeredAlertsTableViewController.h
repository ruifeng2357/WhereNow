//
//  TriggeredAlertsTableViewController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 21/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelManager.h"

@class TriggeredAlertsTableViewController;

@protocol TriggeredAlertsTableViewControllerDelegate <NSObject>

- (void)didTriggeredAlertsDone:(TriggeredAlertsTableViewController *)vc;

@end

@interface TriggeredAlertsTableViewController : UITableViewController

@property (nonatomic, weak) id<TriggeredAlertsTableViewControllerDelegate> delegate;

@end

@interface TriggeredAlertObject : NSObject

@property (nonatomic, retain) TriggeredAlert *triggered_alert;
@property (nonatomic, retain) Alert *alert;
@property (nonatomic, retain) Equipment *equipment;

@end