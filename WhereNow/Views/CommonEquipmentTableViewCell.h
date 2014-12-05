//
//  CommonEquipmentTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 08/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Generic.h"
#import "Equipment.h"

#define kDefaultCommonEquipmentTableViewCellIdentifier     @"CommonEquipmentTableViewCell"

typedef enum {
    CommonEquipmentCellTypeSearch = 0,
    CommonEquipmentCellTypeFavorites,
    CommonEquipmentCellTypeRecent,
    CommonEquipmentCellTypeNearme
} CommonEquipmentCellType;

@class CommonEquipmentTableViewCell;

@protocol CommonEquipmentTableViewCellDelegate <NSObject>

@optional
- (void)onEquipmentDelete:(Equipment *)equipment;
- (void)onEquipmentFavorite:(Equipment *)equipment;
- (void)onEquipmentLocate:(Equipment *)equipment;
- (void)onEquipmentPage:(Equipment *)equipment;

@end


@interface CommonEquipmentTableViewCell : UITableViewCell

@property (nonatomic, strong) Equipment *equipment;
@property (nonatomic, strong) Generic *generic;

@property (assign, nonatomic) BOOL editor;
@property (nonatomic) CommonEquipmentCellType cellType;

@property (nonatomic, weak) id<CommonEquipmentTableViewCellDelegate> delegate;

- (void)bind:(Equipment *)equipment generic:(Generic *)generic type:(CommonEquipmentCellType)cellType;
-(void)setEditor:(BOOL)editor;
- (void)setEditor:(BOOL)editor animate:(BOOL)animate;

#pragma mark - utility
- (CGFloat)heightForCell;


@end
