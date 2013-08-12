//
//  LBMGUserContentViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/8/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGUserContentVC : LBMGNoRotateViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *currentContent;
@property (strong, nonatomic) NSArray *mappedContent;
@property (strong, nonatomic) NSArray *content;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSNumber *tourID;

- (IBAction)backButtonPressed:(id)sender;

@end
