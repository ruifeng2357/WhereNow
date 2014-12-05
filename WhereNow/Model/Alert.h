//
//  Alert.h
//  WhereNow
//
//  Created by Xiaoxue Han on 21/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alert : NSManagedObject

@property (nonatomic, retain) NSNumber * alert_id;
@property (nonatomic, retain) NSString * alert_type;
@property (nonatomic, retain) NSNumber * current_location_id;
@property (nonatomic, retain) NSString * current_location_name;
@property (nonatomic, retain) NSString * current_location_parent_name;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSNumber * equipment_id;
@property (nonatomic, retain) NSString * location_name;
@property (nonatomic, retain) NSString * location_parent_name;
@property (nonatomic, retain) NSString * serial_no;
@property (nonatomic, retain) NSDate * trigger_datetime;
@property (nonatomic, retain) NSString * trigger_string;
@property (nonatomic, retain) NSNumber * user_count;

@end
