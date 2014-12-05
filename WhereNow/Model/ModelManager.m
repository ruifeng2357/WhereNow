//
//  ModelManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 06/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ModelManager.h"
#import "AppContext.h"
#import "Config.h"
#import "Common.h"

static ModelManager *_sharedModelManager = nil;

@implementation ModelManager

+ (ModelManager *)sharedManager
{
    if (_sharedModelManager == nil)
    {
        _sharedModelManager = [[ModelManager alloc] init];
        [_sharedModelManager initModelManager];
    }
    return _sharedModelManager;
}


- (void)initModelManager
{
    _managedObjectContext = [self appContext];
}


#pragma mark - Core Data stack
- (NSManagedObjectContext *)appContext {
    if (self.managedObjectContext != nil) {
        return self.managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self appStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init]; [_managedObjectContext setUndoManager:nil];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)appModel
{
    if (self.managedObjectModel != nil){
        return self.managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.managedObjectModel;
}

- (NSPersistentStoreCoordinator *)appStoreCoordinator
{
    if (self.persistentStoreCoordinator != nil) {
        return self.persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[AppContext applicationDocumentsDirectory] URLByAppendingPathComponent:SQLITE_DB_NAME];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self appModel]];
    
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:nil
                                                               error:&error])
    {
        abort();
    }
    
    return self.persistentStoreCoordinator;
}


- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext =self.managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
        {
            abort();
        }
    }
}

#pragma mark - Load data

- (NSSortDescriptor *)sortForGenerics
{
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"generic_id" ascending:YES];
    return descriptor1;
}

- (NSArray *)sortForEquipments
{
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"current_location_parent_name" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"current_location" ascending:YES];
    return [[NSArray alloc] initWithObjects:descriptor1, descriptor2, nil];
}

- (NSSortDescriptor *)sortForLocations
{
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"ble_location_id" ascending:YES];
    return descriptor1;
}

- (NSSortDescriptor *)sortForEquipMovements
{
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"check_in_date" ascending:NO];
    return descriptor1;
}

- (NSSortDescriptor *)sortForAlerts
{
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"alert_id" ascending:YES];
    return descriptor1;
}

- (NSSortDescriptor *)sortForRecentItems
{
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"recenttime" ascending:NO];
    return descriptor1;
}


- (NSMutableArray *)retrieveFavoritesGenerics
{
    // generic array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Generic"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForGenerics];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    // favorites flag
    NSPredicate* predFavorite = [NSPredicate predicateWithFormat:
                                 @"isfavorites == %@", @(YES)];
    
    [fetchRequest setPredicate:predFavorite];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Generic *generic = (Generic *)[fetchedObjects objectAtIndex:i];
            [result addObject:generic];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveFavoritesEquipments
{
    // equipment array -------------------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
              entityForName:@"Equipment"
              inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSArray *sortDescriptors = [self sortForEquipments];
    
    // favorites flag
    NSPredicate *predFavorite = [NSPredicate predicateWithFormat:@"isfavorites == %@", @(YES)];
    
    [fetchRequest setPredicate:predFavorite];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    

    NSError *error = nil;

    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedObjects objectAtIndex:i];
            [result addObject:equipment];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveGenerics
{
    // generic array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Generic"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForGenerics];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Generic *generic = (Generic *)[fetchedObjects objectAtIndex:i];
            [result addObject:generic];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveEquipmentsWithHasBeacon:(BOOL)withBeacon
{
    // equipment array -------------------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    // sort
    NSArray *sortDescriptors = [self sortForEquipments];
    
    [fetchRequest setEntity:entity];
    if (withBeacon)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"has_beacon == %@", @(YES)];
        [fetchRequest setPredicate:predicate];
    }
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedObjects objectAtIndex:i];
            [result addObject:equipment];
        }
    }
    
    return result;
}


- (NSMutableArray *)locationsForGeneric:(Generic *)generic
{
    
    NSMutableArray *arrayResult = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"GenericLocation"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForLocations];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    // generic_id == generic.generic_id
    NSPredicate* predGeneric = [NSPredicate predicateWithFormat:
                                @"generic_id == %@", generic.generic_id];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predGeneric];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedLocations = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedLocations.count > 0)
    {
        for (int i = 0; i < [fetchedLocations count]; i++) {
            GenericLocation *location = (GenericLocation *)[fetchedLocations objectAtIndex:i];
            [arrayResult addObject:location];
        }
    }
    
    return arrayResult;
}

- (NSMutableArray *)equipmentsForGeneric:(Generic *)generic withBeacon:(BOOL)withBeacon
{
    NSMutableArray *arrayResult = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSArray *sortDescriptors = [self sortForEquipments];
    
    // generic_id == generic.generic_id
    NSPredicate* predGeneric = nil;
    if (withBeacon)
        predGeneric = [NSPredicate predicateWithFormat:
                                @"generic_id == %@ AND has_beacon == %@", generic.generic_id, @(YES)];
    else
        predGeneric = [NSPredicate predicateWithFormat:
                       @"generic_id == %@", generic.generic_id];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predGeneric];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedEquipments = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedEquipments.count > 0)
    {
        for (int i = 0; i < [fetchedEquipments count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedEquipments objectAtIndex:i];
            [arrayResult addObject:equipment];
        }
    }
    
    return arrayResult;
}

- (NSMutableArray *)retrieveGenericsWithKeyword:(NSString *)keyword
{
    // generic array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Generic"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForGenerics];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    // generic_name contains
    NSPredicate* predGeneric = [NSPredicate predicateWithFormat:
                                @"generic_name CONTAINS[cd] %@", keyword];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predGeneric];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Generic *generic = (Generic *)[fetchedObjects objectAtIndex:i];
            [result addObject:generic];
        }
    }
    
    return result;
}

- (NSMutableArray *)searchGenericsWithArray:(NSArray *)genericArray withKeyworkd:(NSString *)keyword
{
#if 0
    NSPredicate *predicate = [[NSPredicate alloc] init];
    // generic_name contains
    NSPredicate* predGeneric = [NSPredicate predicateWithFormat:
                                @"generic_name CONTAINS[cd] %@", keyword];
    return [[NSMutableArray alloc] initWithArray:[genericArray filteredArrayUsingPredicate:predicate]];
#else
    
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    
    // search with name
    for (Generic *generic in genericArray)
	{
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange nameRange = NSMakeRange(0, generic.generic_name.length);
        NSRange foundRange = [generic.generic_name rangeOfString:keyword options:searchOptions range:nameRange];
        if (foundRange.length > 0)
        {
            [searchResults addObject:generic];
        }
	}
    
    return searchResults;
#endif
}

- (NSMutableArray *)retrieveEquipmentsWithKeyword:(NSString *)keyword
{
    // equipment array -------------------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSArray *sortDescriptors = [self sortForEquipments];
    
    // manufacturer_name, model_name_no contains
    NSPredicate* predEquipment = [NSPredicate predicateWithFormat:
                                @"(manufacturer_name CONTAINS[cd] %@) || (model_name_no CONTAINS[cd] %@)", keyword, keyword];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predEquipment];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedObjects objectAtIndex:i];
            [result addObject:equipment];
        }
    }
    
    return result;
}


- (NSMutableArray *)searchEquipmentsWithArray:(NSArray *)equipmentArray withKeyword:(NSString *)keyword
{
#if 0
    
    // manufacturer_name, model_name_no contains
    NSPredicate* predEquipment = [NSPredicate predicateWithFormat:
                                  @"(manufacturer_name CONTAINS[cd] %@) || (model_name_no CONTAINS[cd] %@)", keyword, keyword];
    
    return [[NSMutableArray alloc] initWithArray:[equipmentArray filteredArrayUsingPredicate:predEquipment]];
    
#else

    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    for (Equipment *equipment in equipmentArray)
    {
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange nameRange = NSMakeRange(0, equipment.manufacturer_name.length);
        NSRange foundRange = [equipment.manufacturer_name rangeOfString:keyword options:searchOptions range:nameRange];
        if (foundRange.length > 0)
        {
            [searchResults addObject:equipment];
        }
        else
        {
            NSRange modelRange = NSMakeRange(0, equipment.model_name_no.length);
            foundRange = [equipment.model_name_no rangeOfString:keyword options:searchOptions range:modelRange];
            if (foundRange.length > 0)
            {
                [searchResults addObject:equipment];
            }
        }
    }
    
    return searchResults;
#endif
}

- (NSMutableArray *)searchEquipmentsWithGenerics:(Generic *)generic withKeyword:(NSString *)keyword
{
    NSMutableArray *arrayResult = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSArray *sortDescriptors = [self sortForEquipments];
    
    // manufacturer_name, model_name_no contains
    NSPredicate* predEquipment = [NSPredicate predicateWithFormat:
                                  @"generic_id == %@ AND ((manufacturer_name CONTAINS[cd] %@) || (model_name_no CONTAINS[cd] %@))", generic.generic_id, keyword, keyword];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predEquipment];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedEquipments = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedEquipments.count > 0)
    {
        for (int i = 0; i < [fetchedEquipments count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedEquipments objectAtIndex:i];
            [arrayResult addObject:equipment];
        }
    }
    
    return arrayResult;
}

- (NSMutableArray *)equipmovementsForEquipment:(Equipment *)equipment
{
    NSMutableArray *arrayResult = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"EquipMovement"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForEquipMovements];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    // equipment_id
    NSPredicate* predEquipMovement = [NSPredicate predicateWithFormat:
                                  @"equipment_id == %@", equipment.equipment_id];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predEquipMovement];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedEquipments = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedEquipments.count > 0)
    {
        for (int i = 0; i < [fetchedEquipments count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedEquipments objectAtIndex:i];
            [arrayResult addObject:equipment];
        }
    }
    
    return arrayResult;
}

- (NSMutableArray *)retrieveAlertsForEquipment:(Equipment *)equipment
{
    // alert array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Alert"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // equipment_id
    NSPredicate* predEquipMovement = [NSPredicate predicateWithFormat:
                                      @"equipment_id == %@", equipment.equipment_id];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForAlerts];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predEquipMovement];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Alert *alert = (Alert *)[fetchedObjects objectAtIndex:i];
            [result addObject:alert];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveMovementCountForEquipment:(Equipment *)equipment
{
    // alert array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MovementCount"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // equipment_id
    NSPredicate* predEquipMovement = [NSPredicate predicateWithFormat:
                                      @"equipment_id == %@", equipment.equipment_id];
    
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predEquipMovement];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            MovementCount *movementcount = (MovementCount *)[fetchedObjects objectAtIndex:i];
            [result addObject:movementcount];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveRecentGenerics
{
    // generic array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Generic"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForRecentItems];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    // isrecent
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                      @"isrecent == %@", @(YES)];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Generic *generic = (Generic *)[fetchedObjects objectAtIndex:i];
            [result addObject:generic];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveRecentEquipments
{
    // generic array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForRecentItems];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    // isrecent
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
                              @"has_beacon == %@ AND isrecent == %@", @(YES), @(YES)];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Equipment *generic = (Equipment *)[fetchedObjects objectAtIndex:i];
            [result addObject:generic];
        }
    }
    
    return result;
}

- (void)addRecentGeneric:(Generic *)generic
{
    NSMutableArray *arrayGenerics = [self retrieveRecentGenerics];
    if ([arrayGenerics containsObject:generic])
    {
        generic.recenttime = [NSDate date];
        [self saveContext];
    }
    else
    {
        generic.isrecent = @(YES);
        generic.recenttime = [NSDate date];
        if (arrayGenerics.count >= 50)
        {
            Generic *oldOne = [arrayGenerics lastObject];
            oldOne.isrecent = @(NO);
        }
        [self saveContext];
    }
}

- (void)addRecentEquipment:(Equipment *)equipment
{
    NSMutableArray *arrayEquipments = [self retrieveRecentEquipments];
    if ([arrayEquipments containsObject:equipment])
    {
        equipment.recenttime = [NSDate date];
        [self saveContext];
    }
    else
    {
        equipment.isrecent = @(YES);
        equipment.recenttime = [NSDate date];
        if (arrayEquipments.count >= 50)
        {
            Equipment *oldOne = [arrayEquipments lastObject];
            oldOne.isrecent = @(NO);
        }
        [self saveContext];
    }
}

- (Alert *)alertById:(int)alertId
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Alert"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // alert_id
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                      @"alert_id == %@", @(alertId)];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count <= 0)
        return nil;
    
    return [fetchedObjects objectAtIndex:0];
}

- (Equipment *)equipmentById:(int)equipmentId
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // equipment_id
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
                              @"equipment_id == %@", @(equipmentId)];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count <= 0)
        return nil;
    
    return [fetchedObjects objectAtIndex:0];
}

- (void)addTriggeredAlert:(int)alert_id
{
    TriggeredAlert *triggeredAlert = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"TriggeredAlert"
                                   inManagedObjectContext:_managedObjectContext];
    triggeredAlert.alert_id = @(alert_id);
    triggeredAlert.opened = @(NO);
    triggeredAlert.opened_date = @"";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTriggeredAlertChanged object:nil];
}

- (NSMutableArray *)retrieveTriggeredAlerts
{
    // alert array -----------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TriggeredAlert"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // opened
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                      @"opened == %@", @(NO)];
    
    // sort
    NSSortDescriptor *descriptor1 = [self sortForAlerts];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            TriggeredAlert *alert = (TriggeredAlert *)[fetchedObjects objectAtIndex:i];
            [result addObject:alert];
        }
    }
    
    return result;
}

- (NSMutableArray *)retrieveLocatingEquipments
{
    // equipment array -------------------
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Equipment"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // sort
    NSArray *sortDescriptors = [self sortForEquipments];
    
    // favorites flag
    NSPredicate *predFavorite = [NSPredicate predicateWithFormat:@"islocating == %@", @(YES)];
    
    [fetchRequest setPredicate:predFavorite];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Equipment *equipment = (Equipment *)[fetchedObjects objectAtIndex:i];
            [result addObject:equipment];
        }
    }
    
    return result;
}


+ (NSString *)getEquipmentName:(Equipment *)equipment
{
    NSString *strName = [NSString stringWithFormat:@"%@ (%@)", equipment.model_name_no, equipment.manufacturer_name];
    return strName;
}

@end
