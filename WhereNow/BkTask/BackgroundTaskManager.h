//
//  BackgroundTaskManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 08/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanManager.h"
#import "StickerManager.h"

@interface BackgroundTaskManager : NSObject <ScanManagerDelegate>

+ (BackgroundTaskManager *)sharedManager;

@property (nonatomic, retain) ScanManager *scanManager;
@property (nonatomic, retain) StickerManager *stickBeaconManager;

@property (nonatomic, strong) NSMutableArray *arrayNearmeGenerics;
@property (nonatomic, strong) NSMutableArray *arrayVicinityEquipments;
@property (nonatomic, strong) NSMutableArray *arrayLocationEquipments;

- (void)startScanning;
- (void)stopScanning;

// immediate vicinity beacons
- (NSMutableArray *)nearmeBeacons;

- (void)setConsumeScanning:(BOOL)consume;

- (void)requestLocationInfo:(NSMutableArray *)arrayBeacons complete:(void(^)())complete;
- (NSArray *)getVicinityEquipments;

- (void)changeToStickBeaconMode;
- (void)cancelStickBeaconMode;

@end
