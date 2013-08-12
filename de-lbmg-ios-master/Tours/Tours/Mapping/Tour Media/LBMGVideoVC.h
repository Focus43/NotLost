//
//  LBMGVideoViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/10/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourData.h"

@interface LBMGVideoVC : LBMGNoRotateViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSNumber *tourID;
@property (nonatomic, strong) NSArray *currentVideos;
@property (nonatomic, strong) NSArray *videoData;
@property (nonatomic, strong) TourData *tourData;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


- (IBAction)backButtonPressed:(id)sender;

@end
