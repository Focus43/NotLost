//
//  LBMGAroundMeChildTBVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBMGAroundMeMasterPageVC;

@interface LBMGAroundMeChildTBVC : LBMGNoRotateViewController

@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) NSArray *eventsArray;
@property (weak, nonatomic) IBOutlet UIView *maskingLayerView;

@property (weak, nonatomic) LBMGAroundMeMasterPageVC *masterPage;
@property (strong, nonatomic) NSIndexPath *currentlySelectedRow;

- (void)deselectCurrentRow;

@end
