//
//  CommonGenericTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 08/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Generic.h"

#define kDefaultCommonGenericTableViewCellIdentifier     @"CommonGenericTableViewCell"

typedef enum {
    CommonGenericsCellTypeSearch = 0,
    CommonGenericsCellTypeFavorites,
    CommonGenericsCellTypeRecent,
    CommonGenericsCellTypeNearme
} CommonGenericsCellType;

@protocol CommonGenericTableViewCellDelegate <NSObject>

@optional
- (void)onGenericDelete:(Generic *)generic;
- (void)onGenericFavorite:(Generic *)generic;
- (void)onGenericLocate:(Generic *)generic;

@end

@interface CommonGenericTableViewCell : UITableViewCell

@property (nonatomic, retain) Generic *generic;
@property (assign, nonatomic) BOOL editor;
@property (nonatomic) CommonGenericsCellType cellType;

@property (nonatomic, weak) id<CommonGenericTableViewCellDelegate> delegate;

- (void)bind:(Generic *)generic type:(CommonGenericsCellType)cellType;
- (void)setEditor:(BOOL)editor;
- (void)setEditor:(BOOL)editor animate:(BOOL)animate;

// utility
- (CGFloat)heightForCell;

@end
