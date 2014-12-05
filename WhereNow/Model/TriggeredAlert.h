//
//  TriggeredAlert.h
//  WhereNow
//
//  Created by Xiaoxue Han on 21/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TriggeredAlert : NSManagedObject

@property (nonatomic, retain) NSNumber * alert_id;
@property (nonatomic, retain) NSNumber * opened;
@property (nonatomic, retain) NSString * opened_date;

@end
