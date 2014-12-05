//
//  PagingManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 13/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "PagingManager.h"
#import "SVProgressHUD+WhereNow.h"
#import "BackgroundTaskManager.h"
#import "StickerManager.h"
#include <sys/time.h>

#define kPagingTimeout  25.0f

static PagingManager *_sharedPagingManager = nil;

@interface PagingManager () <StickerManagerDelegate, StickerDelegate>
{
    long startedTime;
}

@property (nonatomic, retain) Equipment *equipment;
@property (nonatomic, retain) Sticker *sticker;
@property (nonatomic, retain) NSMutableArray *arrayDisconnectingSticker;

@property (nonatomic) BOOL started;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation PagingManager

+ (PagingManager *)sharedInstance
{
    if (_sharedPagingManager == nil)
        _sharedPagingManager = [[PagingManager alloc] init];
    return _sharedPagingManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.equipment = nil;
        self.sticker = nil;
        self.arrayDisconnectingSticker = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)startPaging:(Equipment *)equipment
{
    if (self.started)
        return NO;
    
    self.started = YES;
    self.equipment = equipment;
    startedTime = [self getCurrentMilliTime];
    self.sticker = nil;
    
   
    [BackgroundTaskManager sharedManager].stickBeaconManager.delegate = self;
    [[BackgroundTaskManager sharedManager] changeToStickBeaconMode];
    
    // show alert
    SHOW_PROGRESS(@"Device Alert\nFinding Equipment...");
    
    // start timer;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    
    return self.started;
}

- (void)stopPaging
{
    self.started = NO;
    //if (self.timer)
    //{
    //    [self.timer invalidate];
    //    self.timer = nil;
    //}
    
    //if (self.sticker)
    //{
    //    self.sticker.delegate = nil;
    //    [self.sticker disconnect];
    //}
    
    //change mode
    [[BackgroundTaskManager sharedManager] cancelStickBeaconMode];
}

- (void)onTimer:(id)sender
{
    if (self.started)
    {
        long currTime = [self getCurrentMilliTime];
        if (currTime - startedTime >= kPagingTimeout * 1000)
        {
            if (self.sticker)
            {
                [self.arrayDisconnectingSticker addObject:self.sticker];
                self.sticker = nil;
            }
            [self stopPaging];
        
            // timeout alert
            HIDE_PROGRESS_WITH_FAILURE(@"Device Alert\nTimeout");
        }
    }
    
    NSMutableArray *arrayRemovable = [[NSMutableArray alloc] init];
    for (Sticker *sticker in self.arrayDisconnectingSticker) {
        switch (sticker.state) {
            case StickerStateConnected:
                [self.sticker disconnect];
                break;
            case StickerStateConnecting:
                break;
            case StickerStateDisconnected:
                [arrayRemovable addObject:sticker];
                break;
            case StickerStateUpdating:
                break;
            default:
                break;
        }
    }
    
    for (Sticker *sticker in arrayRemovable) {
        [self.arrayDisconnectingSticker removeObject:sticker];
    }
}

- (void)onFinishedPaging
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.sticker)
        {
            [self.arrayDisconnectingSticker addObject:self.sticker];
            self.sticker = nil;
        }
        [self stopPaging];
    });
}

- (void)onFoundSticker:(Sticker *)sticker
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.started)
        {
            if (self.sticker == nil)
            {
                startedTime = [self getCurrentMilliTime];
                
                self.sticker = sticker;
                self.sticker.delegate = self;
                
                // alert
                SHOW_PROGRESS(@"Device Alert\nConnecting...");
                
                [self.sticker connect];
            }
        }
    });
}

- (void)onConnectedSticker:(Sticker *)sticker
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.started)
        {
            if (self.sticker == sticker)
            {
                startedTime = [self getCurrentMilliTime];
                
                [sticker alert];
                
                HIDE_PROGRESS_WITH_SUCCESS(@"Device Alert\nAlerting...");
                
                [self performSelector:@selector(onFinishedPaging) withObject:nil afterDelay:4.f];
            }
        }
    });
}

- (void)onDisconnectedSticker:(Sticker *)sticker
{
    //
}



#pragma mark - sticker manager delegate
- (void)stickerManager:(StickerManager *)stickerManager didDiscoverSticker:(Sticker *)sticker
{
    //
}

- (void)stickerManager:(StickerManager *)stickerManager didGetSidForSticker:(Sticker *)sticker sid:(int)sid
{
    if (self.equipment == nil)
        return;
    
    if (sticker.sid == [self.equipment.sticknfind_id intValue])
    {
        [self onFoundSticker:sticker];
    }
}

#pragma mark - sticker delegate
- (void)sticker:(Sticker *)sticker didStateChanged:(StickerState)state
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        switch (state) {
            case StickerStateConnected:
                [self onConnectedSticker:sticker];
                break;
                
            case StickerStateConnecting:
                startedTime = [self getCurrentMilliTime];
                break;
                
            case StickerStateDisconnected:
                break;
                
            case StickerStateUpdating:
                break;
                
            default:
                break;
        }
    });
}

#pragma mark - utility
- (long)getCurrentMilliTime
{
    struct timeval time;
    gettimeofday(&time, NULL);
    long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    return millis;
}


@end
