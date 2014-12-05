//
//  ResponseParseStrategyProtocol.h
//  WhereNow
//
//  Created by Xiaoxue Han on 07/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#ifndef WhereNow_ResponseParseStrategyProtocol_h
#define WhereNow_ResponseParseStrategyProtocol_h

@protocol ResponseParseStrategyProtocol <NSObject>

@optional
- (BOOL)parseGenericResponse:(NSDictionary *)dicResult;
- (BOOL)parseNearmeResponse:(NSDictionary *)dicResult complete:(void (^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))complete failure:(void(^)())failure;
- (BOOL)parseCurrentLocationEquipmentsResponse:(NSDictionary *)dicResult complete:(void (^)(NSMutableArray *arrayCurrentLocationEquipments))complete failure:(void(^)())failure;
- (BOOL)parseMovementDetailResponse:(NSDictionary *)dicResult;
- (BOOL)parseGenericDetailResponse:(NSDictionary *)dicResult;
- (BOOL)parseEquipmentDetailResponse:(NSDictionary *)dicResult;
- (BOOL)parseLocationDetailResponse:(NSDictionary *)dicResult;
@end

#endif
