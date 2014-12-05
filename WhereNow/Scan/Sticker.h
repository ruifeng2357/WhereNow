//
//  Sticker.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <snfsdk/snfsdk.h>

typedef NS_ENUM(int, StickerState) {
    StickerStateConnected,
    StickerStateDisconnected,
    StickerStateConnecting,
    StickerStateUpdating
};

@class Sticker;

@protocol StickerDelegate <NSObject>
@required
- (void)sticker:(Sticker *)sticker didStateChanged:(StickerState)state;
@end

@interface Sticker : NSObject

@property (nonatomic) StickerState state;
@property (nonatomic, retain) LeSnfDevice *device;
@property (nonatomic) int sid;
@property (nonatomic, weak) id<StickerDelegate> delegate;

- (void)connect;
- (void)disconnect;
- (void)alert;
- (void)onStateChanged:(int)state;

@end
