//
//  ScanManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RightViewController.h"

//#define GLOBAL_UUID         @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define GLOBAL_UUID         @"B125AA4F-2D82-401D-92E5-F962E8037F5C"
//#define HOSPITAL_MAJOR      51

typedef NS_ENUM(NSUInteger, ScanMode) {
    ScanModeNormal,
    ScanModeNearme
};

typedef NS_ENUM(NSUInteger, VisibleMode) {
    VISIBLE_COMEIN = 0,
    VISIBLE_KEEP = 1,
    VISIBLE_GOOUT = 2
};

@interface ScannedBeacon : NSObject

@property (nonatomic, retain) CLBeacon *beacon;
@property (nonatomic) long lastScannedTime;

@end

@interface ReceivedBeacon : NSObject

@property (nonatomic, retain) CLBeacon *beacon;
@property (nonatomic) long lastScannedTime;
@property (nonatomic) int isVisible; // 0 : come in     1 : keep    2 : go out

@end

@protocol ScanManagerDelegate <NSObject>

@optional
// called when not same beacons found
- (void)didVicinityBeaconsFound:(NSMutableArray *)arrayBeacons hasNewBeacon:(BOOL)hasNewBeacon;

// called in beacon ranging callback
- (void)didBeaconsFound:(NSMutableArray *)arrayBeacons;

// called in Receive mode
- (void)didReceiveBeaconFound:(NSMutableArray *) arrBeacons;

- (void)didAssignBeaconFound:(NSMutableArray *) arrBeacons;

@end

@interface ScanManager : NSObject <CLLocationManagerDelegate>

+ (ScanManager *)sharedScanManager;

/**
 * 
 */
@property (nonatomic, weak) id<ScanManagerDelegate> delegate;
@property (nonatomic, weak) id<ScanManagerDelegate> delegateReceive;
@property (nonatomic, weak) id<ScanManagerDelegate> delegateAssign;
@property (nonatomic) ScanMode scanMode;

- (id)initWithDelegate:(id<ScanManagerDelegate>)delegate;
- (id)initWithDelegateReceive:(id<ScanManagerDelegate>)delegate;
- (id)initWithDelegateAssign:(id<ScanManagerDelegate>)delegate;

/**
 * start ranging & monitoring beacons
 */
- (void)start;
- (void)startReceiveMode;
- (void)startAssignMode;

/**
 * stop ranging & mornitoring
 */
- (void)stop;
- (void)stopReceiveMode;
- (void)stopAssignMode;

- (void)clearReceiveArray;

- (void)changeMode:(ScanMode)scanMode;

- (BOOL)isStarted;

+ (BOOL)locationServiceEnabled;

+ (BOOL)permissionEnabled;

@end
