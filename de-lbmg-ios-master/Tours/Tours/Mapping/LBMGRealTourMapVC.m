//
//  LBMGRealTourMapVC.m
//  Tours
//
//  Created by Alan Smithee on 4/11/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#define OUTLINE_POINT_RADIUS 30

#import "LBMGRealTourMapVC.h"
#import "TourPoint.h"
#import "MediaPoint.h"
#import "LBMGTourTypeVC.h"
#import "UAPush.h"
#import "PoiPoint.h"

@interface LBMGRealTourMapVC ()
- (void)zoomToShowCurrentAndNextLocation;
@end

@implementation LBMGRealTourMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showGuideToTourView];
    if (self.currentTour.isRouteBasedTour) {
        [self.mapView addOverlay:self.currentTour.routeLine];
    }    
    if (self.currentTour.lastPointPassedIndex > -1) {  // Tour already started
        [self hideGuideToTourView];
        self.messageLabel.text = ((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:self.currentTour.lastPointPassedIndex]).directionText;
    }
    else {
//        self.messageLabel.text = @"seeking Location...";
        self.messageLabel.text = @"";
    }
    
    self.beginTourTitleLabel.text = self.title;
    self.beginTourDescriptionTextView.text = self.description;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *storedIndex = [userDefaults objectForKey:[self.currentTour.tourID stringValue]];
    if (storedIndex) {
        self.currentTour.lastPointPassedIndex = [storedIndex intValue];
        [self beginTourButtonPressed:nil];
    }
    
//    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Taking out the virtual/real swap buttom
    [self.virtualTourButton setHidden:YES];
    
    if (!self.locationSetup) {
        [self setupLocationManagerAndMap];
        self.mapView.delegate = self;
        self.locationSetup = TRUE;
    }
    
    if (self.currentTour.lastPointPassedIndex > -1) {  // Tour already started
        // add zooming to next point and current location here
        [self zoomToShowCurrentAndNextLocation];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidUnload {
    [self setMessageLabel:nil];
    [self setDirectionsContainer:nil];
    [super viewDidUnload];
}

- (void)zoomToShowCurrentAndNextLocation
{
    
    CLLocationDegrees nextLatitude  = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:self.currentTour.lastPointPassedIndex+1]).latitude doubleValue];
    CLLocationDegrees nextLongitude = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:self.currentTour.lastPointPassedIndex+1]).longitude doubleValue];
    CLLocationCoordinate2D nextPoint = CLLocationCoordinate2DMake(nextLatitude, nextLongitude);
    MKMapPoint nextMapPoint = MKMapPointForCoordinate(nextPoint);
    
    CLLocationDegrees userLatitude = self.locationManager.location.coordinate.latitude;
    CLLocationDegrees userLongitude = self.locationManager.location.coordinate.longitude;
    CLLocationCoordinate2D userPoint = CLLocationCoordinate2DMake(userLatitude, userLongitude);
    MKMapPoint userMapPoint = MKMapPointForCoordinate(userPoint);
    
    
    MKMapRect mapRectangle = MKMapRectMake (fmin(nextMapPoint.x, userMapPoint.x),
                                            fmin(nextMapPoint.y, userMapPoint.y),
                                            fabs(nextMapPoint.x - userMapPoint.x),
                                            fabs(nextMapPoint.y - userMapPoint.y));
    
    // calculating padding to get a zoom level that is zoomed out enough to still get mao images
    CGFloat xpad = (self.mapView.bounds.size.width - fabs(nextMapPoint.x - userMapPoint.x)) / 2;
    CGFloat ypad = (self.mapView.bounds.size.height - fabs(nextMapPoint.y - userMapPoint.y)) / 2;
    // make sure we still get padding for icons/nav bars
    if (xpad < 21) xpad = 21;
    if (ypad < 90) ypad = 90;
    
    // accounting for size of icons and top and bottom bar here
    // plus adding a little extra, (90, 21, 60, 21), to account for the user's current point needing time ot be exaclty calculated
    // That could of course, be unreliable... Maybe later we add code to map view delegate that uses userLocationVisible, and re-draws if NO.
    [self.mapView setVisibleMapRect:mapRectangle edgePadding:UIEdgeInsetsMake(ypad, xpad, ypad, xpad) animated:YES];
    
}

#pragma mark - Section functions
- (void)figureOutAndHighlightSectionForPoint:(TourPoint *)point {
    int sectionNum = 0;
    for (NSArray *section in self.sections) {
        NSInteger index = [section indexOfObject:point];
        if (index >= 0 && index < [self.sections count]) {
            self.navIndex = sectionNum;
            [self switchToNextSection];
            self.navIndex++;
        }
        sectionNum++;
    }
}

#pragma mark - Guide to Tour Functions
- (void)showGuideToTourView {
    [self.guideToTourView setHidden:NO];
    [self.backButton setHidden:NO];
    [self hideTourStartedElements];

}

- (void)hideGuideToTourView {
    [self.guideToTourView setHidden:YES];
    [self.backButton setHidden:YES];
    [self showTourStartedElements];
}

#pragma mark - Begin Tour Functions
- (void)showBeginTourView {
    [self.backButton setHidden:NO];
    [self.beginTourView setHidden:NO];
    [self hideTourStartedElements];
}

- (void)hideBeginTourView {
    [self.backButton setHidden:YES];
    [self.beginTourView setHidden:YES];
    [self showTourStartedElements];
}

#pragma mark - Start Tour UI Functions
- (void)hideTourStartedElements {
    [self.progressContainer setHidden:YES];
    [self.directionsContainer setHidden:YES];
    [self.virtualTourButton setHidden:YES];
    [self.homeButton setHidden:YES];
}

- (void)showTourStartedElements {
    [self.progressContainer setHidden:NO];
    [self.directionsContainer setHidden:NO];
    
//    [self.virtualTourButton setHidden:NO];
    // Taking out the virtual/real swap buttom
    [self.virtualTourButton setHidden:YES];
    
    [self.homeButton setHidden:NO];
}

#pragma mark - New Location Handlers
- (void)handleNewLocation:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.latitudeDataLabel setText:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude]];
    [self.longitudeDataLabel setText:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude]];
    [self.courseLabel setText:[NSString stringWithFormat:@"%f", newLocation.course]];
    
    if (newLocation)
    {
		// make sure the old and new coordinates are different
        if (!((oldLocation.coordinate.latitude == newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude == newLocation.coordinate.longitude))) {
            NSTimeInterval age = abs([newLocation.timestamp timeIntervalSinceNow]);
            if(age > 60){
                return;
            }
            
            if (signbit(newLocation.horizontalAccuracy)) {
                // Negative accuracy means an invalid or unavailable measurement
            }
            else {
                // Valid measurement.
                if (!self.tourStarted && [self isUserOnStart:newLocation] && !self.atStartPoint) {
                    [self hideGuideToTourView];
                    [self showBeginTourView];
                    self.atStartPoint = TRUE;
                }
                else if (self.tourStarted) {
                    if (self.currentTour.isRouteBasedTour) {
                        [self processNewLocation:newLocation];
                    } else {
                        [self processNoneRouteLocation:newLocation];
                    }
                    // TODO: shouldn't these 3 be called from the two above (if appropriate)?
                    [self processMediaLocation:newLocation];
                    [self processPOILocation:newLocation];
                    [self processPersonalContentLocation:newLocation];
                }
            }
        } else {
//            DLogS(@"Rejected Location=%@",newLocation);
        }
    }
}

- (IBAction)skipGuidance
{
    [self hideGuideToTourView];
    [self showBeginTourView];
    self.atStartPoint = TRUE;
    
    [self ZoomInOnCurrentLocationAndStart];    
}

- (void)ZoomInOnCurrentLocationAndStart
{
    TourPoint *point = [self.currentTour.route.tourPoints objectAtIndex:0];
    CLLocationDegrees pointLatitude  = [point.latitude doubleValue];
    CLLocationDegrees pointLongitude = [point.longitude doubleValue];
    CLLocationCoordinate2D pointCoord = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
    MKMapPoint mapPoint = MKMapPointForCoordinate(pointCoord);
    
    CLLocationCoordinate2D currentPoint = self.mapView.userLocation.coordinate;
    MKMapPoint currentMapPoint = MKMapPointForCoordinate(currentPoint);
   
    
    MKMapPoint northEastPoint = currentMapPoint;
    MKMapPoint southWestPoint = currentMapPoint;
    
    if (mapPoint.x > northEastPoint.x)
        northEastPoint.x = mapPoint.x;
    if(mapPoint.y > northEastPoint.y)
        northEastPoint.y = mapPoint.y;
    if (mapPoint.x < southWestPoint.x)
        southWestPoint.x = mapPoint.x;
    if (mapPoint.y < southWestPoint.y)
        southWestPoint.y = mapPoint.y;
    
    CGPoint area = CGPointMake(northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    MKMapRect sectionRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, area.x*1, area.y*1);
    
    // TODO: should add zoom level checking here
//    [self.mapView setVisibleMapRect:sectionRect animated:YES];
    [self.mapView setVisibleMapRect:sectionRect edgePadding:UIEdgeInsetsMake(90, 30, 90, 30) animated:YES];
}



- (BOOL)isUserOnStart:(CLLocation *)newLocation
{
    TourPoint *point = [self.currentTour.route.tourPoints objectAtIndex:0];
    CLLocationDegrees pointLatitude  = [point.latitude doubleValue];
    CLLocationDegrees pointLongitude = [point.longitude doubleValue];
    CLLocationCoordinate2D pointCoords = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
    float distFromPoint = MKMetersBetweenMapPoints(MKMapPointForCoordinate(pointCoords), MKMapPointForCoordinate(newLocation.coordinate));
    
    CGFloat radius = [point.radius floatValue];
    if (radius < 2.0) {
        radius = 15.0;   // Defensive..We always need a valid radius
    }
    if (!self.currentTour.isRouteBasedTour) {
        radius = 1000;
    }
    
    if (distFromPoint <= radius) {
        return YES;
    }
    return NO;
}

- (void)processNewLocation:(CLLocation *)newLocation
{
    // if the user is off the route
    if (self.currentTour.lastPointPassedIndex < 0 ||  ([self checkForOutOfArea:newLocation] && !self.withinPointRadius)) {
        DLogS(@"processOutOfAreaLocation");
        // since we're no longer within a radius, we can deselect all annotations
        [self deselectAllAnnotations];
        
        [self processOutOfAreaLocation:newLocation];
        
    } else {
        DLogS(@"processOnRouteLocation");
       [self processOnRouteLocation:newLocation];
    }
}

- (void)processNoneRouteLocation:(CLLocation *)newLocation
{
    
    for (int i = 0; i < [self.currentTour.route.tourPoints count]; i++) {
        TourPoint *point = [self.currentTour.route.tourPoints objectAtIndex:i];
        CLLocationDegrees pointLatitude  = [point.latitude doubleValue];
        CLLocationDegrees pointLongitude = [point.longitude doubleValue];
        CLLocationCoordinate2D pointCoords = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
        float distFromPoint = MKMetersBetweenMapPoints(MKMapPointForCoordinate(pointCoords), MKMapPointForCoordinate(newLocation.coordinate));
        
        double nrbCourseVariance = 80;
        double degree;
        if (point.directionTrigger && ![point.directionTrigger isEqualToString:@""]) {
            degree = [self degreesFromDirectionTrigger:point.directionTrigger];
        } else {
            degree = -1;
        }
        
        float lowerCourse = degree - nrbCourseVariance;
        float upperCourse = degree + nrbCourseVariance;
                
        // if the current location is within the bounds of the point and the course is within +/- 50 of the expected course for a given point
        // then that point is the new point
        if (distFromPoint <= [point.radius doubleValue] && (degree < 0 || (newLocation.course >= lowerCourse && newLocation.course <= upperCourse && newLocation.course >= 0))) {
            self.currentTour.lastPointPassedIndex = i;
            //            self.waypointLabel.text = [NSString stringWithFormat:@"%i", self.currentTour.lastPointPassedIndex];
            self.withinPointRadius = YES;
            // TODO: unnecessary call
            [self updateProgressBarIfRouteBased];
            [self activateWayPoint:point];
        }
        else if (distFromPoint <= [point.radius doubleValue] && self.currentTour.lastPointPassedIndex == -1 && i == 0) {
            // trigger the starting point!
            self.currentTour.lastPointPassedIndex = 0;
//            self.waypointLabel.text = [NSString stringWithFormat:@"%i", self.currentTour.lastPointPassedIndex];
            // TODO: unnecessary call
            [self updateProgressBarIfRouteBased];
            [self activateWayPoint:point];
        } else {
            // since we're no longer within a radius, we can deselect all annotations
            [self deselectAllAnnotations];
            // also make sure no point is currently set to open
            for (PoiPoint *point in self.currentTour.route.poiPoints) {
                point.isOpen = NO;
            }
        }
    }
}


- (void)processOutOfAreaLocation:(CLLocation *)newLocation
{
    // deselect any annotations taht might be open
//    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
//    if ( [selectedAnnotations count] > 0 ) {
//        for (XCRPointAnnotation *annotation in selectedAnnotations) {
//            [self.mapView deselectAnnotation:annotation animated:YES];
//            
//            PoiPoint *point = [self.currentTour.route.poiPoints objectAtIndex:[[self.mapView annotations] indexOfObject:annotation]];
//            point.isOpen = NO;
//        }
//        self.currentlySelectedAnnotation = NULL;
//    }
    
    if (self.currentTour.lastPointPassedIndex != -1)
        [self handleOutOfArea:newLocation];
    // check direction of travel
    // see if any of the points are hit with the right direction
    // if one is hit then use that as the new point
    
    DLog(@"Off Route");
    for (int i = 0; i < [self.currentTour.route.tourPoints count]; i++) {
        TourPoint *point = [self.currentTour.route.tourPoints objectAtIndex:i];
        CLLocationDegrees pointLatitude  = [point.latitude doubleValue];
        CLLocationDegrees pointLongitude = [point.longitude doubleValue];
        CLLocationCoordinate2D pointCoords = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
        float distFromPoint = MKMetersBetweenMapPoints(MKMapPointForCoordinate(pointCoords), MKMapPointForCoordinate(newLocation.coordinate));
        
        float lowerCourse = point.directionFromPreviousPoint - self.courseVariance;
        float upperCourse = point.directionFromPreviousPoint + self.courseVariance;
        
        // if the current location is within the bounds of the point and the course is within +/- 50 of the expected course for a given point
        // then that point is the new point
        if (distFromPoint <= [point.radius doubleValue] && newLocation.course >= lowerCourse && newLocation.course <= upperCourse && newLocation.course >= 0) {
            DLogS("Back on Route - %d", i);
            self.currentTour.lastPointPassedIndex = i;
            self.waypointLabel.text = [NSString stringWithFormat:@"%i", self.currentTour.lastPointPassedIndex];
            [self updateProgressBarIfRouteBased];
            [self activateWayPoint:point];
            
            if (self.currentTour.isRouteBasedTour) {
                [self figureOutAndHighlightSectionForPoint:point];
            }
        }
        else if (distFromPoint <= [point.radius doubleValue] && self.currentTour.lastPointPassedIndex == -1 && i == 0) {
            // trigger the starting point!
            self.currentTour.lastPointPassedIndex = 0;
            self.waypointLabel.text = [NSString stringWithFormat:@"%i", self.currentTour.lastPointPassedIndex];
            [self updateProgressBarIfRouteBased];
            [self activateWayPoint:point];
            self.messageLabel.text = @"";
            DLog(@"Triggered Start");
            
            if (self.currentTour.isRouteBasedTour) {
                [self figureOutAndHighlightSectionForPoint:point];
            }
        }
    }
}


- (void)processOnRouteLocation:(CLLocation *)newLocation {
    TFLog(@"in processOnRouteLocation and lastPointPassedIndex = %d", self.currentTour.lastPointPassedIndex);
    // not off route
    // check if user is at the next point
    if (self.currentTour.lastPointPassedIndex + 1 >=  self.currentTour.route.tourPoints.count) {
        return;
    }
    
    TourPoint *nextPoint = [self.currentTour.route.tourPoints objectAtIndex:(self.currentTour.lastPointPassedIndex + 1)];
    CLLocationDegrees fromLatitude  = [nextPoint.latitude doubleValue];
    CLLocationDegrees fromLongitude = [nextPoint.longitude doubleValue];
    CLLocationCoordinate2D nextPointCoords = CLLocationCoordinate2DMake(fromLatitude, fromLongitude);
    float distFromNext = MKMetersBetweenMapPoints(MKMapPointForCoordinate(nextPointCoords), MKMapPointForCoordinate(newLocation.coordinate));
    
    TourPoint *previousPoint = [self.currentTour.route.tourPoints objectAtIndex:self.currentTour.lastPointPassedIndex];
    CLLocationDegrees toLatitude  = [previousPoint.latitude doubleValue];
    CLLocationDegrees toLongitude = [previousPoint.longitude doubleValue];
    CLLocationCoordinate2D previousPointCoords = CLLocationCoordinate2DMake(toLatitude, toLongitude);
    
    float distTraveled = MKMetersBetweenMapPoints(MKMapPointForCoordinate(previousPointCoords), MKMapPointForCoordinate(newLocation.coordinate));
    self.courseEntryLabel.text = [NSString stringWithFormat:@"%f", nextPoint.directionFromPreviousPoint];
    // if the user is within the radius of the next point:
    double nextPointRadius = [nextPoint.radius doubleValue];
    if (nextPointRadius == 0) {
        nextPointRadius = OUTLINE_POINT_RADIUS;   // exception for outline point, large numbers here are acceptable but reduce Off Route detection accuracy;
    }
    if (distFromNext <= nextPointRadius) {
        self.withinPointRadius = TRUE;
        TFLog(@"Point Detected - %@", nextPoint.name);
        // sets the progress bar
        [self updateProgressBarIfRouteBased];
        
        self.currentTour.lastPointPassedIndex++;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInt:self.currentTour.lastPointPassedIndex]
                         forKey:[self.currentTour.tourID stringValue]];
        [userDefaults synchronize];
        //        [self markNextPoint];
        self.waypointLabel.text = [NSString stringWithFormat:@"%i", self.currentTour.lastPointPassedIndex];
        
//        [TestFlight passCheckpoint:@"found Next waypoint"];
        [self activateWayPoint:nextPoint];
//        [TestFlight passCheckpoint:[NSString stringWithFormat:@"Detected WayPoint - %@", nextPoint.name]];
    }
    else if (distTraveled >= [previousPoint.radius doubleValue] && self.withinPointRadius) {
        DLog(@"Left a radius");
        TFLog(@"last point - %d", self.currentTour.lastPointPassedIndex);
        self.withinPointRadius = FALSE;
        // since we're no longer within a radius, we can deselect all annotations
        [self deselectAllAnnotations];
    }
}

- (void)showPOIMessageForNRBTours:(PoiPoint *)currentPOI {
    if (!self.currentTour.isRouteBasedTour && ![self.messageLabel.text isEqualToString:currentPOI.labelText])
        self.messageLabel.text = currentPOI.labelText;
}

- (void)deselectAllAnnotations
{    
//    if (!self.annotationSelected) return;
//    TFLog(@"deselectAllAnnotations");
//    for (MKAnnotationView *av in [self.mapView annotations]) {
//        [self.mapView deselectAnnotation:av animated:YES];
//        self.annotationSelected = NO;
//    }
}

#pragma mark - Location Helpers
// handles the activation of the media for a waypoint
- (void)activateWayPoint:(TourPoint *)point {
    [super activateWayPoint:point];
    if ([point.type isEqualToString:@"NavigationPoint"] && point.directionText) {
        self.directionImageView.hidden = YES;
        self.messageLabel.text = point.directionText;
        [self blinkBackgroundColor:[UIColor colorWithRed:1.000 green:0.741 blue:0.180 alpha:1.000] ForView:self.messageLabel];
    }

    if (point.icon) {
        self.directionImageView.hidden = NO;
        [self.directionImageView setImage:[UIImage imageNamed:point.icon]];
        self.messageLabel.text = point.directionText;
    }
    if (self.currentTour.lastPointPassedIndex >= [self.currentTour.route.tourPoints count] - 1) {
        self.directionImageView.hidden = YES;
    }
    
    if ([point.type isEqualToString:@"PoiPoint"]) {
        if (self.currentTour.isRouteBasedTour) {
            [self switchToNextSection];
            self.navIndex++;
        }
        [self activatePoiPointForCorrespondingTourPoint:point];
    }
}

// handles on route poi activation
- (void)activatePoiPointForCorrespondingTourPoint:(TourPoint *)tourPoint {
    TFLog(@"activatePoiPointForCorrespondingTourPoint");
    BOOL passedThroughPOI = FALSE;
    for (PoiPoint *point in self.currentTour.route.poiPoints) {
        
        // if the points match then check it off!
        if ([point matchesTourPoint:tourPoint]) {
            int index = [self.currentTour.route.poiPoints indexOfObject:point];
            NSNumber *visited = [self.currentTour.touchedPoints objectAtIndex:index];
            if (![visited boolValue]) {
                passedThroughPOI = TRUE;
                [self.currentTour.touchedPoints replaceObjectAtIndex:[self.currentTour.route.poiPoints indexOfObject:point] withObject:[NSNumber numberWithBool:YES]];
                [LBMGUtilities storeTouchedPois:self.currentTour.touchedPoints forId:self.currentTour.tourID];
            }
            
            TFLog(@"point should be open %@", point.name);
            point.isOpen = YES;
            
            [TestFlight passCheckpoint:@"POI detected"];
            [self showPOIMessageForNRBTours:[self.currentTour.route.poiPoints objectAtIndex:index]];
        }
    }
    
    if (passedThroughPOI) {
         TFLog(@"activatePoiPointForCorrespondingTourPoint - passedThroughPOI - updating annotations");
        [self updateAnnotations];
    }
}

- (void)handleOutOfArea:(CLLocation *)newLocation {
    DLog(@"OUT OF AREA");
    self.messageLabel.text = @"Off route!";
}

#pragma mark - IBActions
- (IBAction)showCurrentLocationButtonPressed:(id)sender {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (IBAction)guideToTourButtonPressed:(id)sender {
    CLLocationDegrees latitude  = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:0]).latitude doubleValue];
    CLLocationDegrees longitude = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:0]).longitude doubleValue];
    CLLocation *newLocation = self.mapView.userLocation.location;
    
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:newLocation.coordinate addressDictionary:nil];
        MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:place];
        MKPlacemark *toPlace = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
        MKMapItem *toItem = [[MKMapItem alloc] initWithPlacemark:toPlace];
        
        
        NSDictionary *options = @{
                                  MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                                  };
        NSArray *items = @[fromItem, toItem];
        
        [MKMapItem openMapsWithItems:items launchOptions:options];
    } else {
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                         newLocation.coordinate.latitude, newLocation.coordinate.longitude, latitude, longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (IBAction)switchToVirtualTourButtonPressed:(id)sender {
    // Taking out the virtual/real swap buttom functionality
    return;
    
    [self silenceAudio];
    self.currentTour.mapCenter = self.mapView.center;
    self.currentTour.mapRegion = self.mapView.region;
    self.currentTour.useMapSettings = TRUE;
    [self.tourMC switchToVirtualTour];
    [self stopLocationManagerAndMap];
    self.locationSetup = FALSE;
}

- (IBAction)beginTourButtonPressed:(id)sender {
    self.tourStarted = TRUE;
    [self hideBeginTourView];
    [self hideGuideToTourView];
    
    NSString *tagString = [NSString stringWithFormat:@"tour_begins-%@",[self.tourMC.tourID stringValue]];
    DLog(@"%@", tagString);
    [[UAPush shared] addTagToCurrentDevice:tagString];
    [[UAPush shared] updateRegistration];
    
    [ApplicationDelegate.lbmgEngine logTourStartWithId:self.currentTour.tourID latitude:[self getLatitude] andLongitude:[self getLongitude] contentBlock:^(NSDictionary *dictionary) {
        DLog(@"%@", dictionary);
    } errorBlock:^(NSError *error) {
        DLog(@"ERROR logging tour start");
    }];
    self.directionImageView.hidden = YES;
    self.messageLabel.text = @"";
}

- (IBAction)exitButtonTouched:(id)sender {
    self.locationSetup = FALSE;
    
    [super exitButtonTouched:sender];
}

#pragma mark - helpers
- (double)getLatitude {
    return self.mapView.userLocation.coordinate.latitude;
}

- (double)getLongitude {
    return self.mapView.userLocation.coordinate.longitude;
}

- (int)getLastPointPassed {
    return self.currentTour.lastPointPassedIndex;
}

- (double)degreesFromDirectionTrigger:(NSString *)trigger
{
    NSArray *triggers = @[@"N", @"NE" ,@"E" ,@"SE" ,@"S" ,@"SW" ,@"W" ,@"NW"];
    NSArray *degrees = @[@0, @45 ,@90 ,@135 ,@180 ,@225 ,@270 ,@315];

    int index;
    index = [triggers indexOfObject:trigger];
    if (index > 7) return -1.0;
    
    return [degrees[index] doubleValue];
}

- (void)updateProgressBarIfRouteBased {
    if (self.currentTour.isRouteBasedTour) {
        float progressValue = ((self.currentTour.lastPointPassedIndex + 1)/(float)[self.currentTour.route.tourPoints count]);
        [self.progressBar setValue:progressValue animated:YES];
    }
}

@end
