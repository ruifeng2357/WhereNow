//
//  ServerManagerHelper.h
//  WhereNow
//
//  Created by Xiaoxue Han on 14/11/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerManager.h"
#import "ModelManager.h"
#import "BackgroundTaskManager.h"
#import "UserContext.h"
#import "AppContext.h"

@interface ServerManagerHelper : NSObject

+ (ServerManagerHelper *)sharedInstance;

- (void)getGenerics;
- (void)getEquipmentsForGeneric:(Generic *)generic;
- (void)getLocationsForGeneric:(Generic *)generic;
- (void)getMovementsForEquipment:(Equipment *)equipment;
- (void)refreshWholeEquipments;


@end
