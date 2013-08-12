//
//  LBMGTourLibraryDetailTBVCell.h
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGTourLibraryDetailTBVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *tourNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourAddress;
@property (strong, nonatomic) NSString *tourName;

@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic) BOOL downloading;
@property (weak, nonatomic) NSNumber *tourID;

@end
