//
//  LBMGAroundMeFeaturedCell.m
//  Tours
//
//  Created by Alan Smithee on 5/23/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAroundMeFeaturedCell.h"

@implementation LBMGAroundMeFeaturedCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundImageView.image = [[UIImage imageNamed:@"inner_slither_highlight"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    } else {
        self.backgroundImageView.image = [[UIImage imageNamed:@"featured_ad_slither"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundImageView.image = [[UIImage imageNamed:@"inner_slither_highlight"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    } else {
        self.backgroundImageView.image = [[UIImage imageNamed:@"featured_ad_slither"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
}

@end
