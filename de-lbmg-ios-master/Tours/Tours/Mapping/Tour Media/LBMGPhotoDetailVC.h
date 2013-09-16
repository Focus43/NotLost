//
//  LBMGPhotoDetailViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/5/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBMGPhotoDetailProtocol

- (void)singleTapped:(BOOL)showItems withDuration:(float)duration;

@end

@class LBMGPhotoDetailCell;

@interface LBMGPhotoDetailVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, LBMGPhotoDetailProtocol>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSString *photoDirectory;
@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) int currentPhoto;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic) int currentlyShowingIndex;

@property LBMGPhotoDetailCell *currentCell;
@property (nonatomic) BOOL singleTapped;

@property (nonatomic) BOOL isTutorial;

- (IBAction)exitButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;
- (void)singleTapped:(BOOL)showItems withDuration:(float)duration;

@end
