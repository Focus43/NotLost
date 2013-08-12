//
//  LBMGCurrentTour.h
//  Tours
//
//  Created by Alan Smithee on 4/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TourRoute.h"
#import "TourData.h"

@interface LBMGCurrentTour : NSObject

@property (strong, nonatomic) TourRoute *route;
@property (strong, nonatomic) TourData *routeData;
@property (strong, nonatomic) NSNumber *tourID;
@property (nonatomic) int lastPointPassedIndex;

@property (nonatomic, strong) MKPolyline* routeLine;
@property (assign, nonatomic) MKMapRect routeRect;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *touchedPoints;
@property (strong, nonatomic) NSMutableArray *userContent;
@property (nonatomic) BOOL personalOpen;
@property (nonatomic) BOOL isRouteBasedTour;

@property (nonatomic) BOOL isRealTour;

// map settings
@property (nonatomic) BOOL useMapSettings;
@property (nonatomic) MKCoordinateRegion mapRegion;
@property (nonatomic) CGPoint mapCenter;

- (void)loadAndBuildData;
- (double)calculateCourseFromLocation:(CLLocationCoordinate2D)fromLocation toLocation:(CLLocationCoordinate2D)toLocation;

@end
