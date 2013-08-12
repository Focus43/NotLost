//
//  LBMGAroundMeCategoryCell.m
//  Tours
//
//  Created by Alan Smithee on 5/22/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAroundMeCategoryCell.h"
#import "UAPush.h"

NSString const *favoritesUpdatedNotification = @"LBMGFavoritesUpdatedNotification";

@implementation LBMGAroundMeCategoryCell

- (void)setTourName:(NSString *)aTourName
{
    if (_tourName != aTourName) {
        _tourName = aTourName;
        self.tourNameLabel.text = aTourName;
//        if ([LBMGUtilities isCatgegoryFavorite:_tourName ofCategory:self.category]) {
//            self.favoriteButton.selected = YES;
//        } else {
//            self.favoriteButton.selected = NO;
//        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither_on"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither_on"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"menu_tcell_slither"];
    }
}

- (IBAction)favoriteButtonTouched:(id)sender {
    
    self.favoriteButton.selected = !self.favoriteButton.selected;
    
    NSString *tagString;
    if (self.subCategoryID) {
        tagString = [NSString stringWithFormat:@"listingsubcat_favorite-%@",[self.subCategoryID stringValue]];
    } else {
        tagString = [NSString stringWithFormat:@"listingcategory_favorite-%@",[self.categoryID stringValue]];
    }
    DLog(@"%@", tagString);
    
    if (self.favoriteButton.selected) {
        [LBMGUtilities saveFavoriteByArea:self.areaName andCategory:self.categoryName andSubCategory:self.subCategoryName];
        
        [[UAPush shared] addTagToCurrentDevice:tagString];
        [[UAPush shared] updateRegistration];
    } else {
        [LBMGUtilities deleteFavoriteByArea:self.areaName andCategory:self.categoryName andSubCategory:self.subCategoryName];
        
        [[UAPush shared] removeTagFromCurrentDevice:tagString];
        [[UAPush shared] updateRegistration];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LBMGFavoritesUpdatedNotification" object:nil];
}
@end
