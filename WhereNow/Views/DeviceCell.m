//
//  DeviceCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 15/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "DeviceCell.h"

@interface DeviceCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelDeviceName;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;

@end


@implementation DeviceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDeviceInfo:(NSDictionary *)deviceInfo
{
    _deviceInfo = deviceInfo;
    
    if (_deviceInfo == nil)
    {
        self.labelDeviceName.text = @"";
        self.btnRemove.hidden = YES;
    }
    else
    {
        NSString *deviceName = [_deviceInfo objectForKey:kDeviceListDeviceNameKey];
        if (deviceName == nil || deviceName.length == 0)
            self.labelDeviceName.text = @"Device";
        else
            self.labelDeviceName.text = deviceName;
        self.btnRemove.hidden = NO;
    }
}

- (IBAction)onRemove:(id)sender
{
    if (self.delegate)
        [self.delegate didCellRemoved:self];
}

@end
