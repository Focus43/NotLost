//
//  LBMGCalendarMasterVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapItAdDelegates.h"

@class ArialBlackLabel;
@class LBMGDayView;

@interface LBMGCalendarMasterVC : LBMGNoRotateViewController <UITableViewDataSource, UITableViewDelegate, TapItInterstitialAdDelegate>

@property (strong, nonatomic) IBOutlet UIView *calenderViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *weekDayRangeLabel;
@property (weak, nonatomic) IBOutlet UIButton *weekBackButton;
@property (strong, nonatomic) IBOutletCollection(LBMGDayView) NSArray *dayViews;
@property (weak, nonatomic) IBOutlet ArialBlackLabel *monthLabel;
@property (weak, nonatomic) IBOutlet ArialBlackLabel *yearLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *dateLabels;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;

- (IBAction)daySelected:(UIButton *)dayButton;
- (IBAction)nextWeekButtonTouched:(id)sender;
- (IBAction)previousWeekButtonTouched:(id)sender;
- (IBAction)resetDateToNow;

@end
