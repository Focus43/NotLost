//
//  LBMGPhotoCell.h
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoFrameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *currentPhotoFrameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (void)setCurrent:(BOOL)current;

@end
