//
//  ServerManagerHelper.m
//  WhereNow
//
//  Created by Xiaoxue Han on 14/11/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ServerManagerHelper.h"

static ServerManagerHelper *_sharedServerManagerHelper = nil;

@implementation ServerManagerHelper

+ (ServerManagerHelper *)sharedInstance {
    if (_sharedServerManagerHelper == nil)
        _sharedServerManagerHelper = [[ServerManagerHelper alloc] init];
    return _sharedServerManagerHelper;
}

- (void)getGenerics
{
    [[ServerManager sharedManager] getGenerics:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGenericsChanged object:nil];
    } failure: ^(NSString *msg) {
        NSLog(@"Data request failed : %@", msg);
        [[NSNotificationCenter defaultCenter] postNotificationName:kGenericsChanged object:nil];
    }];
}

- (void)getEquipmentsForGeneric:(Generic *)generic
{
    // request equipments for selected generic
    [[ServerManager sharedManager] getEquipmentsForGeneric:generic.generic_id.intValue sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kEquipmentsForGenericChanged object:generic.generic_id];
    } failure:^(NSString *msg) {
        NSLog(@"equipments for generic failed : %@", msg);
        [[NSNotificationCenter defaultCenter] postNotificationName:kEquipmentsForGenericChanged object:generic.generic_id];
    }];
}

- (void)getLocationsForGeneric:(Generic *)generic
{
    // request locations for generic
    [[ServerManager sharedManager] getLocationsForGeneric:generic.generic_id.intValue sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationsForGenericChanged object:generic.generic_id];
    } failure:^(NSString *msg) {
        NSLog(@"locations for generic failed : %@", msg);
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationsForGenericChanged object:generic.generic_id];
    }];
}

- (void)getMovementsForEquipment:(Equipment *)equipment
{
    // request movements for equipment
    [[ServerManager sharedManager] getMovementsForEquipment:equipment sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kMovementsForEquipmentChanged object:equipment.equipment_id];
    } failure:^(NSString *msg) {
        NSLog(@"movements for equipment failed : %@", msg);
        [[NSNotificationCenter defaultCenter] postNotificationName:kMovementsForEquipmentChanged object:equipment.equipment_id];
    }];
}

- (void)refreshWholeEquipments
{
    [[ServerManager sharedManager] getGenerics:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
        NSArray *arrayGenerics = [[ModelManager sharedManager] retrieveGenerics];
        for (Generic *generic in arrayGenerics) {
            
            // request equipments for generic
            [[ServerManager sharedManager] getEquipmentsForGeneric:generic.generic_id.intValue sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^{
                
            } failure:^(NSString *msg) {
                NSLog(@"equipments for generic failed : %@", msg);
                
            }];
            
            // request locations for generic
            [[ServerManager sharedManager] getLocationsForGeneric:generic.generic_id.intValue sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^{
                
            } failure:^(NSString *msg) {
                NSLog(@"locations for generic failed : %@", msg);
                
            }];
        }
    } failure: ^(NSString *msg) {
        NSLog(@"Data request failed : %@", msg);
    }];
}

@end
