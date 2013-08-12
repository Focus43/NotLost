//
//  LBMGPhotoDetailCell.h
//  Tours
//
//  Created by Alan Smithee on 4/5/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBMGPhotoDetailVC.h"

@interface LBMGPhotoDetailCell : UICollectionViewCell <UIScrollViewDelegate>
@property (strong, nonatomic) id<LBMGPhotoDetailProtocol> delegate;
@property (strong, nonatomic) UIImage *currentImage;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIView *labelContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString *imagePath;

@property (nonatomic) int scale;
@property (nonatomic) BOOL singleTapped;

- (void)configureZoom;
- (void)loadWebImageIfNeeded;

@end
