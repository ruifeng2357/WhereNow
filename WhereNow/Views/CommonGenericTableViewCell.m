//
//  CommonGenericTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 08/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "CommonGenericTableViewCell.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "AppContext.h"
#import "UserContext.h"
#import "LocatingManager.h"

#define kButtonWidth        (75.0f)
#define kHeightForCell      (92.0f)

@interface CommonGenericTableViewCell ()

// for outlets
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblNumberOfNearby;
@property (nonatomic, weak) IBOutlet UILabel *lblNotes;
@property (nonatomic, weak) IBOutlet UIImageView *ivStatus;
@property (nonatomic, weak) IBOutlet UIImageView *ivTracking;

@property (nonatomic, weak) IBOutlet UIButton *btnFavorites;
@property (nonatomic, weak) IBOutlet UIButton *btnLocate;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightConstraintOfView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnFavorites;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnLocate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnDelete;

@end

@implementation CommonGenericTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bind:(Generic *)generic type:(CommonGenericsCellType)cellType
{
    self.generic = generic;
    
    self.cellType = cellType;
    
    self.lblName.text = generic.generic_name;
    self.lblNumberOfNearby.text = [NSString stringWithFormat:@"%d registered", (int)[generic.genericwise_equipment_count integerValue]];
    self.lblNotes.text = generic.status_message;
    
    // favourites icon
    if ([generic.isfavorites boolValue])
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    else
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon"] forState:UIControlStateNormal];
    
    NSMutableArray *arrayEquipments = [[ModelManager sharedManager] equipmentsForGeneric:self.generic withBeacon:YES];
    int nLocating = 0;
    int nUnlocating = 0;
    for (Equipment *equipment in arrayEquipments) {
        if ([equipment.islocating boolValue])
            nLocating++;
        else
            nUnlocating++;
    }
    
    if (nLocating == 0)
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon"] forState:UIControlStateNormal];
        self.ivTracking.hidden = YES;
    }
    else if (nUnlocating == 0)
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_located"] forState:UIControlStateNormal];
        self.ivTracking.hidden = NO;
    }
    else
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_halflocated"] forState:UIControlStateNormal];
        self.ivTracking.hidden = NO;
    }
    
    // set status image
    //[[ServerManager sharedManager] setImageContent:self.ivStatus urlString:self.generic.alert_icon];
    if ([self.generic.alert_icon_id intValue] == 0)
        self.ivStatus.image = [UIImage imageNamed:@"status_green"];
    else if ([self.generic.alert_icon_id intValue] == 1)
        self.ivStatus.image = [UIImage imageNamed:@"status_orange"];
    else
        self.ivStatus.image = [UIImage imageNamed:@"status_red"];
    
    _editor = NO;
    self.leftConstraintOfView.constant = 0.f;
    self.rightConstraintOfView.constant = 0.f;
    
    // buttons
    switch (cellType) {
        case CommonGenericsCellTypeSearch:
        case CommonGenericsCellTypeRecent:
        case CommonGenericsCellTypeNearme:
            self.leftConstraintOfBtnFavorites.constant = 0;
            self.btnFavorites.hidden = NO;
            self.leftConstraintOfBtnLocate.constant = kButtonWidth;
            self.btnLocate.hidden = NO;
            
            self.btnDelete.hidden = YES;
            break;
        case CommonGenericsCellTypeFavorites:
            self.leftConstraintOfBtnDelete.constant = 0;
            self.btnDelete.hidden = NO;
            self.leftConstraintOfBtnLocate.constant = kButtonWidth;
            self.btnLocate.hidden = NO;
            
            self.btnFavorites.hidden = YES;
        default:
            break;
    }
    
    [self.contentView layoutIfNeeded];
}

- (void)setEditor:(BOOL)editor
{
    [self setEditor:editor animate:YES];
}

-(void)setEditor:(BOOL)editor animate:(BOOL)animate
{
    if (editor == _editor)
        return;
    
    _editor = editor;
    
    if (_editor)
    {
        switch (self.cellType) {
            case CommonGenericsCellTypeSearch:
            case CommonGenericsCellTypeRecent:
            case CommonGenericsCellTypeNearme:
                self.leftConstraintOfView.constant = -kButtonWidth * 2;
                self.rightConstraintOfView.constant = kButtonWidth * 2;
                break;
            case CommonGenericsCellTypeFavorites:
                self.leftConstraintOfView.constant = -kButtonWidth * 2;
                self.rightConstraintOfView.constant = kButtonWidth * 2;
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

#pragma mark - actions
- (IBAction)onFavorite:(id)sender
{
    // set favorites flag
    self.generic.isfavorites = @(YES);
    [[ModelManager sharedManager] saveContext];
    
    [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGenericFavorite:)])
        [self.delegate onGenericFavorite:self.generic];
}

- (IBAction)onLocate:(id)sender
{

    [[LocatingManager sharedInstance] onLocatingGeneric:self.generic];

    int nLocating = 0;
    int nUnlocating = 0;
    NSMutableArray *arrayEquipments = [[ModelManager sharedManager] equipmentsForGeneric:self.generic withBeacon:YES];
    for (Equipment *equipment in arrayEquipments) {
        if ([equipment.islocating boolValue])
            nLocating++;
        else
            nUnlocating++;
    }
    
    if (nLocating == 0)
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon"] forState:UIControlStateNormal];
        self.ivTracking.hidden = YES;
    }
    else if (nUnlocating == 0)
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_located"] forState:UIControlStateNormal];
        self.ivTracking.hidden = NO;
    }
    else
    {
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_halflocated"] forState:UIControlStateNormal];
        self.ivTracking.hidden = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGenericLocate:)])
        [self.delegate onGenericLocate:self.generic];
}

- (IBAction)onDelete:(id)sender
{
    //[[ModelManager sharedManager].managedObjectContext deleteObject:self.generic];
    self.generic.isfavorites = @(NO);
    [[ModelManager sharedManager] saveContext];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGenericDelete:)])
        [self.delegate onGenericDelete:self.generic];
}

#pragma mark - utility
- (CGFloat)heightForCell
{
    return kHeightForCell;
}

@end
