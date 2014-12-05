//
//  AdvertisingManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/11/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AdvertisingManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define ADVERTISING     0

static AdvertisingManager *_sharedAdvertisingManager = nil;

@interface AdvertisingManager() <CBPeripheralManagerDelegate>
{
    CBUUID *serviceUUID;
    CBUUID *characteristicUUID;
    
    CBMutableService *thisService;
    CBMutableCharacteristic *thisCharacteristic;
    //NSTimer *timer;
    
    NSDictionary *dicAdvData;
    BOOL isStopped;
}

@property (nonatomic, retain) CBPeripheralManager *peripheralManager;

@end

@implementation AdvertisingManager

+ (AdvertisingManager *)sharedInstance
{
    if (_sharedAdvertisingManager == nil)
        _sharedAdvertisingManager = [[AdvertisingManager alloc] init];
    return _sharedAdvertisingManager;
}

- (id)init
{
    self = [super init];
#if ADVERTISING
    [self initBluetooth];
#endif
    return self;
}

- (void)initBluetooth
{
    serviceUUID = [CBUUID UUIDWithString:WHERENOW_DEFAULT_SERVICEID];
    characteristicUUID = [CBUUID UUIDWithString:WHERENOW_DEFAULT_CHARACTERISTICID];
    
    thisCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
                                                            properties:CBCharacteristicPropertyNotify
                                                                 value:nil
                                                           permissions:CBAttributePermissionsReadable];
    thisService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    thisService.characteristics = @[thisCharacteristic];
    
    dicAdvData = @{CBAdvertisementDataServiceUUIDsKey : @[serviceUUID]};
    
    isStopped = YES;
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionRestoreIdentifierKey:@"com.nicholas.wherenow.peripheral"}];
}

- (void)start
{
#if ADVERTISING
    isStopped = NO;
    [self startAdvertising];
#endif
}

- (void)stop
{
#if ADVERTISING
    isStopped = YES;
    [self.peripheralManager stopAdvertising];
#endif
}

- (void)startAdvertising
{
    if (isStopped)
        return;
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        
        if (![self.peripheralManager isAdvertising])
        {
            NSLog(@"start advertising---");
            [self.peripheralManager removeAllServices];
            [self.peripheralManager addService:thisService];
            [self.peripheralManager startAdvertising:dicAdvData];
        }
    }
}

- (void)stopAdvertising
{
    [self.peripheralManager stopAdvertising];
}

#pragma mark - peripheral manager
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSArray *services = dict[CBPeripheralManagerRestoredStateServicesKey];
    NSDictionary *advData = dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
    
    if (services != nil && services.count > 0)
        thisService = services[0];
    
    if (advData != nil)
        dicAdvData = advData;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
#if ADVERTISING
    [self startAdvertising];
#endif
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"started advertising--");
}

@end
