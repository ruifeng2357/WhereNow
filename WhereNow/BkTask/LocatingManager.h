//
//  LocatingManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 03/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipment.h"
#import "Generic.h"

@interface LocatingManager : NSObject

@property (nonatomic, retain) NSMutableArray *arrayLocatingEquipments;
@property (nonatomic, retain) NSMutableArray *arrayFoundTrackingEquipments;

+ (LocatingManager *)sharedInstance;
- (void)locatingEquipment:(Equipment *)equipment;
- (void)cancelLocatingEquipment:(Equipment *)equipment;
- (void)locatingGeneric:(Generic *)generic;
- (void)cancelLocatingGeneric:(Generic *)generic;
- (void)onLocatingGeneric:(Generic *)generic;

- (void)checkLocatingBeacons:(NSMutableArray *)arrayBeacons;

@end
