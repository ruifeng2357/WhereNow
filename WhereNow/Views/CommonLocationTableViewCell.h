//
//  CommonLocationTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 09/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericLocation.h"

#define kDefaultCommonLocationTableViewCellIdentifier     @"CommonLocationTableViewCell"

@interface CommonLocationTableViewCell : UITableViewCell

@property (nonatomic, strong) GenericLocation *genericLocation;

- (void)bind:(GenericLocation *)genericLocation;
-(void)setEditor:(BOOL)editor;

// utility
- (CGFloat)heightForCell;

@end
