//
//  LBMGNavTableCell.h
//  NotLost
//
//  Created by Stine Richvoldsen on 8/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGNavTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *navigationLabel;
@property (strong, nonatomic) NSString *navigationString;

- (void)animateForDuration:(CGFloat)duration forVisibility:(BOOL)isVisible;

@end
