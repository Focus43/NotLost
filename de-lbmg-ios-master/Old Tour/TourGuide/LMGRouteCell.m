//
//  LMGRouteCell.m
//  TourGuide
//
//  Created by Paul Warren on 9/5/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import "LMGRouteCell.h"

@implementation LMGRouteCell
@synthesize routeName;
@synthesize routeIcon;
@synthesize routeDescription;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
