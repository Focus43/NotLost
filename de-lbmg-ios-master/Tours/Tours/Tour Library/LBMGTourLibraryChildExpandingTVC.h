//
//  LBMGTourLibraryChildExpandingTVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBMGTourLibraryChildTBVC;
@class LBMGTourLibraryMasterPageVC;

@interface LBMGTourLibraryChildExpandingTVC :LBMGNoRotateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *toursTableView;

@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) NSArray *places;
@property (assign, nonatomic) int currentOpenIndex;
@property (weak, nonatomic) IBOutlet UIView *maskingLayerView;

@property (nonatomic) float userLatitude;
@property (nonatomic) float userLongitude;

@property (weak, nonatomic) LBMGTourLibraryMasterPageVC *masterVC;
@property LBMGTourLibraryChildTBVC *previousPage;


- (IBAction)backButtonTouched:(id)sender;


@end
