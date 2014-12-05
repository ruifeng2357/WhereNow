//
//  MovementCount.h
//  WhereNow
//
//  Created by Xiaoxue Han on 22/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MovementCount : NSManagedObject

@property (nonatomic, retain) NSNumber * equipment_id;
@property (nonatomic, retain) NSNumber * mon;
@property (nonatomic, retain) NSNumber * tue;
@property (nonatomic, retain) NSNumber * wed;
@property (nonatomic, retain) NSNumber * thu;
@property (nonatomic, retain) NSNumber * fri;
@property (nonatomic, retain) NSNumber * sat;
@property (nonatomic, retain) NSNumber * sun;

@end
