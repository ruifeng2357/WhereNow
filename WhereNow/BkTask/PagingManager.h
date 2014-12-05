//
//  PagingManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 13/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipment.h"

@interface PagingManager : NSObject

+ (PagingManager *)sharedInstance;

- (BOOL)startPaging:(Equipment *)equipment;
- (void)stopPaging;

@end
