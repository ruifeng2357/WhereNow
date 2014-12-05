//
//  StickerManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <snfsdk/snfsdk.h>
#import "Sticker.h"

@class StickerManager;

@protocol StickerManagerDelegate <NSObject>

- (void)stickerManager:(StickerManager *)stickerManager didDiscoverSticker:(Sticker *)sticker;
- (void)stickerManager:(StickerManager *)stickerManager didGetSidForSticker:(Sticker *)sticker sid:(int)sid;

@end

@interface StickerManager : NSObject

@property (nonatomic, retain) LeDeviceManager *manager;
@property (nonatomic, retain) NSMutableArray *arrayStickers;
@property (nonatomic, weak) id<StickerManagerDelegate> delegate;

+ (StickerManager *)sharedManager;
- (void)startDiscover;
- (void)stopDiscover;



@end
