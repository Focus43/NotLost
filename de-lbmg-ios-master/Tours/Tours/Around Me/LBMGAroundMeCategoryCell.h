//
//  LBMGAroundMeCategoryCell.h
//  Tours
//
//  Created by Alan Smithee on 5/22/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGAroundMeCategoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *tourNameLabel;
@property (strong, nonatomic) NSString *tourName;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (copy, nonatomic) NSString *areaName;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *subCategoryName;
@property (copy, nonatomic) NSNumber *categoryID;
@property (copy, nonatomic) NSNumber *subCategoryID;

- (IBAction)favoriteButtonTouched:(id)sender;

@end
