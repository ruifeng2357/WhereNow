//
//  BackgroundTaskManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 08/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "BackgroundTaskManager.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "AppContext.h"
#import "LocatingManager.h"

#define kPeriodOfStickBeaconMode        60 * 3

static BackgroundTaskManager *_sharedBackgroundTaskManager = nil;

@interface BackgroundTaskManager ()

@property (nonatomic, strong) NSMutableArray *arrayVicinityBeacons;
@property (nonatomic) BOOL stickBeaconMode;
@property (nonatomic, retain) NSTimer *timerForStickBeaconMode;
@property (nonatomic) BOOL consumeScanning;


@end

@implementation BackgroundTaskManager

+ (BackgroundTaskManager *)sharedManager
{
    if (_sharedBackgroundTaskManager == nil)
        _sharedBackgroundTaskManager = [[BackgroundTaskManager alloc] init];
    return _sharedBackgroundTaskManager;
}

- (id)init
{
    self = [super init];

    self.arrayVicinityBeacons = [[NSMutableArray alloc] init];
    
    self.arrayNearmeGenerics = [[NSMutableArray alloc] init];
    self.arrayVicinityEquipments = [[NSMutableArray alloc] init];
    self.arrayLocationEquipments = [[NSMutableArray alloc] init];
    
//    self.scanManager = [[ScanManager alloc] initWithDelegate:self];
    self.scanManager = [ScanManager sharedScanManager];
    self.stickBeaconManager = [StickerManager sharedManager];
    self.stickBeaconMode = NO;
    self.consumeScanning = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEquipmentsChanged:) name:kEquipmentsForGenericChanged object:nil];

    return self;
}

- (void)startScanning
{
    [self.scanManager start];
    //[self.stickBeaconManager startDiscover];
    
}

- (void)stopScanning
{
    [self.scanManager stop];
    if (self.stickBeaconMode)
        [self.stickBeaconManager stopDiscover];
}

- (NSMutableArray *)nearmeBeacons
{
    return self.arrayVicinityBeacons;
}

- (void)setConsumeScanning:(BOOL)consume
{
    _consumeScanning = consume;
    if (_consumeScanning)
        [self.scanManager setScanMode:ScanModeNearme];
    else
        [self.scanManager setScanMode:ScanModeNormal];
}

#pragma mark ScanManagerDelegate
- (void)didVicinityBeaconsFound:(NSMutableArray *)arrayBeacons hasNewBeacon:(BOOL)hasNewBeacon
{
    self.arrayVicinityBeacons = arrayBeacons;
    NSLog(@"didVicinityBeaconsFound : %@", self.arrayVicinityBeacons);
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        BOOL hasNewEquipment = NO;
        //if (hasNewBeacon) {
        
        NSMutableArray *newEquipments = [[NSMutableArray alloc] initWithArray:[self getVicinityEquipmentsWithBeacons:self.arrayVicinityBeacons]];
        for (Equipment *newone in newEquipments) {
            if (![self.arrayVicinityEquipments containsObject:newone])
            {
                hasNewEquipment = YES;
                break;
            }
        }
        self.arrayVicinityEquipments = newEquipments;
        
            // notification vicinity beacons changed
            [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundScannedBeaconChanged object:@(hasNewEquipment)];
        //}
    });
    
    [self requestLocationInfo:self.arrayVicinityBeacons complete:^() {
        // post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundUpdateLocationInfoNotification object:nil userInfo:nil];
    }];
    
    [self checkLocatingBeacons:self.arrayVicinityBeacons];
}

- (NSArray *)getVicinityEquipments
{
    NSMutableArray *arrayEquipments = [[NSMutableArray alloc] initWithArray:[self getVicinityEquipmentsWithBeacons:self.arrayVicinityBeacons]];
    return arrayEquipments;
}

- (void)didBeaconsFound:(NSMutableArray *)arrayBeacons
{
 
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        BOOL hasNewEquipment = NO;
        
        NSMutableArray *newEquipments = [[NSMutableArray alloc] initWithArray:[self getVicinityEquipmentsWithBeacons:self.arrayVicinityBeacons]];
        for (Equipment *newone in newEquipments) {
            if (![self.arrayVicinityEquipments containsObject:newone])
            {
                hasNewEquipment = YES;
                break;
            }
        }
        if (hasNewEquipment) {
            self.arrayVicinityEquipments = newEquipments;
            
            // notification vicinity beacons changed
            [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundScannedBeaconChanged object:@(hasNewEquipment)];
        }
    });
    
    [self checkLocatingBeacons:arrayBeacons];
}

- (void)checkLocatingBeacons:(NSMutableArray *)arrayBeacons
{
    NSLog(@"checkLocatingBeacons in BackgroundTaskManager");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[LocatingManager sharedInstance] checkLocatingBeacons:arrayBeacons];
    });
}

#pragma mark Request nearme generics/equipments
- (void)requestLocationInfo:(NSMutableArray *)arrayBeacons complete:(void (^)())complete
{
#if 0
    NSMutableArray *arrayBeaconsForRequest = [[NSMutableArray alloc] init];
    if (arrayBeacons.count > 0)
    {
        CLBeacon *nearestBeacon = [arrayBeacons objectAtIndex:0];
        for (CLBeacon *beacon in arrayBeacons)
        {
            if (nearestBeacon.rssi == 0)
                nearestBeacon = beacon;
            else
            {
                if (beacon.rssi == 0)
                    continue;
                if (nearestBeacon.rssi < beacon.rssi)
                    nearestBeacon = beacon;
            }
        }
        [arrayBeaconsForRequest addObject:nearestBeacon];
    }
    // send request in background
    [[ServerManager sharedManager] getCurrLocationV2:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId arrayBeacons:arrayBeaconsForRequest success:^(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments) {

        [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
            self.arrayNearmeGenerics = arrayGenerics;
            //self.arrayVicinityEquipments = arrayVicinityEquipments;
            self.arrayLocationEquipments = arrayLocationEquipments;
            
            NSLog(@"getCurrLocationV2 : %d - %d - %d", (int)self.arrayNearmeGenerics.count, (int)self.arrayVicinityEquipments.count, (int)self.arrayLocationEquipments.count);
            
            if (self.arrayLocationEquipments.count > 0)
            {
                Equipment *equipment = [self.arrayLocationEquipments objectAtIndex:0];
                if (equipment)
                {
                    if (![[UserContext sharedUserContext].currentLocation isEqualToString:equipment.current_location])
                    {
                        // changed current location
                        //[UserContext sharedUserContext].currentLocation = equipment.current_location;
                        //[[NSNotificationCenter defaultCenter] postNotificationName:kCurrentLocationChanged object:nil];
                    }
                }
            }
            
            complete();
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kVicinityBeaconsChanged object:nil];
        }];
        
    } failure:^(NSString *msg) {
        complete();
    }];
#else
    // send request in background
    if ([AppContext sharedAppContext].locationId == nil || [AppContext sharedAppContext].locationId.length == 0)
    {
        // not get location_id
        complete();
    }
    else
    {
        [[ServerManager sharedManager] getCurrLocationWithLocationId:[AppContext sharedAppContext].locationId sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^(NSMutableArray *arrayLocationEquipments) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
                // self.arrayNearmeGenerics = arrayGenerics;
                // self.arrayVicinityEquipments = arrayVicinityEquipments;
                self.arrayLocationEquipments = arrayLocationEquipments;
                
                if (self.arrayLocationEquipments.count > 0)
                {
                    Equipment *equipment = [self.arrayLocationEquipments objectAtIndex:0];
                    if (equipment)
                    {
                        if (![[UserContext sharedUserContext].currentLocation isEqualToString:equipment.current_location])
                        {
                            // changed current location
                            [UserContext sharedUserContext].currentLocation = equipment.current_location;
                            [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentLocationChanged object:nil];
                        }
                    }
                    
                    // remove it becase vicinity equipments array contains it
                    for (Equipment *equipment in self.arrayVicinityEquipments) {
                        if ([self.arrayLocationEquipments containsObject:equipment])
                            [self.arrayLocationEquipments removeObject:equipment];
                    }
                }
                
                complete();
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kVicinityBeaconsChanged object:nil];
            }];
            
        } failure:^(NSString *msg) {
            complete();
        }];
    }
#endif
    
}

- (void)changeToStickBeaconMode
{
    self.stickBeaconMode = YES;
    [self.scanManager stop];
    
    [self.stickBeaconManager startDiscover];
    self.timerForStickBeaconMode = [NSTimer scheduledTimerWithTimeInterval:kPeriodOfStickBeaconMode target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)cancelStickBeaconMode
{
    if (self.timerForStickBeaconMode)
    {
        [self.timerForStickBeaconMode invalidate];
        self.timerForStickBeaconMode = nil;
    }
    
    [self.stickBeaconManager stopDiscover];
    self.stickBeaconMode = NO;
    [self.scanManager start];
}

- (void)onTimer:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self cancelStickBeaconMode];
    });
}

#pragma utilities
- (NSArray *)getVicinityEquipmentsWithBeacons:(NSArray *)beacons
{
    NSMutableArray *arrayEquipments = [[NSMutableArray alloc] init];
    NSArray *arrayExistEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
    for (CLBeacon *beacon in beacons) {
        // find equipment with uuid/major/minor
        NSString *uuid = beacon.proximityUUID.UUIDString;
        int major = [beacon.major intValue];
        int minor = [beacon.minor intValue];
        for (Equipment *equipment in arrayExistEquipments) {
            NSLog(@"%@", equipment.uuid);
            if ([equipment.minor intValue] == 51)
                NSLog(@"%d", [equipment.minor intValue]);
            if ([equipment.uuid isEqualToString:uuid] &&
                [equipment.major intValue] == major &&
                [equipment.minor intValue] == minor)
            {
                if (![arrayEquipments containsObject:equipment])
                    [arrayEquipments addObject:equipment];
                break;
            }
        }
    }
    return arrayEquipments;
}

- (void)onEquipmentsChanged:(NSNotification *)note
{
    self.arrayVicinityEquipments = [[NSMutableArray alloc] initWithArray:[self getVicinityEquipments]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundScannedBeaconChanged object:nil];
}

@end
