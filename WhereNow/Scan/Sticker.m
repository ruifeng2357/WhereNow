//
//  Sticker.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "Sticker.h"

@interface Sticker ()

@end

@implementation Sticker

- (id)init
{
    self = [super init];
    self.state = StickerStateDisconnected;
    
    return self;
}

- (void)connect
{
    [self.device connect];
}

- (void)disconnect
{
    [self.device disconnect];
}

- (void)alert
{
    [self.device enableAlertSound:YES light:YES];
}

- (void)setDevice:(LeSnfDevice *)device
{
    _device = device;
}

- (void) onStateChanged:(int)state
{
    StickerState stickerState = StickerStateDisconnected;
    if (LE_DEVICE_STATE_CONNECTED == state) /* device just connected */
    {
        NSLog(@"device connected");
        stickerState = StickerStateConnected;
    }
    else if (LE_DEVICE_STATE_DISCONNECTED == state)
    {
        NSLog(@"device disconnected");
        stickerState = StickerStateDisconnected;
    }
    else if (LE_DEVICE_STATE_CONNECTING == state)
    {
        NSLog(@"device connecting...");
        stickerState = StickerStateConnecting;
    }
    else if (LE_DEVICE_STATE_UPDATING_FIRMWARE == state)
    {
        NSLog(@"firmware updating...");
        stickerState = StickerStateUpdating;
    }
    self.state = stickerState;
    
    if (self.delegate)
        [self.delegate sticker:self didStateChanged:stickerState];
}

@end
