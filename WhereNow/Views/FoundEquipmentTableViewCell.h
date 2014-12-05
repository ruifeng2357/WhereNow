//
//  FoundEquipmentTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sticker.h"
#import "Equipment.h"

@interface FoundEquipmentTableViewCell : UITableViewCell

@property (nonatomic, retain) Sticker *sticker;
@property (nonatomic, retain) Equipment *equipment;

- (void)stickerStateChanged;

@end
