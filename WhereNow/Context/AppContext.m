//
//  AppContext.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AppContext.h"

static AppContext *_sharedAppContext = nil;

@implementation AppContext

+ (AppContext *)sharedAppContext
{
    if (_sharedAppContext == nil)
        _sharedAppContext = [[AppContext alloc] init];
    return _sharedAppContext;
}

- (id)init
{
    self = [super init];
    if (self) {
        _receiverId = @"0";
        [self load];
    }
    
    return self;
}

- (void)load
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSObject *obj = [userDefaults objectForKey:@"receiverId"];
    if (obj != nil)
        _receiverId = (NSString *)obj;
}

- (void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.receiverId forKey:@"receiverId"];
    
    [userDefaults synchronize];
}

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask]
            lastObject];
}

- (void) setReceiverId:(NSString *)currentReceiverId
{
    _receiverId = currentReceiverId;
    [self save];
}


@end
