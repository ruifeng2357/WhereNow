//
//  FoundEquipmentTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "FoundEquipmentTableViewCell.h"
#import "EquipmentImage.h"

@interface FoundEquipmentTableViewCell () <StickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ivImg;
@property (weak, nonatomic) IBOutlet UILabel *labelModel;
@property (weak, nonatomic) IBOutlet UILabel *labelSerial;
@property (weak, nonatomic) IBOutlet UILabel *labelLevel;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelState;
@property (weak, nonatomic) IBOutlet UIButton *btnAlert;

@end

@implementation FoundEquipmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEquipment:(Equipment *)equipment
{
    _equipment = equipment;
    [EquipmentImage setModelImageOfEquipment:equipment toImageView:self.ivImg completed:^(UIImage *image) {
        [self layoutIfNeeded];
    }];
    
    self.labelModel.text = equipment.model_name_no;
    self.labelSerial.text = [NSString stringWithFormat:@"SN: %@", equipment.serial_no];
    self.labelLevel.text = @"";
    if (equipment.current_location_parent_name != nil && equipment.current_location_parent_name.length > 0)
        self.labelLevel.text = equipment.current_location_parent_name;
    self.labelLocation.text = equipment.current_location;
    
    [self stickerStateChanged];
}

- (void)setSticker:(Sticker *)sticker
{
    _sticker = sticker;
    [self stickerStateChanged];
    
    if (sticker && sticker.state == StickerStateDisconnected)
        [sticker connect];
}

- (void)stickerStateChanged
{
    if (self.sticker == nil)
    {
        self.btnAlert.enabled = NO;
        self.labelState.text = @"finding equipment...";
        return;
    }
    
    self.sticker.delegate = self;
    
    switch (self.sticker.state)
    {
        case StickerStateConnected:
            self.labelState.text = @"connected";
            self.btnAlert.enabled = YES;
            break;
        case StickerStateConnecting:
            self.labelState.text = @"connecting...";
            self.btnAlert.enabled = NO;
            break;
        case StickerStateDisconnected:
            self.labelState.text = @"disconnected";
            self.btnAlert.enabled = NO;
            break;
        case StickerStateUpdating:
            self.labelState.text = @"firmware updating...";
            self.btnAlert.enabled = NO;
            break;
            
        default:
            break;
    }
}

#pragma mark - sticker delegate
- (void)sticker:(Sticker *)sticker didStateChanged:(StickerState)state
{
    if (self.sticker == sticker)
        [self stickerStateChanged];
}

- (IBAction)onAlert:(id)sender
{
    if (self.sticker)
        [self.sticker alert];
}

@end
