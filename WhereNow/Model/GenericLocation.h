//
//  GenericLocation.h
//  WhereNow
//
//  Created by Xiaoxue Han on 14/11/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GenericLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * ble_location_id;
@property (nonatomic, retain) NSNumber * generic_id;
@property (nonatomic, retain) NSString * generic_name;
@property (nonatomic, retain) NSString * location_name;
@property (nonatomic, retain) NSNumber * location_wise_equipment_count;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minimum_level;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSNumber * optimal_level;
@property (nonatomic, retain) NSString * status_message;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * warning_level;
@property (nonatomic, retain) NSNumber * ble_parent_location_id;
@property (nonatomic, retain) NSString * parent_location_name;

@end
