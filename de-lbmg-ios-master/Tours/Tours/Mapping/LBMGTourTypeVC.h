//
//  LBMGTourTypeViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/10/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourPlace.h"
#import "TourDetail.h"
#import "LBMGCurrentTour.h"
#import "LBMGVirtualTourMapVC.h"
#import "LBMGRealTourMapVC.h"
#import "LBMGTourEndVC.h"

@interface LBMGTourTypeVC : LBMGNoRotateViewController
@property (strong, nonatomic) NSNumber *tourID;
@property (strong, nonatomic) TourPlace *place;
@property (strong, nonatomic) TourDetail *tourDetail;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourDetailsLabel;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIButton *virtualTourButton;
@property (weak, nonatomic) IBOutlet UIButton *realTourButton;

@property (strong, nonatomic) LBMGCurrentTour *currentTour;
@property (strong, nonatomic) LBMGVirtualTourMapVC *virtualTour;
@property (strong, nonatomic) LBMGRealTourMapVC *realTour;
@property (strong, nonatomic) LBMGTourEndVC *tourEnd;

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

// constraints on sliding in rows
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBarLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailBarLeadingSpaceConstraint;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)virtualTourButtonPressed:(id)sender;
- (IBAction)realTimeTourButtonPressed:(id)sender;

- (void)switchToRealTimeTour;
- (void)switchToVirtualTour;
- (void)goToTourEndView:(BOOL)complete;
- (void)popWithCompletionBlock:(void (^)(BOOL))block;

@end
