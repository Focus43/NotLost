//
//  LBMGCalendarEventCell.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGCalendarEventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *personalContentView;

@property (weak, nonatomic) IBOutlet UIView *otherContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *personalItemLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIcon;

@end
