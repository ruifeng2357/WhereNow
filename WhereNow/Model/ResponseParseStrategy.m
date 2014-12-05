//
//  ResponseParseStrategy.m
//  WhereNow
//
//  Created by Xiaoxue Han on 07/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ResponseParseStrategy.h"
#import "ServerManager.h"
#import "ModelManager.h"

#define GET_SAFE_INT(dest, dic, key, default)     \
    int dest; \
    if ([dic objectForKey:key] == nil || [[dic objectForKey:key] isEqual:[NSNull null]]) \
        dest = default; \
    else \
        dest = [[dic objectForKey:key] intValue];

#define GET_SAFE_STRING(dest, dic, key, default)    \
    NSString *dest; \
    if ([dic objectForKey:key] == nil || [[dic objectForKey:key] isEqual:[NSNull null]]) \
        dest = default; \
    else    \
        dest = [dic objectForKey:key];

static ResponseParseStrategy *_sharedParseStrategy = nil;

@implementation ResponseParseStrategy

+ (ResponseParseStrategy *)sharedParseStrategy
{
    if (_sharedParseStrategy == nil)
        _sharedParseStrategy = [[ResponseParseStrategy alloc] init];
    return _sharedParseStrategy;
}

- (BOOL)parseMovements:(NSArray *)arrayMovements withEquipment:(Equipment *)equipment
{
    @autoreleasepool {
        NSArray *arrayExistMovements = nil;
        
        if (equipment) {
            arrayExistMovements = [[ModelManager sharedManager] equipmovementsForEquipment:equipment];
        }
        
        /*
         ble_location_id	number
         
         location_name	string
         
         check_in_date	string
         
         equipment_id	number
         
         date	string
         
         time	string
         
         stay_time	string
         
         time_limit long seconds
         
         direction IN or OUT
         
         stay_minutes long (minutes for stay_time)
         */
        
        NSMutableArray *arrayNewMovements = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicMovement in arrayMovements) {
           
            GET_SAFE_INT(ble_location_id, dicMovement, @"ble_location_id", 0);
            GET_SAFE_STRING(location_name, dicMovement, @"location_name", @"");
            GET_SAFE_STRING(check_in_date, dicMovement, @"check_in_date", @"");
            GET_SAFE_INT(equipment_id, dicMovement, @"equipment_id", 0);
            GET_SAFE_STRING(date, dicMovement, @"date", @"");
            GET_SAFE_STRING(time, dicMovement, @"time", @"");
            GET_SAFE_STRING(stay_time, dicMovement, @"stay_time", @"");
            GET_SAFE_INT(time_limit, dicMovement, @"time_limit", 0);
            GET_SAFE_STRING(direction, dicMovement, @"direction", @"");
            GET_SAFE_INT(stay_minutes, dicMovement, @"stay_minutes", 0);
            GET_SAFE_STRING(parent_location_name, dicMovement, @"parent_location_name", @"");
            
            
            EquipMovement *existMovement = nil;
            
            if (!equipment)
            {
                existMovement = nil;
            }
            else
            {
                
                for (EquipMovement *movement in arrayExistMovements) {
                    if ([movement.ble_location_id intValue] == ble_location_id
                         && [movement.check_in_date isEqualToString:check_in_date])
                    {
                        existMovement = movement;
                        break;
                    }
                }
            }
            
            if (existMovement)
            {
                existMovement.ble_location_id = @(ble_location_id);
                existMovement.location_name = location_name;
                existMovement.check_in_date = check_in_date;
                existMovement.equipment_id = @(equipment_id);
                existMovement.date = date;
                existMovement.time = time;
                existMovement.stay_time = stay_time;
                existMovement.stay_minutes = @(stay_minutes);
                existMovement.time_limit = @(time_limit);
                existMovement.direction = direction;
                existMovement.parent_location_name = parent_location_name;
                
                
                [arrayNewMovements addObject:existMovement];
            }
            else
            {
                EquipMovement *movement = [NSEntityDescription
                                             insertNewObjectForEntityForName:@"EquipMovement"
                                             inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];

                movement.ble_location_id = @(ble_location_id);
                movement.location_name = location_name;
                movement.check_in_date = check_in_date;
                movement.equipment_id = @(equipment_id);
                movement.date = date;
                movement.time = time;
                movement.stay_time = stay_time;
                movement.stay_minutes = @(stay_minutes);
                movement.time_limit = @(time_limit);
                movement.direction = direction;
                movement.parent_location_name = parent_location_name;
                
                [arrayNewMovements addObject:movement];
            }
        }
        
        // delete objects
        if (equipment)
        {
            for (EquipMovement *existMovement in arrayExistMovements) {
                if (![arrayNewMovements containsObject:existMovement])
                {
                    [[ModelManager sharedManager].managedObjectContext deleteObject:existMovement];
                }
            }
        }
    }
    return YES;
}

- (BOOL)parseAlertsWithCurrentAlerts:(NSArray *)currentAlerts timeAlerts:(NSArray *)timeAlerts entryAlerts:(NSArray *)entryAlerts exitAlerts:(NSArray *)exitAlerts withEquipment:(Equipment *)equipment
{
    @autoreleasepool {
        NSArray *arrayExistAlerts = nil;
        if (equipment) {
            arrayExistAlerts = [[ModelManager sharedManager] retrieveAlertsForEquipment:equipment];
        }

        for (NSDictionary *dicAlert in currentAlerts) {
            /*
             
             [location_name] => Ward B
             [serial_no] => 12856010
             [equipment_id] => 1630
             [current_location_name] => Ward B
            */
            GET_SAFE_INT(alert_id, dicAlert, @"alert_id", 0);
            GET_SAFE_STRING(location_name, dicAlert, @"location_name", @"");
            GET_SAFE_STRING(serial_no, dicAlert, @"serial_no", @"");
            GET_SAFE_INT(equipment_id, dicAlert, @"equipment_id", 0);
            GET_SAFE_STRING(current_location_name, dicAlert, @"current_location_name", @"");
            GET_SAFE_STRING(location_parent_name, dicAlert, @"location_parent_name", @"");
            GET_SAFE_STRING(current_location_parent_name, dicAlert, @"current_location_parent_name", @"");
            
            Alert *alert = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Alert"
                            inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
            
            alert.alert_id = @(alert_id);
            alert.alert_type = @"Current Alerts";
            alert.location_name = location_name;
            alert.serial_no = serial_no;
            alert.equipment_id = @(equipment_id);
            alert.current_location_name = current_location_name;
            alert.current_location_parent_name = current_location_parent_name;
            alert.location_parent_name = location_parent_name;

        }
        
        for (NSDictionary *dicAlert in timeAlerts) {
            /*
             [user_count] => 1
             [trigger_datetime] => 2014-08-22 23:14:54
             [current_location_id] => 16
             [location_name] => Ward B
             [trigger_string] => 1 day
             */
            
            GET_SAFE_INT(alert_id, dicAlert, @"alert_id", 0);
            GET_SAFE_INT(user_count, dicAlert, @"user_count", 0);
            GET_SAFE_STRING(str_trigger_datetime, dicAlert, @"trigger_datetime", @"");
            GET_SAFE_INT(current_location_id, dicAlert, @"current_location_id", 0);
            GET_SAFE_STRING(location_name, dicAlert, @"location_name", @"");
            GET_SAFE_STRING(trigger_string, dicAlert, @"trigger_string", @"");
            GET_SAFE_STRING(location_parent_name, dicAlert, @"location_parent_name", @"");
            
            
            Alert *alert = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Alert"
                            inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
            
            alert.alert_id = @(alert_id);
            alert.alert_type = @"Time Alerts";
            alert.user_count = @(user_count);
            alert.trigger_datetime = [Common str2date:str_trigger_datetime withFormat:DATETIME_FORMAT];
            alert.current_location_id = @(current_location_id);
            alert.location_name = location_name;
            alert.trigger_string = trigger_string;
            alert.location_parent_name = location_parent_name;
            
            alert.equipment_id = equipment.equipment_id;
        }
        
        for (NSDictionary *dicAlert in entryAlerts) {
            /*
             
             [user_count] => 1
             [trigger_datetime] => 2014-08-22 23:14:54
             [current_location_id] => 16
             [location_name] => Ward B
             [direction] => IN
             */
            
            GET_SAFE_INT(alert_id, dicAlert, @"alert_id", 0);
            GET_SAFE_INT(user_count, dicAlert, @"user_count", 0);
            GET_SAFE_STRING(str_trigger_datetime, dicAlert, @"trigger_datetime", @"");
            GET_SAFE_INT(current_location_id, dicAlert, @"current_location_id", 0);
            GET_SAFE_STRING(location_name, dicAlert, @"location_name", @"");
            GET_SAFE_STRING(direction, dicAlert, @"direction", @"");
            GET_SAFE_STRING(location_parent_name, dicAlert, @"location_parent_name", @"");
            
            Alert *alert = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Alert"
                            inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
            
            alert.alert_id = @(alert_id);
            alert.alert_type = @"Entry Alerts";
            alert.user_count = @(user_count);
            alert.trigger_datetime = [Common str2date:str_trigger_datetime withFormat:DATETIME_FORMAT];
            alert.current_location_id = @(current_location_id);
            alert.location_name = location_name;
            alert.direction = direction;
            alert.location_parent_name = location_parent_name;
            
            alert.equipment_id = equipment.equipment_id;
        }
        
        for (NSDictionary *dicAlert in exitAlerts) {
            /*
             
             [user_count] => 1
             [trigger_datetime] => 2014-08-22 23:14:54
             [current_location_id] => 16
             [location_name] => Ward B
             [direction] => IN
             */
            GET_SAFE_INT(alert_id, dicAlert, @"alert_id", 0);
            GET_SAFE_INT(user_count, dicAlert, @"user_count", 0);
            GET_SAFE_STRING(str_trigger_datetime, dicAlert, @"trigger_datetime", @"");
            GET_SAFE_INT(current_location_id, dicAlert, @"current_location_id", 0);
            GET_SAFE_STRING(location_name, dicAlert, @"location_name", @"");
            GET_SAFE_STRING(direction, dicAlert, @"direction", @"");
            GET_SAFE_STRING(location_parent_name, dicAlert, @"location_parent_name", @"");
            
            Alert *alert = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Alert"
                            inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
            
            alert.alert_id = @(alert_id);
            alert.alert_type = @"Exit Alerts";
            alert.user_count = @(user_count);
            alert.trigger_datetime = [Common str2date:str_trigger_datetime withFormat:DATETIME_FORMAT];
            alert.current_location_id = @(current_location_id);
            alert.location_name = location_name;
            alert.direction = direction;
            alert.location_parent_name = location_parent_name;
            
            alert.equipment_id = equipment.equipment_id;
        }
        
        // delete objects
        for (Alert *existAlert in arrayExistAlerts) {
            [[ModelManager sharedManager].managedObjectContext deleteObject:existAlert];
        }
  
    }
    
    return YES;
}

- (BOOL)parseMovementCount:(NSArray *)arrayMovementCount withEquipment:(Equipment *)equipment
{
    @autoreleasepool {
        
        NSArray *arrayExistMovementCount = nil;
        if (equipment) {
            arrayExistMovementCount = [[ModelManager sharedManager] retrieveMovementCountForEquipment:equipment];
        }
        
        for (NSDictionary *dicMovementCount in arrayMovementCount) {
            /*
             [Mon] => 75
             [Tue] => 69
             [Wed] => 6
             [Thu] => 0
             [Fri] => 36
             [Sat] => 54
             [Sun] => 0
             */
            GET_SAFE_INT(mon, dicMovementCount, @"Mon", 0);
            GET_SAFE_INT(tue, dicMovementCount, @"Tue", 0);
            GET_SAFE_INT(wed, dicMovementCount, @"Wed", 0);
            GET_SAFE_INT(thu, dicMovementCount, @"Thu", 0);
            GET_SAFE_INT(fri, dicMovementCount, @"Fri", 0);
            GET_SAFE_INT(sat, dicMovementCount, @"Sat", 0);
            GET_SAFE_INT(sun, dicMovementCount, @"Sun", 0);
            
            MovementCount *movementcount = [NSEntityDescription
                            insertNewObjectForEntityForName:@"MovementCount"
                            inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
            
            movementcount.equipment_id = equipment.equipment_id;
            movementcount.mon = @(mon);
            movementcount.tue = @(tue);
            movementcount.wed = @(wed);
            movementcount.thu = @(thu);
            movementcount.fri = @(fri);
            movementcount.sat = @(sat);
            movementcount.sun = @(sun);
        }

        // delete objects
        for (MovementCount *existMovementCount in arrayExistMovementCount) {
            [[ModelManager sharedManager].managedObjectContext deleteObject:existMovementCount];
        }
        
    }
    
    return YES;
}

- (BOOL)parseLocations:(NSArray *)arrayLocations withGeneric:(Generic *)generic
{
    @autoreleasepool {
        NSArray *arrayExistLocations = nil;
        if (generic) {
            arrayExistLocations = [[ModelManager sharedManager] locationsForGeneric:generic];
        }
        
        /*
         generic_id	number
         
         generic_name	string
         
         ble_location_id	number
         
         location_name	string
         
         location_wise_equipment_count	number
         
         optimal_level	number
         
         warning_level	number
         
         minimum_level	number
         
         [location_hierarchy] => Array
             (
                 [0] => Array
                 (
                     [ble_location_id] => 16
                     [company_id] => 1132
                     [location_parent_id] => 2
                     [location_name] => Ward B
                 )
                 [1] => Array
                 (
                     [ble_location_id] => 2
                     [company_id] => 1132
                     [location_parent_id] => 1
                     [location_name] => Level 1
                 )
                 [2] => Array
                 (
                     [ble_location_id] => 1
                     [company_id] => 1132
                     [location_parent_id] => 0
                     [location_name] => Main Building
                 )
            )

         */
        
        NSMutableArray *arrayNewLocations = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicLocation in arrayLocations) {
            GET_SAFE_INT(generic_id, dicLocation, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicLocation, @"generic_name", @"");
            GET_SAFE_INT(ble_location_id, dicLocation, @"ble_location_id", 0);
            GET_SAFE_STRING(location_name, dicLocation, @"location_name", @"");
            GET_SAFE_INT(location_wise_equipment_count, dicLocation, @"location_wise_equipment_count", 0);
            GET_SAFE_INT(optimal_level, dicLocation, @"optimal_level", 0);
            GET_SAFE_INT(warning_level, dicLocation, @"warning_level", 0);
            GET_SAFE_INT(minimum_level, dicLocation, @"minimum_level", 0);
            GET_SAFE_STRING(uuid, dicLocation, @"UUID", @"");
            GET_SAFE_INT(major, dicLocation, @"Major", 0);
            GET_SAFE_INT(minor, dicLocation, @"Minor", 0);
            GET_SAFE_STRING(status_message, dicLocation, @"status_message", @"");
            GET_SAFE_INT(ble_parent_location_id, dicLocation, @"ble_parent_location_id", 0);
            GET_SAFE_STRING(parent_location_name, dicLocation, @"parent_location_name", @"");

            
            NSMutableArray *arrayHierarchy = [dicLocation objectForKey:@"location_hierarchy"];
            
            
            
            GenericLocation *existLocation = nil;
            
            if (!generic)
            {
                existLocation = nil;
            }
            else
            {
                
                for (GenericLocation *location in arrayExistLocations) {
                    if ([location.ble_location_id intValue] == ble_location_id)
                    {
                        existLocation = location;
                        break;
                    }
                }
            }
            
            if (existLocation)
            {
                existLocation.generic_id = [NSNumber numberWithInt:generic_id];
                existLocation.generic_name = generic_name;
                existLocation.ble_location_id = [NSNumber numberWithInt:ble_location_id];
                existLocation.location_name = location_name;
                existLocation.location_wise_equipment_count = [NSNumber numberWithInt:location_wise_equipment_count];
                existLocation.optimal_level = [NSNumber numberWithInt:optimal_level];
                existLocation.warning_level = [NSNumber numberWithInt:warning_level];
                existLocation.minimum_level = [NSNumber numberWithInt:minimum_level];
                existLocation.status_message = status_message;
                existLocation.uuid = uuid;
                existLocation.major = @(major);
                existLocation.minor = @(minor);
                existLocation.ble_parent_location_id = @(ble_parent_location_id);
                existLocation.parent_location_name = parent_location_name;
                
                [arrayNewLocations addObject:existLocation];
                
                // parse arrayHierarchy
            }
            else
            {
                GenericLocation *location = [NSEntityDescription
                                             insertNewObjectForEntityForName:@"GenericLocation"
                                             inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                location.generic_id = [NSNumber numberWithInt:generic_id];
                location.generic_name = generic_name;
                location.ble_location_id = [NSNumber numberWithInt:ble_location_id];
                location.location_name = location_name;
                location.location_wise_equipment_count = [NSNumber numberWithInt:location_wise_equipment_count];
                location.optimal_level = [NSNumber numberWithInt:optimal_level];
                location.warning_level = [NSNumber numberWithInt:warning_level];
                location.minimum_level = [NSNumber numberWithInt:minimum_level];
                location.status_message = status_message;
                location.uuid = uuid;
                location.major = @(major);
                location.minor = @(minor);
                location.ble_parent_location_id = @(ble_parent_location_id);
                location.parent_location_name = parent_location_name;
                
                [arrayNewLocations addObject:location];
                
                // parse arrayHierarchy
            }
            
            // arrayHierarchy
            if (arrayHierarchy)
            {
                //for (NSDictionary *dicHierarchy in arrayHierarchy) {
                    /*
                    int h_ble_location_id = [[dicHierarchy objectForKey:@"ble_location_id"] intValue];
                    int h_company_id = [[dicHierarchy objectForKey:@"company_id"] intValue];
                    int h_location_parent_id = [[dicHierarchy objectForKey:@"location_parent_id"] intValue];
                    NSString *h_location_name = [dicHierarchy objectForKey:@"location_name"];
                     */
                //}
            }
        }
        
        // delete objects
        if (generic)
        {
            for (GenericLocation *existLocation in arrayExistLocations) {
                if (![arrayNewLocations containsObject:existLocation])
                {
                    [[ModelManager sharedManager].managedObjectContext deleteObject:existLocation];
                }
            }
        }
    }
    return YES;
}


- (BOOL)parseEquipments:(NSArray *)arrayEquipments withGeneric:(Generic *)generic
{
    @autoreleasepool {
        NSArray *arrayExistEquipments = nil;
        if (generic) {
            arrayExistEquipments = [[ModelManager sharedManager] equipmentsForGeneric:generic withBeacon:YES];
        }
        
        /*
         generic_id	number
         
         generic_name	string
         
         equipment_id	number
         
         serial_no	string
         
         barcode_no	string
         
         currernt_location_id	number
         
         current_location	string
         
         manufacturer_name	string
         
         model_name_no	string
         
         home_location_id	number
         
         
         home_location	string
         
         model_id
         

         movement_array	array
         
         movement_count array
         
         equipment_file_location
         
         model_file_location
         
         UUID
         
         Major
         
         Minor
         
         current_location_parent_name   
         current_location_parent_id
         
         manufacturer_file_location
         manufacturer_path_key

         */
        
        NSMutableArray *arrayNewEquipments = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicEquipment in arrayEquipments) {
            GET_SAFE_INT(generic_id, dicEquipment, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicEquipment, @"generic_name", @"");
            GET_SAFE_INT(equipment_id, dicEquipment, @"equipment_id", 0);
            GET_SAFE_STRING(serial_no, dicEquipment, @"serial_no", @"");
            GET_SAFE_STRING(barcode_no, dicEquipment, @"barcode_no", @"");
            GET_SAFE_INT(current_location_id, dicEquipment, @"current_location_id", 0);
            GET_SAFE_STRING(current_location, dicEquipment, @"current_location", @"");
            GET_SAFE_STRING(manufacturer_name, dicEquipment, @"manufacturer_name", @"");
            GET_SAFE_STRING(model_name_no, dicEquipment, @"model_name_no", @"");
            GET_SAFE_INT(home_location_id, dicEquipment, @"home_location_id", 0);
            GET_SAFE_STRING(home_location, dicEquipment, @"home_location", @"");
            
            if (equipment_id == 12838)
                equipment_id = equipment_id;

            
            NSArray *movement_array = [dicEquipment objectForKey:@"movement_array"];
            
            // movement count
            NSArray *movement_count = [dicEquipment objectForKey:@"movement_count"];
            
            // alerts
            NSArray *current_alert = [dicEquipment objectForKey:@"current_alert"];
            
            NSArray *time_alert = [dicEquipment objectForKey:@"time_alert"];
            
            NSArray *entry_alert = [dicEquipment objectForKey:@"entry_alert"];
            
            NSArray *exit_alert = [dicEquipment objectForKey:@"exit_alert"];
            
            
            BOOL isfavorites = NO;
            
            GET_SAFE_STRING(model_id, dicEquipment, @"model_id", @"");
            GET_SAFE_STRING(equipment_file_location, dicEquipment, @"equipment_file_location", @"");
            GET_SAFE_STRING(model_file_location, dicEquipment, @"model_file_location", @"");
            
            NSString *equipment_file_location_local = @"";
            NSString *model_file_location_local = @"";
            NSString *manufacturer_file_location_local = @"";
            
            GET_SAFE_STRING(uuid, dicEquipment, @"UUID", @"");
            GET_SAFE_INT(major, dicEquipment, @"Major", 0);
            GET_SAFE_INT(minor, dicEquipment, @"Minor", 0);
            
            GET_SAFE_STRING(current_location_parent_name, dicEquipment, @"current_location_parent_name", @"");
            GET_SAFE_INT(current_location_parent_id, dicEquipment, @"current_location_parent_id", 0);
            
            GET_SAFE_STRING(equipment_alert_icon, dicEquipment, @"equipment_alert_icon", @"");
            GET_SAFE_INT(equipment_alert_icon_id, dicEquipment, @"equipment_alert_icon_id", 0);
            
            GET_SAFE_STRING(manufacturer_file_location, dicEquipment, @"manufacturer_file_location", @"");
            GET_SAFE_STRING(manufacturer_path_key, dicEquipment, @"manufacturer_path_key", @"");
            
            GET_SAFE_STRING(home_location_parent_id, dicEquipment, @"home_location_parent_id", @"");
            GET_SAFE_STRING(home_location_parent_name, dicEquipment, @"home_location_parent_name", @"");
            
            GET_SAFE_INT(sticknfind_id, dicEquipment, @"sticknfind_id", 0);
            
            
            Equipment *existEquipment = nil;
            
            if (!generic)
            {
                existEquipment = nil;
            }
            else
            {
                for (Equipment *equipment in arrayExistEquipments) {
                    if ([equipment.equipment_id intValue] == equipment_id)
                    {
                        existEquipment = equipment;
                        break;
                    }
                }
            }
            
            if (existEquipment)
            {
                existEquipment.generic_id = [NSNumber numberWithInt:generic_id];
                existEquipment.generic_name = generic_name;
                existEquipment.equipment_id = [NSNumber numberWithInt:equipment_id];
                existEquipment.serial_no = serial_no;
                existEquipment.barcode_no = barcode_no;
                existEquipment.current_location_id = [NSNumber numberWithInt:current_location_id];
                existEquipment.current_location = current_location;
                existEquipment.manufacturer_name = manufacturer_name;
                existEquipment.model_name_no = model_name_no;
                existEquipment.home_location_id = [NSNumber numberWithInt:home_location_id];
                existEquipment.home_location = home_location;
                existEquipment.has_beacon = @(YES);
                
                existEquipment.model_id = model_id;
                
                if (![existEquipment.equipment_file_location isEqualToString:equipment_file_location])
                {
                    // resave file to local
                    existEquipment.equipment_file_location = equipment_file_location;
                    existEquipment.equipment_file_location_local = @"";
                }
                
                if (![existEquipment.model_file_location isEqualToString:model_file_location])
                {
                    // resave file to local
                    existEquipment.model_file_location = model_file_location;
                    existEquipment.model_file_location_local = @"";
                }
                
                existEquipment.uuid = uuid;
                existEquipment.major = @(major);
                existEquipment.minor = @(minor);
                
                existEquipment.current_location_parent_name = current_location_parent_name;
                existEquipment.current_location_parent_id = @(current_location_parent_id);
                
                existEquipment.equipment_alert_icon = equipment_alert_icon;
                existEquipment.equipment_alert_icon_id = @(equipment_alert_icon_id);
                
                existEquipment.manufacturer_file_location = manufacturer_file_location;
                existEquipment.manufacturer_path_key = manufacturer_path_key;
                if (![existEquipment.manufacturer_file_location isEqualToString:manufacturer_file_location])
                {
                    existEquipment.manufacturer_file_location = manufacturer_file_location;
                    existEquipment.manufacturer_file_location_local = manufacturer_file_location_local;
                }
                
                existEquipment.home_location_parent_id = home_location_parent_id;
                existEquipment.home_location_parent_name = home_location_parent_name;
                
                existEquipment.sticknfind_id = @(sticknfind_id);

                
                [arrayNewEquipments addObject:existEquipment];
#if 0
                if (movement_array)
                    [self parseMovements:movement_array withEquipment:existEquipment];
#endif
                
                [self parseAlertsWithCurrentAlerts:current_alert timeAlerts:time_alert entryAlerts:entry_alert exitAlerts:exit_alert withEquipment:existEquipment];
                
#if 0
                if (movement_count)
                    [self parseMovementCount:movement_count withEquipment:existEquipment];
#endif
            }
            else
            {
                Equipment *equipment = [NSEntityDescription
                                             insertNewObjectForEntityForName:@"Equipment"
                                             inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                equipment.generic_id = [NSNumber numberWithInt:generic_id];
                equipment.generic_name = generic_name;
                equipment.equipment_id = [NSNumber numberWithInt:equipment_id];
                equipment.serial_no = serial_no;
                equipment.barcode_no = barcode_no;
                equipment.current_location_id = [NSNumber numberWithInt:current_location_id];
                equipment.current_location = current_location;
                equipment.manufacturer_name = manufacturer_name;
                equipment.model_name_no = model_name_no;
                equipment.home_location_id = [NSNumber numberWithInt:home_location_id];
                equipment.home_location = home_location;
                equipment.has_beacon = @(YES);
                
                equipment.isfavorites = @(isfavorites);
                
                equipment.model_id = model_id;
                
                equipment.equipment_file_location = equipment_file_location;
                equipment.model_file_location = model_file_location;
                
                // have to save file to local
                equipment.equipment_file_location_local = equipment_file_location_local;
                equipment.model_file_location_local = model_file_location_local;
                
                equipment.isrecent = @(NO);
                equipment.recenttime = [NSDate date];
                
                equipment.uuid = uuid;
                equipment.major = @(major);
                equipment.minor = @(minor);
                
                equipment.current_location_parent_name = current_location_parent_name;
                equipment.current_location_parent_id = @(current_location_parent_id);
                
                equipment.equipment_alert_icon = equipment_alert_icon;
                equipment.equipment_alert_icon_id = @(equipment_alert_icon_id);
                
                equipment.manufacturer_file_location = manufacturer_file_location;
                equipment.manufacturer_path_key = manufacturer_path_key;
                equipment.manufacturer_file_location_local = manufacturer_file_location_local;
                
                equipment.home_location_parent_id = home_location_parent_id;
                equipment.home_location_parent_name = home_location_parent_name;
                
                equipment.islocating = @(NO);
                
                equipment.sticknfind_id = @(sticknfind_id);
                
                [arrayNewEquipments addObject:equipment];
                
#if 0
                if (movement_array)
                    [self parseMovements:movement_array withEquipment:existEquipment];
                else
                    [self parseMovements:[[NSMutableArray alloc] init] withEquipment:existEquipment];
#endif
                
                [self parseAlertsWithCurrentAlerts:current_alert timeAlerts:time_alert entryAlerts:entry_alert exitAlerts:exit_alert withEquipment:equipment];
      
#if 0
                if (movement_count)
                    [self parseMovementCount:movement_count withEquipment:equipment];
#endif
            }
        }
        
        // delete objects
        if (generic)
        {
            for (Equipment *existEquipment in arrayExistEquipments) {
                if (![arrayNewEquipments containsObject:existEquipment])
                {
                    [[ModelManager sharedManager].managedObjectContext deleteObject:existEquipment];
                }
            }
        }
    }
    return YES;
}

- (BOOL)parseGenericResponse:(NSDictionary *)dicResult
{
    BOOL bRet = YES;
    
    @autoreleasepool {
        
        NSArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
        NSMutableArray *arrayNewGenerics = [[NSMutableArray alloc] init];
        
        NSArray *arrayResult = (NSArray *)dicResult;
        for (NSDictionary *dicGeneric in arrayResult) {
            
            // generic
            GET_SAFE_INT(generic_id, dicGeneric, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicGeneric, @"generic_name", @"");
            GET_SAFE_INT(genericwise_equipment_count, dicGeneric, @"genericwise_equipment_count", 0);
            GET_SAFE_INT(alert_count, dicGeneric, @"alert_count", 0);
            GET_SAFE_STRING(alert_icon, dicGeneric, @"alert_icon", @"");
            GET_SAFE_STRING(status_message, dicGeneric, @"status_message", @"");

            BOOL isfavorites = NO;
           
            Generic *newGeneric = nil;
            
            // is exist
            Generic *existGeneric = nil;
            for (Generic *generic in arrayExistGenerics) {
                if ([generic.generic_id intValue] == generic_id)
                {
                    existGeneric = generic;
                    break;
                }
            }
            
            // if is exist, update values
            if (existGeneric)
            {
                existGeneric.generic_id = [NSNumber numberWithInt:generic_id];
                existGeneric.generic_name = generic_name;
                existGeneric.genericwise_equipment_count = [NSNumber numberWithInt:genericwise_equipment_count];
                existGeneric.status_message = status_message;
                existGeneric.alert_count = @(alert_count);
                existGeneric.alert_icon = alert_icon;
                
                [arrayNewGenerics addObject:existGeneric];
            }
            else
            {
                // insert generic
                newGeneric = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Generic"
                                inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                
                newGeneric.generic_id = [NSNumber numberWithInt:generic_id];
                newGeneric.generic_name = generic_name;
                newGeneric.genericwise_equipment_count = [NSNumber numberWithInt:genericwise_equipment_count];
                newGeneric.isfavorites = @(isfavorites);
                newGeneric.status_message = status_message;
                
                
                newGeneric.alert_count = @(alert_count);
                newGeneric.alert_icon = alert_icon;
                
                newGeneric.isrecent = @(NO);
                newGeneric.recenttime = [NSDate date];
                
                [arrayNewGenerics addObject:newGeneric];
            }

#if 0
            NSArray *locationArray = (NSArray *)[dicGeneric objectForKey:@"location_array"];
            NSArray *equipmentArray = (NSArray *)[dicGeneric objectForKey:@"equipment_array"];

            // locations for generic
            if (locationArray)
                [self parseLocations:locationArray withGeneric:existGeneric];
            else
                [self parseLocations:[[NSMutableArray alloc] init] withGeneric:existGeneric];
           
            // equipments for generic
            if (equipmentArray)
                [self parseEquipments:equipmentArray withGeneric:existGeneric];
            else
                [self parseEquipments:[[NSMutableArray alloc] init] withGeneric:existGeneric];
#endif
            
        } // end for
        
        // delete objects
        for (Generic *existGeneric in arrayExistGenerics) {
            if (![arrayNewGenerics containsObject:existGeneric])
            {
                [[ModelManager sharedManager].managedObjectContext deleteObject:existGeneric];
            }
        }
    }
    
    [[ModelManager sharedManager] saveContext];
    
    return bRet;
}

- (BOOL)parseNearmeResponse:(NSDictionary *)dicResult complete:(void (^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))complete failure:(void(^)())failure
{
    NSMutableArray *arrayGenerics = [[NSMutableArray alloc] init];
    NSMutableArray *arrayVicinityEquipments = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLocationEquipments = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
    NSMutableArray *arrayExistEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
    
    NSArray *arrayResult = (NSArray *)dicResult;
    for (NSDictionary *dicGeneric in arrayResult) {
        int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
        
        Generic *generic = [self genericWithGenericId:generic_id generics:arrayExistGenerics];
        if (generic == nil)
            continue;
        
        
        NSArray *arrayLocations = [dicGeneric objectForKey:@"location_array"];
        if (arrayLocations != nil)
        {
            for (NSDictionary *dicLocation in arrayLocations) {
                int equipment_id = [[dicLocation objectForKey:@"equipment_id"] intValue];
                Equipment *equipment = [self equipmentWithEquipmentId:equipment_id equipments:arrayExistEquipments];
                if (equipment == nil)
                    continue;
                
                NSString *location_type = [dicLocation objectForKey:@"location_type"];
                if ([location_type isEqualToString:kLocationTypeImmediateVicinity])
                {
                    if (![arrayVicinityEquipments containsObject:equipment])
                        [arrayVicinityEquipments addObject:equipment];
                    
                    if (![arrayGenerics containsObject:generic])
                        [arrayGenerics addObject:generic];
                }
                else if ([location_type isEqualToString:kLocationTypeCurrentLocation])
                {
                    if (![arrayLocationEquipments containsObject:equipment])
                        [arrayLocationEquipments addObject:equipment];
                    
                    if (![arrayGenerics containsObject:generic])
                        [arrayGenerics addObject:generic];
                }
            }
        }
    }
    
    complete(arrayGenerics, arrayVicinityEquipments, arrayLocationEquipments);
    return YES;
}

- (BOOL)parseCurrentLocationEquipmentsResponse:(NSDictionary *)dicResult complete:(void (^)(NSMutableArray *))complete failure:(void (^)())failure
{
    NSMutableArray *arrayGenerics = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLocationEquipments = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
    NSMutableArray *arrayExistEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
    
    NSArray *arrayResult = (NSArray *)dicResult;
    for (NSDictionary *dicGeneric in arrayResult) {
        if (![dicGeneric isKindOfClass:[NSDictionary class]])
            return false;
        
        NSObject *obj = [dicGeneric objectForKey:@"generic_id"];
        if (obj == nil || [obj isEqual:[NSNull null]]) {
            NSLog(@"got incorrect response from server - generic id is null");
            return NO;
        }
        
        int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
        
        Generic *generic = [self genericWithGenericId:generic_id generics:arrayExistGenerics];
        if (generic == nil)
            continue;

        NSArray *arrayLocations = [dicGeneric objectForKey:@"equipment_array"];
        if (arrayLocations != nil)
        {
            for (NSDictionary *dicLocation in arrayLocations) {
                int equipment_id = [[dicLocation objectForKey:@"equipment_id"] intValue];
                Equipment *equipment = [self equipmentWithEquipmentId:equipment_id equipments:arrayExistEquipments];
                if (equipment == nil)
                    continue;
                
                if (![arrayLocationEquipments containsObject:equipment])
                    [arrayLocationEquipments addObject:equipment];
                    
                if (![arrayGenerics containsObject:generic])
                    [arrayGenerics addObject:generic];
                
            }
        }
    }
    
    complete(arrayLocationEquipments);
    return YES;
}

- (BOOL)parseMovementDetailResponse:(NSDictionary *)dicResult
{
    if (dicResult == nil)
        return NO;
    
    BOOL bRet = YES;
    
    NSMutableArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
    NSMutableArray *arrayExistEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
    
    NSArray *arrayResult = (NSArray *)dicResult;
    for (NSDictionary *dicGeneric in arrayResult) {
        int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
        Generic *generic = [self genericWithGenericId:generic_id generics:arrayExistGenerics];
        if (generic == nil)
            continue;
        
        NSArray *arrayEquipments = [dicGeneric objectForKey:@"equipment_array"];
        if (arrayEquipments != nil) {
            for (NSDictionary *dicEquipment in arrayEquipments) {
                int equipment_id = [[dicEquipment objectForKey:@"equipment_id"] intValue];
                Equipment *equipment = [self equipmentWithEquipmentId:equipment_id equipments:arrayExistEquipments];
                if (equipment == nil)
                    continue;
                
                GET_SAFE_INT(current_location_id, dicEquipment, @"current_location_id", 0);
                GET_SAFE_STRING(current_location, dicEquipment, @"current_location", @"");
                GET_SAFE_INT(current_location_parent_id, dicEquipment, @"current_location_parent_id", 0);
                GET_SAFE_STRING(current_location_parent_name, dicEquipment, @"current_location_parent_name", @"");
                equipment.current_location_id = @(current_location_id);
                equipment.current_location = current_location;
                equipment.current_location_parent_id = @(current_location_parent_id);
                equipment.current_location_parent_name = current_location_parent_name;
                
                
                NSArray *movementArray = [dicEquipment objectForKey:@"movement_array"];
                if (movementArray == nil)
                    movementArray = movementArray;
                
                if (![self parseMovements:movementArray withEquipment:equipment]) {
                    bRet = NO;
                    break;
                }
                
                NSArray *movementCount = [dicEquipment objectForKey:@"movement_count"];
                if (![self parseMovementCount:movementCount withEquipment:equipment]) {
                    bRet = NO;
                    break;
                }
            }
            if (bRet == NO)
                break;
        }
    }
    [[ModelManager sharedManager] saveContext];
    return bRet;
}

- (BOOL)parseGenericDetailResponse:(NSDictionary *)dicResult
{
    return [self parseGenericResponse:dicResult];
}

- (BOOL)parseEquipmentDetailResponse:(NSDictionary *)dicResult
{
    if (dicResult == nil)
        return NO;
    
    BOOL bRet = YES;
    
    NSMutableArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
    
    NSArray *arrayResult = (NSArray *)dicResult;
    for (NSDictionary *dicGeneric in arrayResult) {
        int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
        if (generic_id == 240)
            generic_id = generic_id;
        Generic *generic = [self genericWithGenericId:generic_id generics:arrayExistGenerics];
        if (generic == nil)
            continue;
        NSArray *arrayEquipments = [dicGeneric objectForKey:@"equipment_array"];
        if (![self parseEquipments:arrayEquipments withGeneric:generic]) {
            bRet = NO;
            break;
        }
    }
    [[ModelManager sharedManager] saveContext];
    return bRet;
}

- (BOOL)parseLocationDetailResponse:(NSDictionary *)dicResult {
    if (dicResult == nil)
        return NO;
    
    BOOL bRet = YES;
    
    NSMutableArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
    
    NSArray *arrayResult = (NSArray *)dicResult;
    for (NSDictionary *dicGeneric in arrayResult) {
        int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
        Generic *generic = [self genericWithGenericId:generic_id generics:arrayExistGenerics];
        if (generic == nil)
            continue;
        NSArray *arrayLocations = [dicGeneric objectForKey:@"location_array"];
        if (![self parseLocations:arrayLocations withGeneric:generic]) {
            bRet = NO;
            break;
        }
    }
    [[ModelManager sharedManager] saveContext];
    return bRet;
}



- (Generic *)genericWithGenericId:(int)generic_id generics:(NSMutableArray *)arrayGenerics
{
    for (Generic *generic in arrayGenerics) {
        if ([generic.generic_id intValue] == generic_id)
            return generic;
    }
    return nil;
}

- (Equipment *)equipmentWithEquipmentId:(int)equipment_id equipments:(NSMutableArray *)arrayEquipments
{
    for (Equipment *equipment in arrayEquipments) {
        if ([equipment.equipment_id intValue] == equipment_id)
            return equipment;
    }
    return nil;
}


@end
