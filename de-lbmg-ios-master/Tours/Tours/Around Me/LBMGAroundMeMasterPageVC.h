//
//  LBMGAroundMeMasterPageVCViewController.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapIt.h"

@interface LBMGAroundMeMasterPageVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *maskingLayerView;
@property (strong, nonatomic) IBOutlet UIScrollView *pagedScrollView;
@property (strong, nonatomic) IBOutlet UIView *searchViewContainer;
@property (weak, nonatomic) IBOutlet UITextField *searchTextView;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *clearSearchTextButton;
@property (retain, nonatomic) TapItBannerAdView *tapitAd;

- (IBAction)searchButtonTouched:(id)sender;
- (IBAction)closeSearchButtonPressed:(id)sender;
- (IBAction)clearTextButtonPressed:(id)sender;

@end
