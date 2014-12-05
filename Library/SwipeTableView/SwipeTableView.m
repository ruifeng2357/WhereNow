//
//  SwipeTableView.m
//  Knotable
//
//  Created by backup on 13-12-26.
//
//

#import "SwipeTableView.h"

#import <objc/runtime.h>

#define screenWidth() (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)


const static char * kYFJLeftSwipeDeleteTableViewCellIndexPathKey = "YFJLeftSwipeDeleteTableViewCellIndexPathKey";

@interface UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPath;

@end

@implementation UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, kYFJLeftSwipeDeleteTableViewCellIndexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)indexPath {
    id obj = objc_getAssociatedObject(self, kYFJLeftSwipeDeleteTableViewCellIndexPathKey);
    if([obj isKindOfClass:[NSIndexPath class]]) {
        return (NSIndexPath *)obj;
    }
    return nil;
}

@end

@interface SwipeTableView() {
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    
    NSIndexPath * _editingIndexPath;
}

@end

@implementation SwipeTableView


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        //
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)initControls
{
    _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_leftGestureRecognizer];
    
    _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _rightGestureRecognizer.delegate = self;
    _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:_rightGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
  
    
    //[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // drawing code
 }
 */


- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell {
    
    NSIndexPath *recalcedIndexPath = indexPath;
    if(editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [self cellForRowAtIndexPath:_editingIndexPath];
            recalcedIndexPath = [self setEditingNo:_editingIndexPath cell:editingCell recalcIndexPath:indexPath];
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    if(editing) {
        _editingIndexPath = recalcedIndexPath;
    } else {
        _editingIndexPath = nil;
    }
    
    if (self.swipeDelegate && [self.swipeDelegate respondsToSelector:@selector(setEditing:atIndexPath:cell:)]) {
        [self.swipeDelegate setEditing:editing atIndexPath:recalcedIndexPath cell:cell];
    }
}

- (NSIndexPath *)setEditingNo:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    [self removeGestureRecognizer:_tapGestureRecognizer];
     _editingIndexPath = nil;
    
    if (self.swipeDelegate && [self.swipeDelegate respondsToSelector:@selector(setEditing:atIndexPath:cell:recalcIndexPath:)]) {
        return [self.swipeDelegate setEditing:NO atIndexPath:indexPath cell:cell recalcIndexPath:recalcIndexPath];
    }
    else if (self.swipeDelegate && [self.swipeDelegate respondsToSelector:@selector(setEditing:atIndexPath:cell:)])
    {
        [self.swipeDelegate setEditing:NO atIndexPath:indexPath cell:cell];
        return recalcIndexPath;
    }
    return recalcIndexPath;
}


- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
    {
        if (gestureRecognizer == _leftGestureRecognizer)
            if (self.swipeDelegate)
                [self.swipeDelegate onSwipeLeft:self indexPath:nil];
        if (gestureRecognizer == _rightGestureRecognizer)
            if (self.swipeDelegate)
                [self.swipeDelegate onSwipeRight:self indexPath:nil];
        return;
    }
    
    if(![self.dataSource tableView:self canEditRowAtIndexPath:indexPath]) {
        return;
    }
    
    if (gestureRecognizer == _leftGestureRecognizer && [_editingIndexPath isEqual:indexPath])
    {
        if (self.swipeDelegate)
        {
            [self.swipeDelegate onSwipeLeft:self indexPath:indexPath];
            return;
        }
    }
    
    if (gestureRecognizer == _rightGestureRecognizer && ![_editingIndexPath isEqual:indexPath])
    {
        if (self.swipeDelegate)
        {
            [self.swipeDelegate onSwipeRight:self indexPath:indexPath];
            return;
        }
    }
    
    if(gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(_editingIndexPath) {
        
        UITableViewCell * cell = [self cellForRowAtIndexPath:_editingIndexPath];
        
        if (self.swipeDelegate && [self.swipeDelegate respondsToSelector:@selector(canCloseEditingOnTap:atIndexPath:)])
        {
            NSIndexPath *tappedIndexPath = [self cellIndexPathForGestureRecognizer:_tapGestureRecognizer];
            if ([self.swipeDelegate canCloseEditingOnTap:self atIndexPath:tappedIndexPath])
                [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        }
        else
        {
            [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        }
    }
}

- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    UIView * view = gestureRecognizer.view;
    if(![view isKindOfClass:[UITableView class]]) {
        return nil;
    }
    
    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [self indexPathForRowAtPoint:point];
    return indexPath;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _leftGestureRecognizer || gestureRecognizer == _rightGestureRecognizer)
        return YES; // Recognizers of this class are the first priority
    else if (gestureRecognizer == _tapGestureRecognizer)
    {
        NSIndexPath *tappedIndexPath = [self cellIndexPathForGestureRecognizer:_tapGestureRecognizer];
        if (self.swipeDelegate && [self.swipeDelegate respondsToSelector:@selector(canCloseEditingOnTap:atIndexPath:)])
        {
            if ([self.swipeDelegate canCloseEditingOnTap:self atIndexPath:tappedIndexPath])
                return YES;
            else
                return NO;
        }
        else
            return YES;
        
    }
    return YES;
}

- (void)reloadData
{
    if (_editingIndexPath != nil)
    {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    _editingIndexPath = nil;

    [super reloadData];
    
}

@end

