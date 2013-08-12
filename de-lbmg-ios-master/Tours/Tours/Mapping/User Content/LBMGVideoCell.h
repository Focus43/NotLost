//
//  LBMGVideoCell.h
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGVideoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highlightedVideoImageView;

- (void)setCurrent:(BOOL)current;

@end
