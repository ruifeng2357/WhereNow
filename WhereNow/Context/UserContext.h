//
//  UserContext.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserContext : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) BOOL isLastLoggedin;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *userId;

// YES when user logge in, otherwise NO
@property (nonatomic) BOOL isLoggedIn;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *tokenId;
@property (nonatomic, strong) NSString *currentLocation;
@property (nonatomic, strong) NSString *currentLocationId;
@property (nonatomic, strong) NSNumber *currTagMinor;

+ (UserContext *)sharedUserContext;

- (void)setUserName:(NSString *)userName;
- (void)setPassword:(NSString *)password;
- (void)setIsLastLoggedin:(BOOL)isLastLoggedin;
- (void)setSessionId:(NSString *)sessionId;
- (void)setUserId:(NSString *)userId;
- (void)setIsLoggedIn:(BOOL)isLoggedIn;
- (void)setFullName:(NSString *)fullName;
- (void)setTokenId:(NSString *)tokenId;
- (void)setCurrentLocation:(NSString *)currentLocation;
- (void)setCurrentLocationId:(NSString *)currentLocationId;
- (void)setCurrTagMinor:(NSNumber *)currTagMinor;

@end
