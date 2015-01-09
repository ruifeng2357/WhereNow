//
//  SeverManager.m
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#import "ServerManager.h"
#import "Reachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "AFNetworking.h"
#import "SBJson.h"
#import <CoreLocation/CoreLocation.h>
#import "AppContext.h"
#import "UIImageView+WebCache.h"

static ServerManager *_sharedServerManager = nil;

NSString * const WhereNowErrorDomain = @"com.wherenow";

#define kDescriptionNotReachable    @"Network error"
#define ErrorFromNotReachable   ([NSError errorWithDomain:WhereNowErrorDomain code:ServiceErrorNetwork userInfo:@{NSLocalizedDescriptionKey:kDescriptionNotReachable}])

@implementation ServerManager

+ (ServerManager *)sharedManager
{
    if (_sharedServerManager == nil)
        _sharedServerManager = [[ServerManager alloc] init];
    return _sharedServerManager;
}

- (BOOL)hasConnectivity
{
    // test reachability
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    Reachability *reachability = [Reachability reachabilityWithAddress:&zeroAddress];
    if (reachability != nil)
    {
        if ([reachability isReachable])
            return YES;
        return NO;
    }
    return NO;
}

- (void)callMethodName:(NSString *)methodName isGet:(BOOL)isGet params:(NSDictionary *)params completion:(void (^)(NSString *, NSDictionary *, NSError *))handler
{
    if (![self hasConnectivity])
    {
        NSLog(@"Request error, network error");
        handler(nil, nil, ErrorFromNotReachable);
        return;
    }
    
    NSURL  *url = nil;
    url = [NSURL URLWithString:API_URL];
    NSLog(@"requesting : %@%@\n%@", url, methodName, params);
    
	AFHTTPClient  *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    void (^successHandler)(AFHTTPRequestOperation *operation, id responseObject)  = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (responseObject == nil)
        {
            NSLog(@"Request error, responseObject = nil");
            handler(nil, nil, [NSError errorWithDomain:WhereNowErrorDomain code:ServiceErrorNoResponse userInfo:nil]);
        }
        else
        {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            // remove <pre> tag if exists
            
            if (responseStr.length > 0)
            {
                if ([[responseStr substringToIndex:5] isEqualToString:@"<pre>"])
                    responseStr = [responseStr substringFromIndex:5];
                // remove prefix till to meet {
                NSRange range = [responseStr rangeOfString:@"{" options:0 range:NSMakeRange(0, responseStr.length)];
                NSRange range1 = [responseStr rangeOfString:@"[" options:0 range:NSMakeRange(0, responseStr.length)];
                
                NSRange range2;
                range2.length = 0;
                range2.location = NSNotFound;
                
                if (range.location != NSNotFound && range1.location != NSNotFound)
                {
                    if (range1.location < range.location)
                        range2 = range1;
                    else
                        range2 = range;
                }
                else if (range.location != NSNotFound)
                {
                    range2 = range;
                }
                else if (range1.location != NSNotFound)
                {
                    range2 = range1;
                }
                    
                if (range2.location != NSNotFound && range2.location > 0)
                {
                    responseStr = [responseStr substringFromIndex:range2.location];
                }
                
                NSDictionary *responseDic = [responseStr JSONValue];
                if (responseStr == nil)
                {
                    NSLog(@"Request successful, response string is nil");
                }
                else
                {
                    if (responseStr.length >= 3000)
                        NSLog(@"Request Successful, response '%@'", [responseStr substringToIndex:3000]);
                    else
                        NSLog(@"Request Successful, response '%@'", responseStr);
                }
                
                handler(responseStr, responseDic, nil);
            }
        }
        
    };
    
    void (^errorHandler)(AFHTTPRequestOperation *operation, NSError *error)  = ^ (AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        handler(nil, nil, error);
    };
    
    if (isGet)
    {
        [httpClient getPath:methodName parameters:params success:successHandler failure:errorHandler];
    }
    else
    {
        [httpClient postPath:methodName parameters:params success:successHandler failure:errorHandler];
    }
    
}

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler
{
    [self callMethodName:methodName isGet:YES params:params completion:handler];
}

- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler
{
    [self callMethodName:methodName isGet:NO params:params completion:handler];
}


#pragma mark - User Login
- (void)loginUserV2WithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId, NSString *fullname))success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uname": userName, @"upass": pwd};
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@%@.json", kAPIBaseUrlV2, kMethodForLoginV2];
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"] ||
                [responseStr isEqualToString:@"Invalid User Name Password\n"])
            {
                failure(@"Invalid User Name and Password!");
            }
            else
            {
                //success(@"SESID-AABB", @"27");
                failure(@"Invalid response from server!");
            }
            return;
        }
        else
        {
            //{"ERROR":"Invalid User Name or Password"}
            // or {"ID":"SESID-AABB","UID":"27"}
            NSString *userId = [response objectForKey:@"UID"];
            if (userId == nil || [userId isEqual:[NSNull null]])
            {
                NSString *msg = [response objectForKey:@"ERROR"];
                if (msg == nil)
                    msg = @"Unknown error";
                failure(msg);
            }
            else
            {
                NSString *sessionId = [response objectForKey:@"ID"];
                NSString *fullname = [response objectForKey:@"NAME"];
                if (sessionId == nil || [sessionId isEqual:[NSNull null]])
                    failure(@"Invalid response");
                else
                {
                    success(sessionId, userId, fullname);
                }
            }
        }
    }];
}

- (void)getCurrLocationV2:(NSString *)sessionId userId:(NSString *)userId arrayBeacons:(NSMutableArray *)arrayBeacons success:(void (^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))sc failure:(void (^)(NSString *))failure
{
    
    DEF_SERVERMANAGER
    
    // parse beacon arrays and make params
    NSMutableArray *beaconsJsonArray = [[NSMutableArray alloc] init];
    for (CLBeacon *beacon in arrayBeacons) {
        NSMutableDictionary *dicBeacon = [[NSMutableDictionary alloc] init];
        [dicBeacon setObject:[beacon.proximityUUID UUIDString] forKey:@"uuid"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", [beacon.major intValue]] forKey:@"major"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", [beacon.minor intValue]] forKey:@"minor"];
//        if ([beacon.minor integerValue] == 51)
//        {
        [beaconsJsonArray addObject:dicBeacon];
//        break;
//        }
    }
    
    if (arrayBeacons.count <= 0)
    {
//        NSMutableDictionary *dicBeacon = [[NSMutableDictionary alloc] init];
//        [dicBeacon setObject:@"B125AA4F-2D82-401D-92E5-F962E8037F5C" forKey:@"uuid"];
//        [dicBeacon setObject:[NSString stringWithFormat:@"%d", 100] forKey:@"major"];
//        [dicBeacon setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"minor"];
//        [beaconsJsonArray addObject:dicBeacon];
        sc([NSMutableArray array], [NSMutableArray array], [NSMutableArray array]);
        return;
    }
    
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:beaconsJsonArray options:0 error:nil];
    NSString *strJsonScanned = [[NSString alloc] initWithBytes:[serializedData bytes] length:[serializedData length] encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"uid":userId, @"scanned":strJsonScanned, @"requesttype":@"locationdetail"};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            // parse response
            [self.parser parseNearmeResponse:response complete:^(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments) {
                
                sc(arrayGenerics, arrayVicinityEquipments, arrayLocationEquipments);
                
            } failure:^() {
                //
                failure(@"failed to parse response");
            }];
        }
    }];
}

- (void)getCurrLocationWithLocationId:(NSString *)locationId sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)(NSMutableArray *))sc failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    if (locationId == nil) {
        NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
        sc(emptyArray);
        return;
    }
    NSDictionary *params = @{@"uid": userId,
                             @"lid": locationId,
                             @"requesttype": @"equipmentdetail"};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error) {
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            BOOL ret = [self.parser parseCurrentLocationEquipmentsResponse:response complete:^(NSMutableArray *arrayLocationEquipments) {
                
                sc(arrayLocationEquipments);
                
            } failure:^() {
                //
                failure(@"failed to parse response");
            }];
            
            if (!ret) {
                NSLog(@"parse current location response failed : \n params : %@ \n response : %@", params, response);
            }
        }
    }];
}

- (void)getMovementsForEquipment:(Equipment *)equipment sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uid":userId,
                             @"gid":[NSString stringWithFormat:@"%@", equipment.generic_id],
                             @"eid":[NSString stringWithFormat:@"%@", equipment.equipment_id],
                             @"requesttype":@"movementdetail"};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error) {
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            // parse response, insert & update managed objects, save context
            [self.parser parseMovementDetailResponse:response];
            
            // delegate to oberver success
            success();
        }
    }];
}

- (void)getLocationsForGeneric:(int)generic_id sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uid": userId,
                             @"gid": [NSString stringWithFormat:@"%d", generic_id],
                             @"requesttype": @"locationdetail"};
    DEF_SERVERMANAGER
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid Response!");
            }
            return;
        }
        else
        {
            // parse response, insert & update managed objects, save context
            [self.parser parseLocationDetailResponse:response];
            
            // delegate to oberver success
            success();
        }
        
    }];
}

- (void)getGenerics:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uid": userId,
                             @"requesttype": @"genericdetail"};
    DEF_SERVERMANAGER
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid Response!");
            }
            return;
        }
        else
        {
            // parse response, insert & update managed objects, save context
            [self.parser parseGenericResponse:response];
            
            // delegate to oberver success
            success();
        }
        
    }];

}

- (void)getEquipmentsForGeneric:(int)generic_id sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uid": userId,
                             @"gid": [NSString stringWithFormat:@"%d", generic_id],
                             @"requesttype": @"equipmentdetail"};
    DEF_SERVERMANAGER
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid Response!");
            }
            return;
        }
        else
        {
            // parse response, insert & update managed objects, save context
            [self.parser parseEquipmentDetailResponse:response];
            
            // delegate to oberver success
            success();
        }
        
    }];
}

- (void)updateDeviceToken:(NSString *)deviceToken sessionId:(NSString *)sessionId userId:(NSString *)userId deviceName:(NSString *)deviceName success:(void (^)(NSString *tokenId, NSString *locname, NSString *locid))success failure:(void (^)(NSString *))failure
{
    
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uid":userId, @"utoken":deviceToken, @"dname":deviceName};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForRegisterToken];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            //NSString *userId = [response objectForKey:@"UID"];
            NSString *tokenId = [response objectForKey:@"tid"];
            NSString *curLocationName = [response objectForKey:@"location_name"];
            if (curLocationName == nil || [curLocationName isEqual:[NSNull null]])
                curLocationName = @"";
            else if ([curLocationName isEqualToString:@""])
                curLocationName = @"";
            NSString *curLocID = [response objectForKey:@"lid"];
            if (curLocID == nil || [curLocID isEqual:[NSNull null]])
                curLocID = @"0";
            else if ([curLocID isEqualToString:@""])
                curLocID = @"0";
            
            success(tokenId, curLocationName, curLocID);
        }
    }];
}

- (void)userLogout:(NSString *)sessionId userId:(NSString *)userId tokenId:(NSString *)tokenId isRemote:(BOOL)isRemote success:(void (^)(NSString *tokenId))success failure:(void (^)(NSString *))failure
{
    
    DEF_SERVERMANAGER
    
    NSDictionary *params;
    if (!isRemote)
        params = @{@"uid":userId,
                   @"tid":tokenId};
    else
        params = @{@"uid":userId,
                   @"tid":tokenId,
                   @"remote":@"Y"};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForLogout];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            //NSString *userId = [response objectForKey:@"UID"];
            //NSString *tokenId = [response objectForKey:@"tokenID"];
            success(tokenId);
        }
    }];
}

- (void)resetBadgeCountWithToken:(NSString *)token sessionId:(NSString *)sessionId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"utoken":token};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForBadge];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            success();
        }
    }];
}

- (void)createEquipmentWatch:(NSArray *)arrayEquipmentIds token:(NSString *)token sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:arrayEquipmentIds options:0 error:nil];
    NSString *strJsonIds = [[NSString alloc] initWithBytes:[serializedData bytes] length:[serializedData length] encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"utoken":token,
                             @"eid":strJsonIds};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForCreateEquipmentWatch];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            success();
        }
    }];
}

- (void)cancelEquipmentWatch:(NSArray *)arrayEquipmentIds token:(NSString *)token sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:arrayEquipmentIds options:0 error:nil];
    NSString *strJsonIds = [[NSString alloc] initWithBytes:[serializedData bytes] length:[serializedData length] encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"utoken":token,
                             @"eid":strJsonIds};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForCancelEquipmentWatch];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            success();
        }
    }];
}

- (void)getRegisteredDeviceList:(NSString *)sessionId userId:(NSString *)userId success:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uid":userId};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForDeviceList];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            NSArray *arrayDevices = (NSArray *)response;
            success(arrayDevices);
        }
    }];
}

-(void) sendReceivedDevices:(NSString *)Minor receiver:(NSString *)receiver isvisible:(int)isvisible success:(void (^)(BOOL removed))success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params;
    if (isvisible != 2)
        params = @{@"Minor":Minor, @"receiver":receiver};
    else
        params = @{@"Minor":Minor, @"receiver":receiver, @"visible":@"false"};
    
    NSString *methodName = kMethodForReceivedDevice;
    
    [manager getMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error)
    {
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            NSString *strActive = [response objectForKey:@"active"];
            if ([strActive isEqualToString:@"t"])
                success(NO);
            else
                success(YES);
        }
    }];
}

- (void) setPhoneBeacon:(NSString *)sessionid tid:(NSString *)tid uuid:(NSString *) uuid major:(NSString *)major minor:(NSString *)minor success:(void (^)(BOOL success)) success failure:(void (^)(NSString *)) failure;
{
    DEF_SERVERMANAGER;
    
    NSDictionary *params = @{@"tid":tid, @"uuid":uuid, @"major":major, @"minor":minor};
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionid, kMethodForSetPhoneBeacon];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else if ([responseStr isEqualToString:@"Invalid Beacon\n"])
            {
                failure(@"Invalid Beacon!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            success(YES);
        }
    }];
    
    return;
}

- (void)checkDeviceRemoved:(NSString *)sessionId userId:(NSString *)userId tokenId:(NSString *)tokenId success:(void (^)(BOOL))success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uid":userId, @"tid":tokenId};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, kMethodForCheckDeviceRemoved];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            NSString *strActive = [response objectForKey:@"active"];
            if ([strActive isEqualToString:@"t"])
                success(NO);
            else
                success(YES);
        }
    }];
}

- (void)forgotUsernameWithEmail:(NSString *)email success:(void (^)())success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uemail":email};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@.json", kAPIBaseUrlV2, kMethodForForgotUsernameV2];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            success();
        }
    }];
}

- (void)forgotPasswordWithEmail:(NSString *)email success:(void (^)())success failure:(void (^)(NSString *))failure
{
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uemail":email};
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@.json", kAPIBaseUrlV2, kMethodForForgotPasswordV2];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            success();
        }
    }];
}



#pragma mark - Utilities
- (void) setImageContent:(UIImageView*)ivContent urlString:(NSString *)urlString success:(void(^)(UIImage *image))success
{
    if (urlString != nil && ![urlString isEqualToString:@""])
    {
        //NSString *strImage = [NSString stringWithFormat:@"%@%@", HOST_URL, urlString];
        NSString *strImage = urlString;
//        [ivContent setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"Loading"]
//                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                               ivContent.image = image;
//                               success(image);
//                           } failure:nil];
        [ivContent sd_setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"Loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            success(image);
        }];
    }
    else
    {
        // url is incorrect
        //NSString *strImage = [NSString stringWithFormat:@"%@%@", HOST_URL, urlString];
        //NSString *strImage = urlString;
//        [ivContent setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"Loading"]
//                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                               ivContent.image = image;
//                               success(image);
//                           } failure:nil];
        [ivContent setImage:[UIImage imageNamed:@"Loading"]];
        /*
        [ivContent sd_setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"Loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            success(image);
        }];
         */
        success(nil);
    }
}

@end
