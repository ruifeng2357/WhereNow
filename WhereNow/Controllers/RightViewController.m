//
//  RightViewController.m
//  WhereNow
//
//  Created by Admin on 12/18/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "RightViewController.h"
#import "ModelManager.h"


@interface RightViewController () <RightViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelDevicesInCount;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesInName;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesWithinName;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesWithinCount;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesRequestedCount;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesRequestedName;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesOutCount;
@property (weak, nonatomic) IBOutlet UILabel *labelDevicesOutName;


@end

@implementation RightViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[ModelManager sharedManager] initWithDelegate:self];
}

- (void) didGetDevicesInfo: (NSString *)regionName indevices:(NSString *) indevices withindevices:(NSString *) withindevices requesteddevices:(NSString *) requesteddevices outdevices:(NSString *)outdevices
{
    self.labelDevicesInCount.text = indevices;
    self.labelDevicesWithinCount.text = withindevices;
    self.labelDevicesRequestedCount.text = requesteddevices;
    self.labelDevicesOutCount.text = outdevices;
    
    self.labelDevicesInName.text = [NSString stringWithFormat:@"DEVICES IN %@", regionName];
    self.labelDevicesWithinName.text = [NSString stringWithFormat:@"DEVICES ROAMING WITHIN %@", regionName];
    self.labelDevicesOutName.text = [NSString stringWithFormat:@"DEVICES OUT OF %@", regionName];
    
    return;
}

@end
