//
//  AssignTagTableViewCell.m
//  WhereNow
//
//  Created by Admin on 12/6/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AssignTagTableViewCell.h"

@implementation AssignTagInfo

@end

@interface AssignTagTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;
@property (nonatomic, weak) IBOutlet UILabel *labelDeviceName;
@property (nonatomic, weak) IBOutlet UIImageView *imgSignal;

@end

@implementation AssignTagTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (int)getSignalValue:(int) _rssi
{
    int bars = 0;
    
    if (_rssi > -87)
    {
        bars = 0;
    }
    if (_rssi > -82)
    {
        bars = 1;
    }
    if (_rssi > -77)
    {
        bars = 2;
    }
    if (_rssi > -72)
    {
        bars = 3;
    }
    if (_rssi > -67)
    {
        bars = 4;
    }
    if (_rssi > -62)
    {
        bars = 5;
    }
    
    return bars;
}


-(void)setTagCell:(AssignTagInfo *) tagCell
{
    _tagCell = tagCell;
    
    if (_tagCell == nil)
    {
        self.imgSelected.image = [UIImage imageNamed:@"icon_checkmark_nonchecked"];
        [self.labelDeviceName setText:@""];
        self.imgSignal.image = [UIImage imageNamed:@"signal_0"];
        return;
    }
    else
    {
        int nChecked = tagCell.checkmark;
        if (nChecked == 0)
            self.imgSelected.image = [UIImage imageNamed:@"icon_checkmark_nonchecked"];
        else
            self.imgSelected.image = [UIImage imageNamed:@"icon_checkmark_checked"];
        
        self.labelDeviceName.text = tagCell.tagname;

        NSString* imgName = [NSString stringWithFormat:@"signal_%d", [self getSignalValue:tagCell.signal]];
        self.imgSignal.image = [UIImage imageNamed:imgName];
    }
    
    return;
}

@end
