//
//  CommonLocationTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 09/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "CommonLocationTableViewCell.h"

#define kHeightForCell      (64.0f)

@interface CommonLocationTableViewCell () {
    //
}

@property (nonatomic, weak) IBOutlet UILabel *lblLevel;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblCount;
@property (nonatomic, weak) IBOutlet UILabel *lblNote;


@end

@implementation CommonLocationTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bind:(GenericLocation *)genericLocation
{
    self.genericLocation = genericLocation;
    
    self.lblLevel.text = genericLocation.parent_location_name;
    self.lblName.text = genericLocation.location_name;
    self.lblCount.text = [NSString stringWithFormat:@"%d in area", [genericLocation.location_wise_equipment_count intValue]];
    self.lblNote.text = genericLocation.status_message;
    
    [self layoutIfNeeded];
}

- (void)setEditor:(BOOL)editor
{
    //
}

// utility
- (CGFloat)heightForCell
{
    return kHeightForCell;
}

@end
