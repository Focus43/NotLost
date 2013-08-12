//
//  LBMGTourEndViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/23/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBMGTourTypeVC;

@interface LBMGTourEndVC : LBMGNoRotateViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UITableView *featuredLinksTableView;
@property (strong, nonatomic) LBMGTourTypeVC *tourMC;
@property (weak, nonatomic) IBOutlet UILabel *tourNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourDetailsLabel;

@property (strong, nonatomic) NSString *tourName;
@property (strong, nonatomic) NSString *detailText;
@property (weak, nonatomic) IBOutlet UIView *tourCompletedContainer;
@property (assign, nonatomic) BOOL tourComplete;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;

@property (strong, nonatomic) NSArray *featuredLinksArray;

- (IBAction)homeButtonTouched:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

@end
