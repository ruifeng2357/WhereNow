//
//  EquipmentImage.h
//  WhereNow
//
//  Created by Xiaoxue Han on 25/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerManager.h"
#import "ModelManager.h"
#import "Equipment.h"

@interface EquipmentImage : NSObject

+ (void)setModelImageOfEquipment:(Equipment *)equipment toImageView:(UIImageView *)iv completed:(void(^)(UIImage *image))completionBlock;
+ (void)setManufacturerImageOfEquipment:(Equipment *)equipment toImageView:(UIImageView *)iv completed:(void(^)(UIImage *image))completionBlock;

@end
