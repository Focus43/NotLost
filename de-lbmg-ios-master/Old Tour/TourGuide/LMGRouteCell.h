//
//  LMGRouteCell.h
//  TourGuide
//
//  Created by Paul Warren on 9/5/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMGRouteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *routeName;
@property (weak, nonatomic) IBOutlet UIImageView *routeIcon;
@property (weak, nonatomic) IBOutlet UILabel *routeDescription;

@end
