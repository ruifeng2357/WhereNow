 //
//  ScanManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ScanManager.h"
#include <sys/time.h>
#import <snfsdk/snfsdk.h>

#define kScanForEveryCertainSecs     1
#define kScanPeriodOnce             13
#define kScanTimout                 13
#define kScanReceive                22

static ScanManager *_sharedScanManager = nil;

@implementation ScannedBeacon


@end

@implementation ReceivedBeacon

@end


@interface ScanManager() {
    NSTimer *timer;
    NSTimer *timerReceive;
    NSTimer *timerAssign;
    long scanStartedTime;
    long scanEndedTime;
    long scanReceivedStartedTime;
    long scanReceivedEndedTime;
    long scanAssignStartedTime;
    long scanAssignEndedTime;
    int scanningMethod;
    long lastDelegateTime;
}

@property (retain, nonatomic) CLBeaconRegion *beaconRegion;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isStarted;
@property (nonatomic) BOOL isReceiveStarted;
@property (nonatomic) BOOL isAssignStarted;

@property (nonatomic, retain) NSMutableArray *prevScannedBeacons;
@property (nonatomic, retain) NSMutableArray *currScannedBeacons;
@property (nonatomic, retain) NSMutableArray *prevReceivedBeacons;
@property (nonatomic, retain) NSMutableArray *currReceivedBeacons;

@property (nonatomic, retain) NSMutableArray *prevAssignBeacons;
@property (nonatomic, retain) NSMutableArray *currAssignBeacons;

// sticknfind
@property (nonatomic, retain) LeDeviceManager *snfDeviceManager;

@end

@implementation ScanManager

+ (ScanManager *)sharedScanManager
{
    if (_sharedScanManager == nil)
    {
        _sharedScanManager = [[ScanManager alloc] initWithDelegate:self];
        _sharedScanManager = [[ScanManager alloc] initWithDelegateReceive:self];
        _sharedScanManager = [[ScanManager alloc] initWithDelegateAssign:self];
    }
    return _sharedScanManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initMembers];
    }
    
    return self;
}

- (id)initWithDelegate:(id<ScanManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        //
    }
    
    self.delegate = delegate;
    
    [self initMembers];
    
    return self;
}

- (id)initWithDelegateReceive:(id<ScanManagerDelegate>)delegateReceive
{
    self = [super init];
    if (self) {
        //
    }
    
    self.delegateReceive = delegateReceive;
    
    return self;
}

- (id)initWithDelegateAssign:(id<ScanManagerDelegate>)delegateAssign
{
    self = [super init];
    if (self) {
        //
    }
    
    self.delegateAssign = delegateAssign;
    
    return self;
}

- (void)initMembers
{
    self.isStarted = NO;
    self.isReceiveStarted = NO;
    self.isAssignStarted = NO;
    timer = nil;
    timerReceive = nil;
    timerAssign = nil;
    
    scanningMethod = kScanForEveryCertainSecs;
    self.scanMode = ScanModeNormal;
}

#pragma mark - public functions

- (void)start
{
    if (self.isStarted)
        return;
    
    self.prevScannedBeacons = [[NSMutableArray alloc] init];
    self.currScannedBeacons = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [self.locationManager requestAlwaysAuthorization];
#endif
    
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self initRegion];
    
    self.isStarted = YES;
    
    scanEndedTime = scanStartedTime = [self getCurrentMilliTime];
    
    lastDelegateTime = [self getCurrentMilliTime];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerProc:) userInfo:nil repeats:YES];
}

 - (void)startReceiveMode
{
    if (self.isReceiveStarted)
        return;
    
    self.isReceiveStarted = YES;
    scanReceivedStartedTime = scanReceivedEndedTime = [self getCurrentMilliTime];
    
    self.prevReceivedBeacons = [[NSMutableArray alloc] init];
    self.currReceivedBeacons = [[NSMutableArray alloc] init];
    
    timerReceive = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerReceiveProc:) userInfo:nil repeats:YES];
}

- (void)startAssignMode
{
    if (self.isAssignStarted)
        return;
    
    self.isAssignStarted = YES;
    scanAssignStartedTime = scanAssignEndedTime = [self getCurrentMilliTime];
    
    self.prevAssignBeacons = [[NSMutableArray alloc] init];
    self.currAssignBeacons = [[NSMutableArray alloc] init];
    
    timerAssign = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerAssignProc:) userInfo:nil repeats:YES];
}

- (void)stop
{
    if (timer)
        [timer invalidate];
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    
    self.isStarted = NO;
}

- (void)stopReceiveMode
{
    if (timerReceive)
        [timerReceive invalidate];
        
    self.isReceiveStarted = NO;
}

- (void)stopAssignMode
{
    if (timerAssign)
        [timerAssign invalidate];
    
    self.isAssignStarted = NO;
}


- (void)clearReceiveArray
{
    self.currReceivedBeacons = [[NSMutableArray alloc] init];
}

- (void)changeMode:(ScanMode)scanMode
{
    if (self.scanMode == scanMode)
        return;
    
    
    if (scanMode == ScanModeNormal)
    {
        scanEndedTime = [self getCurrentMilliTime];
    }
    
    _scanMode = scanMode;
}

- (BOOL)isStarted
{
    return _isStarted;
}

#pragma mark - scanning

- (long)getCurrentMilliTime
{
    struct timeval time;
    gettimeofday(&time, NULL);
    long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    return millis;
}

- (void)timerProc:(id)tm
{
}

- (void)timerAssignProc:(id)timer
{
    [self.delegateAssign didAssignBeaconFound:self.currAssignBeacons];
}

- (void)timerReceiveProc:(id)timer
{
    [self.delegateReceive didReceiveBeaconFound: self.currReceivedBeacons];
}


- (void)compareBeaconsAndDelegate
{
    // compare previous vicinity beacons
    BOOL isEqual =  YES;
    BOOL hasNewBeacon = NO;
    if (self.prevScannedBeacons.count != self.currScannedBeacons.count)
    {
        // not equal
        isEqual = NO;
        
        // check has new beacon
        for (ScannedBeacon *currScannedBeacon in self.currScannedBeacons) {
            BOOL isExist = NO;
            for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
                if ([currScannedBeacon.beacon.major intValue] == [scannedBeacon.beacon.major intValue]
                    && [currScannedBeacon.beacon.minor intValue] == [scannedBeacon.beacon.minor intValue])
                {
                    isExist = YES;
                }
            }
            if (!isExist) {
                hasNewBeacon = YES;
                break;
            }
        }
    }
    else
    {
        for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
            BOOL isExist = NO;
            for (ScannedBeacon *currScannedBeacon in self.currScannedBeacons) {
                if ([currScannedBeacon.beacon.major intValue] == [scannedBeacon.beacon.major intValue]
                    && [currScannedBeacon.beacon.minor intValue] == [scannedBeacon.beacon.minor intValue])
                {
                    isExist = YES;
                    break;
                }
            }
            
            if (isExist == NO)
            {
                isEqual = NO;
                hasNewBeacon = YES;
                break;
            }
        }
    }
    
    NSLog(@"compareBeaconsAndDelegate : %@\n %@\n%@", self.prevScannedBeacons, self.currScannedBeacons, (isEqual?@"same":@"Different"));
   
    if (!isEqual)
    {
        self.prevScannedBeacons = self.currScannedBeacons;
        self.currScannedBeacons = [[NSMutableArray alloc] init];
        
        // delegates
        if (self.delegate && [self.delegate respondsToSelector:@selector(didVicinityBeaconsFound:hasNewBeacon:)])
        {
            NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
            for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
                [arrayBeacons addObject:scannedBeacon.beacon];
            }
            [self.delegate didVicinityBeaconsFound:arrayBeacons hasNewBeacon:hasNewBeacon];
        }
    }
    else
    {
        NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
        for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
            [arrayBeacons addObject:scannedBeacon.beacon];
        }
        [self.delegate didBeaconsFound:arrayBeacons];
        self.currScannedBeacons = [[NSMutableArray alloc] init];
    }
}

#pragma mark - internal functions
- (void)initRegion {
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:GLOBAL_UUID];
#if 0
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:HOSPITAL_MAJOR
                                                           identifier:@"com.app.BeaconRegion"];
#else
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                           identifier:@"com.app.BeaconRegion"];
#endif
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        NSLog(@"error : cannot monitoring for class : clbeaconregion");
    }
    
    if (![CLLocationManager isRangingAvailable])
    {
        NSLog(@"error : cannot ranging");
    }
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"init region");
}

#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    //self.lblStatus.text = @"user entered in a range of beacon";
    
    NSLog(@"didEnterRegion -- ");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //[self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    //self.lblStatus.text = @"user exited in a range of beacon";
    
    NSLog(@"didExitRegion ---");
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"didStartMonitoringForRegion -- ");
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //NSLog(@"didRangeBeacons : %@", beacons);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        //
    }
    else
    {
        // expand time
    }
    
    // when change
    for (CLBeacon *beacon in beacons) {
        int beaconMajor = [beacon.major intValue];
        int beaconMinor = [beacon.minor intValue];
        int rssi = (int)beacon.rssi;
        
        NSLog(@"beacon(%d, %d) : %d", beaconMajor, beaconMinor, rssi);
        
        if (![self isVicinity:beacon])
        {
            // not
        }
        else
        {
            // add it to vicinity array
            // check exist
            BOOL isExist = NO;
            for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                if ([scannedBeacon.beacon.major intValue] == beaconMajor &&
                    [scannedBeacon.beacon.minor intValue] == beaconMinor)
                {
                    isExist = YES;
                    scannedBeacon.lastScannedTime = [self getCurrentMilliTime];
                    break;
                }
            }
            if (!isExist)
            {
                ScannedBeacon *newBeacon = [[ScannedBeacon alloc] init];
                newBeacon.beacon = beacon;
                newBeacon.lastScannedTime = [self getCurrentMilliTime];
                [self.currScannedBeacons addObject:newBeacon];
            }
            
            if (self.isReceiveStarted)
            {
                isExist = NO;
                for (ReceivedBeacon *receivedBeacon in self.prevReceivedBeacons) {
                    if ([receivedBeacon.beacon.major intValue] == beaconMajor && [receivedBeacon.beacon.minor intValue] == beaconMinor)
                    {
                        isExist = YES;
                        receivedBeacon.lastScannedTime = [self getCurrentMilliTime];
                        break;
                    }
                }
                if (!isExist)
                {
                    ReceivedBeacon *newBeacon = [[ReceivedBeacon alloc] init];
                    newBeacon.beacon = beacon;
                    newBeacon.isVisible = VISIBLE_COMEIN;
                    newBeacon.lastScannedTime = [self getCurrentMilliTime];
                    [self.prevReceivedBeacons addObject:newBeacon];
                }
            }
            
            if (self.isAssignStarted)
            {
                isExist = NO;
                for (ScannedBeacon *receivedBeacon in self.prevAssignBeacons) {
                    if ([receivedBeacon.beacon.major intValue] == beaconMajor && [receivedBeacon.beacon.minor intValue] == beaconMinor)
                    {
                        isExist = YES;
                        receivedBeacon.lastScannedTime = [self getCurrentMilliTime];
                        break;
                    }
                }
                if (!isExist)
                {
                    ScannedBeacon *newBeacon = [[ScannedBeacon alloc] init];
                    newBeacon.beacon = beacon;
                    newBeacon.lastScannedTime = [self getCurrentMilliTime];
                    [self.prevAssignBeacons addObject:newBeacon];
                }
            }
        }
    }
    
    NSLog(@"get curr time");
    if (self.isReceiveStarted)
    {
        [self.currReceivedBeacons removeAllObjects];
        NSMutableArray *removeReceiveBeacon = [[NSMutableArray alloc] init];
        for (ReceivedBeacon *item in self.prevReceivedBeacons)
        {
            long currTime = [self getCurrentMilliTime];
            
            switch (item.isVisible)
            {
                case VISIBLE_COMEIN:
                    [self.currReceivedBeacons addObject:item];
                    item.isVisible = VISIBLE_KEEP;
                    break;
                case VISIBLE_KEEP:
                    if (currTime - item.lastScannedTime > kScanReceive * 1000)
                    {
                        item.isVisible = VISIBLE_GOOUT;
                        [self.currReceivedBeacons addObject:item];
                        [removeReceiveBeacon addObject:item];
                    }
                    break;
            }
        }
        
        for (ReceivedBeacon *item in removeReceiveBeacon)
        {
            if (item.isVisible == VISIBLE_GOOUT)
                [self.prevReceivedBeacons removeObject:item];
        }
    }
    
    if (self.isAssignStarted)
    {
        [self.currAssignBeacons removeAllObjects];
        NSMutableArray *removeAssignBeacon = [[NSMutableArray alloc] init];
        for (ScannedBeacon *item in self.prevAssignBeacons)
        {
            long currTime = [self getCurrentMilliTime];
            
            if (currTime - item.lastScannedTime > kScanReceive * 1000)
            {
                [removeAssignBeacon addObject:item];
            }
            else
            {
                [self.currAssignBeacons addObject:item];
            }
        }
        
        for (ScannedBeacon *item in removeAssignBeacon)
        {
            [self.prevAssignBeacons removeObject:item];
        }
    }
    
    if (self.scanMode == ScanModeNormal)
    {
        
        // check time
        //if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
            long currTime = [self getCurrentMilliTime];
            if (currTime - lastDelegateTime > kScanPeriodOnce * 1000)
            {
                NSLog(@"compare and delegate");
                [self compareBeaconsAndDelegate];
                lastDelegateTime = [self getCurrentMilliTime];
            }
        //}
        //else {
        //    [self compareBeaconsAndDelegate];
        //}
        
    }
    else if (self.scanMode == ScanModeNearme)
    {
        long currTime = [self getCurrentMilliTime];
        
        // remove timed out beacons --------------------
        NSMutableArray *removeBeacons = [[NSMutableArray alloc] init];
        for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
            if (currTime - scannedBeacon.lastScannedTime > kScanTimout * 1000)
            {
                [removeBeacons addObject:scannedBeacon];
            }
        }
        
        for (ScannedBeacon *scannedBeacon in removeBeacons) {
            [self.currScannedBeacons removeObject:scannedBeacon];
        }
    
    
        // compare two arrays
        BOOL isEqual = YES;
        BOOL hasNewBeacon = NO;
        
        if (self.prevScannedBeacons.count != self.currScannedBeacons.count)
        {
            isEqual = NO;
            
            // check has new beacon
            for (ScannedBeacon *currScannedBeacon in self.currScannedBeacons) {
                BOOL isExist = NO;
                for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
                    if ([currScannedBeacon.beacon.major intValue] == [scannedBeacon.beacon.major intValue]
                        && [currScannedBeacon.beacon.minor intValue] == [scannedBeacon.beacon.minor intValue])
                    {
                        isExist = YES;
                    }
                }
                if (!isExist) {
                    hasNewBeacon = YES;
                    break;
                }
            }

        }
        else
        {
            for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
                BOOL isExist = NO;
                for (ScannedBeacon *currScannedBeacon in self.currScannedBeacons) {
                    if ([currScannedBeacon.beacon.major intValue] == [scannedBeacon.beacon.major intValue]
                        && [currScannedBeacon.beacon.minor intValue] == [scannedBeacon.beacon.minor intValue])
                    {
                        isExist = YES;
                        break;
                    }
                }
                
                if (isExist == NO)
                {
                    isEqual = NO;
                    hasNewBeacon = YES;
                    break;
                }
            }
        }
        
        if (!isEqual)
        {
            self.prevScannedBeacons = [self.currScannedBeacons copy];
            NSMutableArray *vicinityBeacons = [[NSMutableArray alloc] init];
            for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                [vicinityBeacons addObject:scannedBeacon.beacon];
            }
            
            //if (self.delegate && currTime - lastDelegateTime > 10 * 1000)
            {
                [self.delegate didVicinityBeaconsFound:vicinityBeacons hasNewBeacon:hasNewBeacon];
                lastDelegateTime = [self getCurrentMilliTime];
            }
        }
        else
        {
            if (self.delegate && currTime - lastDelegateTime > 10 * 1000)
            {
                NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
                for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                    [arrayBeacons addObject:scannedBeacon.beacon];
                }
                [self.delegate didBeaconsFound:arrayBeacons];
                lastDelegateTime = [self getCurrentMilliTime];
            }
        }
    }
}

#pragma mark - estimate vicinity
- (BOOL)isVicinity:(CLBeacon *)beacon
{
    if (beacon.proximity == CLProximityUnknown)
        return NO;
    if (beacon.proximity == CLProximityFar)
        return YES;
    if (beacon.proximity == CLProximityNear)
        return YES;
    if (beacon.proximity == CLProximityImmediate)
        return YES;
    return NO;
}

#pragma mark - Utility functions for location service
+ (BOOL)locationServiceEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)permissionEnabled
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return NO;
    }
    return NO;
#else
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    }
    return NO;
#endif
}


@end
