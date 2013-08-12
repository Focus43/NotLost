//
//  LBMGTourLibraryTBVCell.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGTourLibraryTBVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *tourNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourDistanceLabel;
@property (strong, nonatomic) NSString *tourName;
@property (strong, nonatomic) NSNumber *tourDistance;

- (void)animateForDuration:(CGFloat) duration;
@end
