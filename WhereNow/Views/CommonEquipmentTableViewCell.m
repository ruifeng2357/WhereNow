//
//  CommonEquipmentTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 08/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "CommonEquipmentTableViewCell.h"
#import "ServerManager.h"
#import "ModelManager.h"
#import "EquipmentImage.h"
#import "AppContext.h"
#import "UserContext.h"
#import "LocatingManager.h"
#import "LocatingManager.h"
#import "BackgroundTaskManager.h"

#define kButtonWidth    (75.0f)
#define kHeightForCell  (92.0f);

@interface CommonEquipmentTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblLocation;
@property (nonatomic, weak) IBOutlet UILabel *lblSn;

@property (nonatomic, weak) IBOutlet UIImageView *ivStatus;
@property (nonatomic, weak) IBOutlet UIImageView *ivImg;
@property (nonatomic, weak) IBOutlet UIImageView *ivTracking;

@property (nonatomic, weak) IBOutlet UIButton *btnFavorites;
@property (nonatomic, weak) IBOutlet UIButton *btnLocate;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnPage;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightConstraintOfView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnFavorites;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnLocate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnDelete;

@end

@implementation CommonEquipmentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self.btnDelete setBackgroundColor:[UIColor colorWithRed:(201/255.f) green:(58/255.f) blue:(38/255.f) alpha:1.0f]];
    [self.btnFavorites setBackgroundColor:[UIColor colorWithRed:(66/255.f) green:(186/255.f) blue:(79/255.f) alpha:1.0f]];
    [self.btnLocate setBackgroundColor:[UIColor colorWithRed:(239/255.f) green:(239/255.f) blue:(244/255.f) alpha:1.0f]];
}

- (void)bind:(Equipment *)equipment generic:(Generic *)generic type:(CommonEquipmentCellType)cellType
{
    self.equipment = equipment;
    self.generic = generic;
    self.cellType = cellType;
    
    self.lblName.text = [ModelManager getEquipmentName:equipment];
    
    // location name = parent location name + current location name
    if (![equipment.current_location_parent_name isEqualToString:@""])
        self.lblLocation.text = [NSString stringWithFormat:@"%@ %@", equipment.current_location_parent_name, equipment.current_location];
    else
        self.lblLocation.text = [NSString stringWithFormat:@"%@", equipment.current_location];
    
    self.lblSn.text = [NSString stringWithFormat:@"SN : %@", equipment.serial_no];
    
    // favourites icon
    if ([equipment.isfavorites boolValue])
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    else
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon"] forState:UIControlStateNormal];
    
    // near me icon
    if ([equipment.islocating boolValue])
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_located"] forState:UIControlStateNormal];
        self.ivTracking.hidden = NO;
    }
    else
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon"] forState:UIControlStateNormal];
        self.ivTracking.hidden = YES;
    }
    
    if (equipment == nil || equipment.current_location == nil || equipment.serial_no == nil)
        equipment = equipment;
    
    // set image
    //[[ServerManager sharedManager] setImageContent:self.ivImg urlString:equipment.equipment_file_location];
    [EquipmentImage setModelImageOfEquipment:_equipment toImageView:self.ivImg completed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self layoutIfNeeded];
        });
    }];
    
    
    // set status image
    if ([equipment.equipment_alert_icon_id intValue] == 0)
        self.ivStatus.image = [UIImage imageNamed:@"status_green"];
    else if ([equipment.equipment_alert_icon_id intValue] == 1)
        self.ivStatus.image = [UIImage imageNamed:@"status_orange"];
    else
        self.ivStatus.image = [UIImage imageNamed:@"status_red"];
    
    _editor = NO;
    
    self.leftConstraintOfView.constant = 0.f;
    self.rightConstraintOfView.constant = 0.f;
    
    switch (self.cellType) {
        case CommonEquipmentCellTypeSearch:
        case CommonEquipmentCellTypeRecent:
        
            self.leftConstraintOfBtnFavorites.constant = 0;
            self.btnFavorites.hidden = NO;
            self.leftConstraintOfBtnLocate.constant = kButtonWidth;
            self.btnLocate.hidden = NO;
            
            self.btnDelete.hidden = YES;
            self.btnPage.hidden = YES;
        
            break;
        case CommonEquipmentCellTypeNearme:
            if ([[BackgroundTaskManager sharedManager].arrayVicinityEquipments containsObject:self.equipment])
            {
                self.btnLocate.hidden = YES;
                self.btnDelete.hidden = YES;
                self.btnFavorites.hidden = YES;
                self.btnPage.hidden = NO;
            }
            else
            {
                self.leftConstraintOfBtnFavorites.constant = 0;
                self.btnFavorites.hidden = NO;
                self.leftConstraintOfBtnLocate.constant = kButtonWidth;
                self.btnLocate.hidden = NO;
                
                self.btnDelete.hidden = YES;
                self.btnPage.hidden = YES;
            }
            break;
            
        case CommonEquipmentCellTypeFavorites:
            if (self.generic == nil)
            {
                self.leftConstraintOfBtnDelete.constant = 0;
                self.btnDelete.hidden = NO;
                
                self.leftConstraintOfBtnLocate.constant = kButtonWidth;
                self.btnLocate.hidden = NO;
                
                self.btnPage.hidden = YES;
            }
            else
            {
                self.btnDelete.hidden = YES;
                
                self.leftConstraintOfBtnLocate.constant = 0;
                self.btnLocate.hidden = NO;
                
                self.btnPage.hidden = YES;
            }
            
            self.btnFavorites.hidden = YES;
            break;
        default:
            break;
    }
    
    
    
    [self layoutIfNeeded];
}

- (void)setEditor:(BOOL)editor
{
    [self setEditor:editor animate:YES];
}



- (void)setEditor:(BOOL)editor animate:(BOOL)animate
{
    if (editor == _editor)
        return;
    
    _editor = editor;
    
    if (_editor)
    {
        switch (self.cellType) {
            case CommonEquipmentCellTypeSearch:
            case CommonEquipmentCellTypeRecent:
                self.leftConstraintOfView.constant = -kButtonWidth * 2;
                self.rightConstraintOfView.constant = kButtonWidth * 2;
                break;
            case CommonEquipmentCellTypeNearme:
                if ([[BackgroundTaskManager sharedManager].arrayVicinityEquipments containsObject:self.equipment])
                {
                    self.leftConstraintOfView.constant = -kButtonWidth;
                    self.rightConstraintOfView.constant  = kButtonWidth;
                }
                else
                {
                    self.leftConstraintOfView.constant = -kButtonWidth * 2;
                    self.rightConstraintOfView.constant = kButtonWidth * 2;
                }
                break;
            case CommonEquipmentCellTypeFavorites:
                if (self.generic == nil)
                {
                    self.leftConstraintOfView.constant = -kButtonWidth * 2;
                    self.rightConstraintOfView.constant = kButtonWidth * 2;
                }
                else
                {
                    self.leftConstraintOfView.constant = -kButtonWidth;
                    self.rightConstraintOfView.constant = kButtonWidth;
                }

            default:
                break;
        }
    }
    else
    {
        self.leftConstraintOfView.constant = 0;
        self.rightConstraintOfView.constant = 0;
    }
    
    if (animate)
    {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.contentView layoutIfNeeded];
        }];
    }
    else
        [self.contentView layoutIfNeeded];
}

- (IBAction)onFavorite:(id)sender
{
    self.equipment.isfavorites = @(YES);
    [[ModelManager sharedManager] saveContext];
    
    [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentFavorite:)])
        [self.delegate onEquipmentFavorite:self.equipment];
}

- (IBAction)onLocate:(id)sender
{
    if ([self.equipment.islocating boolValue])
    {
        [[LocatingManager sharedInstance] cancelLocatingEquipment:self.equipment];
    }
    else
    {
        [[LocatingManager sharedInstance] locatingEquipment:self.equipment];
    }
    
    // near me icon
    if ([self.equipment.islocating boolValue])
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_located"] forState:UIControlStateNormal];
        self.ivTracking.hidden = NO;
    }
    else
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon"] forState:UIControlStateNormal];
        self.ivTracking.hidden = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentLocate:)])
        [self.delegate onEquipmentLocate:self.equipment];
}

- (IBAction)onDelete:(id)sender
{
    //[[ModelManager sharedManager].managedObjectContext deleteObject:self.equipment];
    self.equipment.isfavorites = @(NO);
    [[ModelManager sharedManager] saveContext];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentDelete:)])
        [self.delegate onEquipmentDelete:self.equipment];
    
}

- (IBAction)onPage:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentPage:)])
        [self.delegate onEquipmentPage:self.equipment];
}

#pragma mark - utility
- (CGFloat)heightForCell
{
    return kHeightForCell;
}

@end
