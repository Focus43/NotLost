//
//  LBMGAroundMeFeaturedCell.h
//  Tours
//
//  Created by Alan Smithee on 5/23/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGAroundMeFeaturedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *tourNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourAddress;
@property (strong, nonatomic) NSString *tourName;

@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) NSNumber *tourID;

@end
