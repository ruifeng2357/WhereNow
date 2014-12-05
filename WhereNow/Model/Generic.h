//
//  Generic.h
//  WhereNow
//
//  Created by Xiaoxue Han on 26/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Generic : NSManagedObject

@property (nonatomic, retain) NSNumber * alert_count;
@property (nonatomic, retain) NSString * alert_icon;
@property (nonatomic, retain) NSNumber * alert_icon_id;
@property (nonatomic, retain) NSNumber * generic_id;
@property (nonatomic, retain) NSString * generic_name;
@property (nonatomic, retain) NSNumber * genericwise_equipment_count;
@property (nonatomic, retain) NSNumber * isfavorites;
@property (nonatomic, retain) NSNumber * isrecent;
@property (nonatomic, retain) NSDate * recenttime;
@property (nonatomic, retain) NSString * status_message;

@end
