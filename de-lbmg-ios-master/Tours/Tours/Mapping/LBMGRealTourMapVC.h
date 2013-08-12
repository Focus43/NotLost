//
//  LBMGRealTourMapVC.h
//  Tours
//
//  Created by Alan Smithee on 4/11/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBMGBaseTourMapVC.h"

@class Route;

@interface LBMGRealTourMapVC : LBMGBaseTourMapVC

// Outlets for GuideToTourView
@property (weak, nonatomic) IBOutlet UIView *guideToTourView;
@property (strong, nonatomic) NSString *address;

@property (weak, nonatomic) IBOutlet UIButton *virtualTourButton;

// begin tour view outlets
@property (weak, nonatomic) IBOutlet UIView *beginTourView;
@property (weak, nonatomic) IBOutlet UILabel *beginTourTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *beginTourDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *takeMeThereButton;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;

@property (nonatomic) BOOL locationSetup;
@property (nonatomic) BOOL tourStarted;
@property (nonatomic) BOOL atStartPoint;

- (IBAction)guideToTourButtonPressed:(id)sender;
- (IBAction)switchToVirtualTourButtonPressed:(id)sender;
- (IBAction)beginTourButtonPressed:(id)sender;
- (IBAction)skipGuidance;

@end
