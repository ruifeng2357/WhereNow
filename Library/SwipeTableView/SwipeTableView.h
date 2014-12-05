//
//  SwipeTableView.h
//  Knotable
//
//  Created by backup on 13-12-26.
//
//

#import <UIKit/UIKit.h>

@protocol SwipeTableViewDelegate <NSObject>

@required
- (void)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell;
- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath;
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)onSwipeRight:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)onSwipeLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface SwipeTableView : UITableView <UIGestureRecognizerDelegate>

- (void)initControls;

@property (weak, nonatomic) id<SwipeTableViewDelegate> swipeDelegate;
- (void)tapped:(UIGestureRecognizer *)gestureRecognizer;

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell;
- (void)reloadData;

@end