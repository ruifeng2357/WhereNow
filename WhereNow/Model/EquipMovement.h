//
//  EquipMovement.h
//  WhereNow
//
//  Created by Xiaoxue Han on 08/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EquipMovement : NSManagedObject

@property (nonatomic, retain) NSNumber * ble_location_id;
@property (nonatomic, retain) NSString * check_in_date;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSNumber * equipment_id;
@property (nonatomic, retain) NSString * location_name;
@property (nonatomic, retain) NSNumber * stay_minutes;
@property (nonatomic, retain) NSString * stay_time;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * time_limit;
@property (nonatomic, retain) NSString * parent_location_name;

@end
