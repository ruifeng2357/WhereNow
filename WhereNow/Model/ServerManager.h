//
//  SeverManager.h
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceErrorCodes.h"
#import "ResponseParseStrategyProtocol.h"
#import "Equipment.h"

#define HOST_URL    @"http://dev.scmedical.com.au/"
#define API_URL     @"http://dev.scmedical.com.au/mobile/index.php/"


// v2
#define kAPIBaseUrlV2       @"api/v2/"

#define kMethodForLoginV2           @"user"
#define kMethodForRegisterToken     @"registertoken"
#define kMethodForLogout            @"userlogout"
#define kMethodForBadge             @"changebadge"
#define kMethodForCreateEquipmentWatch  @"createequipmentwatch"
#define kMethodForCancelEquipmentWatch  @"cancelequipmentwatch"
#define kMethodForForgotPasswordV2   @"forgotpassword"
#define kMethodForForgotUsernameV2   @"forgotusername"
#define kMethodForDeviceList         @"getregistereddevice"
#define kMethodForCheckDeviceRemoved    @"isdeviceremoved"
#define kMethodForReceivedDevice    @"";
#define kMethodForSetPhoneBeacon @"setphonebeacon"

#define DEF_SERVERMANAGER   ServerManager *manager = [ServerManager sharedManager];

typedef void (^ServerManagerRequestHandlerBlock)(NSString *, NSDictionary *, NSError *);

@interface ServerManager : NSObject

@property (nonatomic, strong) id<ResponseParseStrategyProtocol> parser;

+ (ServerManager *)sharedManager;

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;
- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;


- (void)loginUserV2WithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId, NSString *fullname))success failure:(void (^)(NSString *))failure;

/**
 * get generics list
 *
 */
//- (void)getGenericsV2:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)updateDeviceToken:(NSString *)deviceToken sessionId:(NSString *)sessionId userId:(NSString *)userId deviceName:(NSString *)deviceName success:(void (^)(NSString *tokenId, NSString *locname, NSString *locid))success failure:(void (^)(NSString *))failure;

- (void)userLogout:(NSString *)sessionId userId:(NSString *)userId tokenId:(NSString *)tokenId isRemote:(BOOL)isRemote success:(void (^)(NSString *tokenId))success failure:(void (^)(NSString *))failure;

- (void)resetBadgeCountWithToken:(NSString *)token sessionId:(NSString *)sessionId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)createEquipmentWatch:(NSArray *)arrayEquipmentIds token:(NSString *)token sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)cancelEquipmentWatch:(NSArray *)arrayEquipmentIds token:(NSString *)token sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)getRegisteredDeviceList:(NSString *)sessionId userId:(NSString *)userId success:(void (^)(NSArray *arrayDevices))success failure:(void (^)(NSString *))failure;

- (void)sendReceivedDevices:(NSString *)Minor receiver:(NSString *)receiver isvisible:(int)isvisible success:(void (^)(BOOL removed))success failure:(void (^)(NSString *))failure;

- (void)checkDeviceRemoved:(NSString *)sessionId userId:(NSString *)userId tokenId:(NSString *)tokenId success:(void (^)(BOOL removed))success failure:(void (^)(NSString *))failure;

- (void) setPhoneBeacon:(NSString *)sessionid tid:(NSString *)tid uuid:(NSString *) uuid major:(NSString *)major minor:(NSString *)minor success:(void (^)(BOOL success)) success failure:(void (^)(NSString *)) failure;

/**
 *
 * get information(generics/equipments) of current location
 *   request location information with beacons scaned by the phone
 */
- (void)getCurrLocationV2:(NSString *)sessionId userId:(NSString *)userId arrayBeacons:(NSMutableArray *)arrayBeacons success:(void(^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))success failure:(void (^)(NSString *))failure;

- (void)getCurrLocationWithLocationId:(NSString *)locationId sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void(^)(NSMutableArray *arrayEquipments))success failure:(void (^)(NSString *))failure;

- (void)getMovementsForEquipment:(Equipment *)equipment sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void(^)())success failure:(void (^)(NSString *))failure;

- (void)getLocationsForGeneric:(int)generic_id sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)getGenerics:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)getEquipmentsForGeneric:(int)generic_id sessionId:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)forgotUsernameWithEmail:(NSString *)email success:(void(^)())success failure:(void (^)(NSString *))failure;
- (void)forgotPasswordWithEmail:(NSString *)email success:(void(^)())success failure:(void (^)(NSString *))failure;

// utilities
- (void)setImageContent:(UIImageView*)ivContent urlString:(NSString *)urlString success:(void(^)(UIImage *image))success;

@end
