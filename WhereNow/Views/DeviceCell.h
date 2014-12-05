//
//  DeviceCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 15/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceCell;

@protocol DeviceCellDelegate <NSObject>

@required
- (void)didCellRemoved:(DeviceCell *)cell;

@end

@interface DeviceCell : UITableViewCell

@property (nonatomic, retain) NSDictionary *deviceInfo;
@property (nonatomic, weak) id<DeviceCellDelegate> delegate;

@end
