//
//  LBMGTourLibraryChildTBVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TourList;
@class LBMGTourLibraryMasterPageVC;

@interface LBMGTourLibraryChildTBVC : LBMGNoRotateViewController

@property (strong, nonatomic) IBOutlet UITableView *toursTableView;

@property (strong, nonatomic) IBOutlet UITableViewController *tableViewController;
@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) TourList *tourList;
@property (weak, nonatomic) IBOutlet UIView *maskingLayerView;

@property (weak, nonatomic) LBMGTourLibraryMasterPageVC *masterVC;
@property (strong, nonatomic) NSIndexPath *selectedRow;

@property (nonatomic) float userLatitude;
@property (nonatomic) float userLongitude;

@property (nonatomic) BOOL inSubview;


- (void)deselectCurrentRow;

@end
