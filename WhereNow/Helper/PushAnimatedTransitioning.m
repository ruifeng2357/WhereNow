//
//  PushAnimatedTransitioning.m
//  WhereNow
//
//  Created by Xiaoxue Han on 07/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "PushAnimatedTransitioning.h"

static NSTimeInterval const DEAnimatedTransitionDuration = 0.3f;

@interface UIViewController (transitioningcontext)

- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

@end

@implementation UIViewController (transitioningcontext)

- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        NSString *key = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] == self ? UITransitionContextFromViewKey : UITransitionContextToViewKey;
        return [transitionContext viewForKey:key];
    } else {
        return self.view;
    }
#else
    return self.view;
#endif
}

@end

@implementation PushAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView;
    UIView *fromView;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromView = [fromViewController viewForTransitionContext:transitionContext];
    toView = [toViewController viewForTransitionContext:transitionContext];

    UIView *container = [transitionContext containerView];
    
    if (self.reverse) {
        [container insertSubview:toView belowSubview:fromView];
        toView.transform = CGAffineTransformMakeTranslation(-fromView.frame.size.width, 0);
    }
    else {
        toView.transform = CGAffineTransformMakeTranslation(fromView.frame.size.width, 0);
        [container addSubview:toView];
    }
    
    [UIView animateKeyframesWithDuration:DEAnimatedTransitionDuration delay:0 options:0 animations:^{
        if (self.reverse) {
            fromView.transform = CGAffineTransformMakeTranslation(fromView.frame.size.width, 0);
            toView.transform = CGAffineTransformIdentity;
        }
        else {
            toView.transform = CGAffineTransformIdentity;
            fromView.transform = CGAffineTransformMakeTranslation(-fromView.frame.size.width/3, 0);
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return DEAnimatedTransitionDuration;
}



@end
