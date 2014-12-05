//
//  UIManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "UIManager.h"
#import "PushTransitioningDelegate.h"

static PushTransitioningDelegate *_pushTransitioningDelegate = nil;

@implementation UIManager

+ (UIColor *)cellHighlightColor
{
    return [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
}

+ (UIModalTransitionStyle)detailModalTransitionStyle
{
    return UIModalTransitionStyleCrossDissolve;
}

+ (NSInteger)navbarStyle
{
    return UIBarStyleBlackTranslucent;
}

+ (UIColor *)navbarTintColor
{
    return [UIColor whiteColor];
}

+ (NSDictionary *)navbarTitleTextAttributes
{
    //return @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    //return @{NSForegroundColorAttributeName:[UIColor colorWithRed:199/25.0 green:37/255.0 blue:39/255.0 alpha:1.0]};
    
    // white
//    return @{NSForegroundColorAttributeName:[UIColor colorWithRed:255/25.0 green:255/255.0 blue:255/255.0 alpha:1.0]};
    
    // gray
    return @{NSForegroundColorAttributeName:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]};
}

+ (UIColor *)navbarBarTintColor
{
    //return [UIColor colorWithRed:197/255.0 green:0/255.0 blue:27/255.0 alpha:1.0];
    
    // white
    return [UIColor whiteColor];
    
    // red
    //return [UIColor colorWithRed:255/255.0 green:107/255.0 blue:108/255.0 alpha:1.0];
    
    // blue
    //return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
}

+ (UIColor *)navbarBorderColor
{
    return [UIColor colorWithRed:229/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
}

+ (UIBarButtonItem *)defaultBackButton:(id)target action:(SEL)action
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:target action:action];
    return backButton;
}

+ (id <UIViewControllerTransitioningDelegate>)pushTransitioingDelegate
{
    if (_pushTransitioningDelegate == nil)
        _pushTransitioningDelegate = [[PushTransitioningDelegate alloc] init];
    return _pushTransitioningDelegate;
}

@end
