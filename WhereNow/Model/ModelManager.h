//
//  ModelManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 06/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RightViewController.h"


#import "Generic.h"
#import "Equipment.h"
#import "GenericLocation.h"
#import "EquipMovement.h"
#import "Alert.h"
#import "MovementCount.h"
#import "TriggeredAlert.h"

#define SQLITE_DB_NAME      @"wherenow.sqlite"


@protocol RightViewDelegate <NSObject>

@optional
- (void) didGetDevicesInfo: (NSString *)regionName indevices:(NSString *) indevices withindevices:(NSString *) withindevices requesteddevices:(NSString *) requesteddevices outdevices:(NSString *)outdevices;

@end

@interface ModelManager : NSObject

@property (strong, readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, weak) id<RightViewDelegate> delegateRight;

+ (ModelManager *)sharedManager;

- (void)initModelManager;
- (id)initWithDelegate:(id<RightViewDelegate>)delegate;

- (void)saveContext;

- (NSMutableArray *)retrieveFavoritesGenerics;

- (NSMutableArray *)retrieveFavoritesEquipments;

- (NSMutableArray *)retrieveGenerics;

- (NSMutableArray *)retrieveEquipmentsWithHasBeacon:(BOOL)withBeacon;

- (NSMutableArray *)locationsForGeneric:(Generic *)generic;

- (NSMutableArray *)equipmentsForGeneric:(Generic *)generic withBeacon:(BOOL)withBeacon;

- (NSMutableArray *)retrieveGenericsWithKeyword:(NSString *)keyword;

- (NSMutableArray *)searchGenericsWithArray:(NSArray *)genericArray withKeyworkd:(NSString *)keyword;

- (NSMutableArray *)retrieveEquipmentsWithKeyword:(NSString *)keyword;

- (NSMutableArray *)searchEquipmentsWithArray:(NSArray *)equipmentArray withKeyword:(NSString *)keyword;

- (NSMutableArray *)searchEquipmentsWithGenerics:(Generic *)generic withKeyword:(NSString *)keyword;

- (NSMutableArray *)equipmovementsForEquipment:(Equipment *)equipment;

- (NSMutableArray *)retrieveAlertsForEquipment:(Equipment *)equipment;

- (NSMutableArray *)retrieveMovementCountForEquipment:(Equipment *)equipment;

- (NSMutableArray *)retrieveRecentGenerics;

- (NSMutableArray *)retrieveRecentEquipments;

- (void)addRecentGeneric:(Generic *)generic;
- (void)addRecentEquipment:(Equipment *)equipment;

- (Alert *)alertById:(int)alertId;

- (Equipment *)equipmentById:(int)equipmentId;

- (void)addTriggeredAlert:(int)alert_id;

- (NSMutableArray *)retrieveTriggeredAlerts;

- (NSMutableArray *)retrieveLocatingEquipments;

+ (NSString *)getEquipmentName:(Equipment *)equipment;

@end
