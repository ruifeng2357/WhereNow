//
//  EquipmentTabBarController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Equipment.h"

@protocol EquipmentDetailMenuDelegate <NSObject>

@required
- (void)onMenu:(id)sender;
- (void)onBack:(id)sender;

@end

@interface EquipmentTabBarController : UITabBarController
<
UITabBarControllerDelegate,
EquipmentDetailMenuDelegate
>

@property (nonatomic, retain) Equipment *equipment;

+ (EquipmentTabBarController *)sharedInstance;

@end
