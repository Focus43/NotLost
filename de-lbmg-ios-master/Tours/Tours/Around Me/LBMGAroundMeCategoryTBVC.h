//
//  LBMGAroundMeCategoryTBVC.h
//  Tours
//
//  Created by Alan Smithee on 5/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBMGAroundMeMasterPageVC;
@class LBMGAroundMeChildTBVC;

@interface LBMGAroundMeCategoryTBVC :LBMGNoRotateViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *toursTableView;

@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) NSArray *places;
//@property (assign, nonatomic) int currentOpenIndex;
@property (weak, nonatomic) IBOutlet UIView *maskingLayerView;
@property (copy, nonatomic) NSString *areaName;

@property (weak, nonatomic) LBMGAroundMeMasterPageVC *masterPage;
@property (weak, nonatomic) LBMGAroundMeChildTBVC *previousPage;
@property (strong, nonatomic) NSString *oldTitleText;

@property (strong, nonatomic) NSIndexPath *selectedIndex;

- (IBAction)backButtonTouched:(id)sender;
- (void)deselectCurrentRow;

@end
