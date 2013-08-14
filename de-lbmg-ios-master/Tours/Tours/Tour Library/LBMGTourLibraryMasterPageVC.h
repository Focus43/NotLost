//
//  LBMGTourLibraryMasterPageVC.h
//  Tours
//
//  Created by Alan Smithee on 3/27/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TapItAdDelegates.h"

@class TourList;

@interface LBMGTourLibraryMasterPageVC : LBMGNoRotateViewController <UIScrollViewDelegate, TapItInterstitialAdDelegate>

@property (strong, nonatomic) IBOutlet UIView *maskingLayerView;
@property (strong, nonatomic) IBOutlet UIScrollView *pagedScrollView;
@property (weak, nonatomic) IBOutlet UIButton *yourLibraryButton;
@property (weak, nonatomic) IBOutlet UIButton *RefreshButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *lastRefreshTime;
@property (nonatomic, strong) NSTimer *dataRefreshTimer;

@property (strong, nonatomic) TourList *tourList;

- (IBAction)yourLibraryTouched:(id)sender;
- (IBAction)refreshTouched:(id)sender;
- (void)getData;
- (void)removeRefreshTimer;

@end
