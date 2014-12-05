//
//  AdvertisingManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/11/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WHERENOW_DEFAULT_SERVICEID @"B125AA4F-2D82-401D-92E5-F962E8037F5C"
#define WHERENOW_DEFAULT_CHARACTERISTICID @"B125AA4F-2D82-401D-92E5-F962E8037F5D"

@interface AdvertisingManager : NSObject

+ (AdvertisingManager *)sharedInstance;
- (void)start;
- (void)stop;

@end
