//
//  LBMGAroundMeChildExpandingTVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBMGAroundMeMasterPageVC;
@class LBMGAroundMeCategoryTBVC;

@interface LBMGAroundMeChildExpandingTVC :LBMGNoRotateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *toursTableView;

@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) NSArray *places;
@property (assign, nonatomic) int currentOpenIndex;
@property (weak, nonatomic) IBOutlet UIView *maskingLayerView;
@property (copy, nonatomic) NSString *areaName;
@property (copy, nonatomic) NSString *categoryName;

@property (weak, nonatomic) LBMGAroundMeMasterPageVC *masterPage;
@property (weak, nonatomic) LBMGAroundMeCategoryTBVC *previousPage;
@property (strong, nonatomic) NSString *oldTitleText;

- (IBAction)backButtonTouched:(id)sender;


@end
