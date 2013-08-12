//
//  LBMGCurrentTour.m
//  Tours
//
//  Created by Alan Smithee on 4/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGCurrentTour.h"
#import "LBMGUtilities.h"
#import "Tour.h"
#import "TourPoint.h"
#import "PoiPoint.h"

@implementation LBMGCurrentTour

- (void)loadAndBuildData {
    [self loadData];
    [self loadRoute];
   if (self.isRouteBasedTour && self.route.tourPoints.count > 0) {
        [self calculateAndStoreCourse];
    }
    

    self.touchedPoints = [[NSMutableArray alloc] initWithArray:[LBMGUtilities getTouchedPoisForTour:self.tourID]];
    if (!([self.touchedPoints count] > 0)) {
        [self clearTouchPoints];
    }
    
    self.lastPointPassedIndex = -1;
}

-(void)loadData
{
    TourData *currentTour = [LBMGUtilities getTourDataForTour:self.tourID];
    self.routeData = currentTour;
    self.isRouteBasedTour = [self.routeData.routeBased boolValue];
    self.route = self.routeData.route;
}

// creates the route (MKPolyline) overlay
-(void)loadRoute
{
    MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
	
	// create a c array of points.
	MKMapPoint *pointArr = malloc(sizeof(MKMapPoint) * self.route.tourPoints.count);
	
	for(int idx = 0; idx < self.route.tourPoints.count; idx++)
	{
		TourPoint *coords = [self.route.tourPoints objectAtIndex:idx];
        
		CLLocationDegrees latitude  = [coords.latitude doubleValue];
		CLLocationDegrees longitude = [coords.longitude doubleValue];
        
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
		// adjust the bounding box
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
		pointArr[idx] = point;
	}
	
	// create the polyline based on the array of points.
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:self.route.tourPoints.count];
    
    CGPoint area = CGPointMake(northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
	self.routeRect = MKMapRectMake(southWestPoint.x-area.x/2, southWestPoint.y-area.y/2, area.x*2, area.y*2);
    
	free(pointArr);
}

// calculates the course to a point from the previous for out of bounds rules
- (void)calculateAndStoreCourse {
    
    ((TourPoint *)[self.route.tourPoints objectAtIndex:0]).directionFromPreviousPoint = -1.0;
    
    for (int i = 1; i < [self.route.tourPoints count]; i++) {
        CLLocationDegrees fromLatitude = [((TourPoint *)[self.route.tourPoints objectAtIndex:(i-1)]).latitude doubleValue];
        CLLocationDegrees fromLongitude = [((TourPoint *)[self.route.tourPoints objectAtIndex:(i-1)]).longitude doubleValue];
        CLLocationCoordinate2D fromLocation = CLLocationCoordinate2DMake(fromLatitude, fromLongitude);
        
        CLLocationDegrees toLatitude = [((TourPoint *)[self.route.tourPoints objectAtIndex:i]).latitude doubleValue];
        CLLocationDegrees toLongitude = [((TourPoint *)[self.route.tourPoints objectAtIndex:i]).longitude doubleValue];
        CLLocationCoordinate2D toLocation = CLLocationCoordinate2DMake(toLatitude, toLongitude);
        
        float course = [self calculateCourseFromLocation:fromLocation toLocation:toLocation];
        ((TourPoint *)[self.route.tourPoints objectAtIndex:i]).directionFromPreviousPoint = course;
    }
}

#pragma mark - Calculation Functions
// calculates the course between two points
- (double)calculateCourseFromLocation:(CLLocationCoordinate2D)fromLocation toLocation:(CLLocationCoordinate2D)toLocation {
    double fromLatitude = [self radiansFromDegrees:fromLocation.latitude];
    double fromLongitude = [self radiansFromDegrees:fromLocation.longitude];
    
    double toLatitude = [self radiansFromDegrees:toLocation.latitude];
    double toLongitude = [self radiansFromDegrees:toLocation.longitude];
    
    double longitudinalDistance = toLongitude - fromLongitude;
    
    double y = sin(longitudinalDistance) * cos(toLatitude);
    double x = cos(fromLatitude) * sin(toLatitude) - sin(fromLatitude) * cos(toLatitude) * cos(longitudinalDistance);
    double course = atan2(y, x);
    
    double degrees = [self degreesFromRadians:course];
    
    if (degrees < 0)
        degrees = degrees + 360;
    
    return degrees;
}

- (double)radiansFromDegrees:(double)degrees
{
    return degrees * (M_PI / 180.0);
}

- (double)degreesFromRadians:(double)radians
{
    return radians * (180.0 / M_PI);
}

- (void)clearTouchPoints {
    
    self.touchedPoints = [[NSMutableArray alloc] initWithCapacity:self.route.poiPoints.count];
    for (PoiPoint *way in self.route.poiPoints) {
        [self.touchedPoints addObject:[NSNumber numberWithBool:NO]];
    }
}

@end
