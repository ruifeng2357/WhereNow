//
//  PushTransitioningDelegate.m
//  WhereNow
//
//  Created by Xiaoxue Han on 07/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "PushTransitioningDelegate.h"
#import "PushAnimatedTransitioning.h"

@implementation PushTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    PushAnimatedTransitioning *transitioning = [PushAnimatedTransitioning new];
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    PushAnimatedTransitioning *transitioning = [PushAnimatedTransitioning new];
    transitioning.reverse = YES;
    return transitioning;
}

@end
