//
//  StickerManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "StickerManager.h"

static StickerManager *_sharedStickerManager = nil;

@interface StickerManager () <LeDeviceManagerDelegate, LeSnfDeviceDelegate>
{
    NSString *leFileName;           // file name for persistent storage dictionary
    NSMutableDictionary *leDict;    // dictionary used for persistent storage
}

@end

@implementation StickerManager

+ (StickerManager *)sharedManager
{
    if (_sharedStickerManager == nil)
    {
        _sharedStickerManager = [[StickerManager alloc] init];
        [_sharedStickerManager openManager];
    }
    return _sharedStickerManager;
}

- (void)openManager
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    leFileName =  [applicationSupportDirectory stringByAppendingString:@"/LeDevices.plist"];
    leDict = [[NSMutableDictionary alloc] initWithContentsOfFile: leFileName];
    if (nil == leDict)
        leDict = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void)startDiscover
{
    self.arrayStickers = [[NSMutableArray alloc] init];
    self.manager = [[LeDeviceManager alloc] initWithSupportedDevices:@[[LeSnfDevice class]] delegate:self];
}

- (void)stopDiscover
{
    self.delegate = nil;
    for (Sticker *sticker in self.arrayStickers) {
        sticker.delegate = nil;
        [sticker disconnect];
    }
    [self.manager stopScan];
}

#pragma mark LeDeviceManagerDelegate
//  called on discovery of a new device
- (void) leDeviceManager: (LeDeviceManager *) mgr didAddNewDevice:(LeDevice*) dev
{
    if ([dev isKindOfClass:[LeSnfDevice class]])
    {
        Sticker *sticker = [[Sticker alloc] init];
        ((LeSnfDevice *)dev).delegate = self;
        sticker.device = (LeSnfDevice *)dev;
        [self.arrayStickers addObject:sticker];
        
        if (self.delegate)
            [self.delegate stickerManager:self didDiscoverSticker:sticker];
    }
}

- (NSArray *) retrieveStoredDeviceUUIDsForLeDeviceManager: (LeDeviceManager *)mgr
{
    return [leDict allKeys];
}

- (id) leDeviceManager: (LeDeviceManager *) mgr valueForDeviceUUID: (CFUUIDRef) uuid key:(NSString *)key
{
    NSDictionary *d = [leDict objectForKey: (__bridge NSString *) CFUUIDCreateString(NULL,uuid) ];
    if (d)
    {
        return [d valueForKey:key];
    }
    return NULL;
}

- (void) leDeviceManager: (LeDeviceManager *) mgr setValue: (id) value forDeviceUUID: (CFUUIDRef) uuid key:(NSString *)key
{
    NSString *ks = (__bridge NSString *) CFUUIDCreateString(NULL,uuid);
    NSMutableDictionary *d = [leDict valueForKey: ks ];
    if (nil == d)
    {
        d = [[NSMutableDictionary alloc] initWithCapacity:2];
        [leDict setValue: d forKey: ks];
    }else if (![d isKindOfClass: [NSMutableDictionary class]])
    {
        d = [d mutableCopy];
        [leDict setValue: d forKey: ks];
    }
    if (d)
    {
        [d setValue: value forKey: key];
        [leDict writeToFile: leFileName atomically:true];
    }
    
}

- (void) leSnfDevice:(LeSnfDevice *)dev didUpdateBroadcastData: (NSData *) data
{
    uint8_t t[32];
    if (data.length > 32) return;
    [data getBytes:t];
    NSString *str = @"";
    for (int i = 0; i < data.length; i++)
        str = [NSString stringWithFormat:@"%@ %02X", str, (int)t[i]];
    NSLog(@"broadcast data \n%@", str);
    
    if (data.length == 22) {
        // F9 00 13 78 56 34 12 6B 16 01 00 06 D4 1A 26 B3 99 30 70 67 4C 38
        if (t[0] == 0xF9)
        {
            NSLog(@"getting sid");
            uint32_t sid = *(uint32_t *)(&t[3]);
            
            if (self.delegate)
            {
                for (Sticker *sticker in self.arrayStickers) {
                    if ([sticker.device isEqual:dev])
                    {
                        sticker.sid = (int)sid;
                        [self.delegate stickerManager:self didGetSidForSticker:sticker sid:(int)sid];
                        break;
                    }
                }
            }
        }
    }
}

- (void) leSnfDevice:(LeSnfDevice *)dev didChangeState:(int)state
{
    for (Sticker *sticker in self.arrayStickers) {
        if ([sticker.device isEqual:dev])
        {
            [sticker onStateChanged:state];
            break;
        }
    }
}

@end
