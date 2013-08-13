//
//  LBMGNavTableVC.h
//  NotLost
//
//  Created by Stine Richvoldsen on 8/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//
//  Pretty much copying the tour library table view setup. Some of this could be refactored
//  into a parent table class with all the stuff htat is shared between the two.

#import <UIKit/UIKit.h>
#import "LBMGNoRotateViewController.h"

@class LBMGMainMasterPageVC;

@interface LBMGNavTableVC : LBMGNoRotateViewController

@property (strong, nonatomic) IBOutlet UITableView *navTableView;

@property (strong, nonatomic) IBOutlet UITableViewController *tableViewController;
@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) NSArray *navList;
@property (weak, nonatomic) IBOutlet UIView *maskingLayerView;

@property (weak, nonatomic) LBMGMainMasterPageVC *masterVC;
@property (strong, nonatomic) NSIndexPath *selectedRow;

@property (nonatomic) BOOL inSubview;


- (void)deselectCurrentRow;

@end
