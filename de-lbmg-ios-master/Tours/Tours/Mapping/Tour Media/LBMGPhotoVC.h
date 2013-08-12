//
//  LBMGPhotoViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourData.h"

@interface LBMGPhotoVC : LBMGNoRotateViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSNumber *tourID;
@property (nonatomic, strong) NSArray *currentPhotos;
@property (nonatomic, strong) NSArray *photoData;
@property (nonatomic, strong) TourData *tourData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) BOOL pushedToDetail;

- (IBAction)backButtonPressed:(id)sender;

@end
