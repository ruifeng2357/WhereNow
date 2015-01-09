//
//  AssignTagTableViewCell.h
//  WhereNow
//
//  Created by Admin on 12/6/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssignTagViewController.h"

@class AssignTagTableViewCell;

@interface AssignTagInfo : NSObject

@property(nonatomic) int checkmark;
@property(nonatomic) NSString *tagname;
@property(nonatomic) int signal;
@property(nonatomic) int minor;
@property(nonatomic) int major;
@property(nonatomic) NSString *uuid;

@end

@protocol AssignTagDelegate <NSObject>

@optional
-(void) didRefreshCell:(AssignTagTableViewCell *)cell;

@end

@interface AssignTagTableViewCell : UITableViewCell

@property (nonatomic, weak) AssignTagInfo *tagCell;
@property (nonatomic, weak) id<AssignTagDelegate> delegate;

@end
