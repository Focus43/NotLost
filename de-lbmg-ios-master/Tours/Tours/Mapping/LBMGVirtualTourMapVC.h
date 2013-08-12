//
//  LBMGVirtualTourVC.h
//  Tours
//
//  Created by Alan Smithee on 4/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBMGBaseTourMapVC.h"
#import "XCRPointAnnotation.h"

@interface LBMGVirtualTourMapVC : LBMGBaseTourMapVC
@property (weak, nonatomic) IBOutlet UIView *virtualTourBeginView;
@property (strong, nonatomic) NSMutableArray *virtualTourPoints;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *realTourButton;

@property (strong, nonatomic) XCRPointAnnotation *userLocationAnnotation;
@property (nonatomic) BOOL tourStarted;
@property (nonatomic) int virtualPointPassedIndex;
@property (nonatomic) BOOL needToUpdateUserLocation;
@property (weak, nonatomic) IBOutlet UILabel *routeDescription;
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;

- (IBAction)beginButtonPressed:(id)sender;
- (IBAction)switchToRealTimeTourButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)previousButtonPressed:(id)sender;
- (IBAction)navButtonPressed:(id)sender;

@end
