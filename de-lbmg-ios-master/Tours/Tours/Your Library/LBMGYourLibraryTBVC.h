//
//  LBMGYourLibraryTBVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBMGTopToursNearYouTBVC.h"
#import "TourList.h"
#import <MapKit/MapKit.h>

@interface LBMGYourLibraryTBVC : LBMGNoRotateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *toursListTBLV;
@property (strong, nonatomic) IBOutlet UIView *topToursContainerView;
@property (strong, nonatomic) LBMGTopToursNearYouTBVC *topToursNearYouTBVC;

@property (strong, nonatomic) TourList *availableTours;

@property (nonatomic, strong) NSTimer *dataRefreshTimer;

- (IBAction)backButtonTouched:(id)sender;
- (void)fetchTourDetail:(TourDetail *)tour;
- (void)fetchYourTours;

@end
