//
//  AppContext.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject

@property (nonatomic, retain) NSString *cleanDeviceToken;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *receiverId;

+ (AppContext *)sharedAppContext;

+ (NSURL *)applicationDocumentsDirectory;

- (void)setReceiverId:(NSString *)currentReceiverId;

@end
