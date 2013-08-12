//
//  LBMGTopToursNearYouTBVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourList.h"
#import <MapKit/MapKit.h>

@class LBMGYourLibraryTBVC;

@interface LBMGTopToursNearYouTBVC : LBMGNoRotateViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TourList *availableTours;
@property (strong, nonatomic) NSMutableArray *topToursNearYou;

@property (strong, nonatomic) LBMGYourLibraryTBVC *parentViewController;

- (void)createToursNearYouList;

@end
