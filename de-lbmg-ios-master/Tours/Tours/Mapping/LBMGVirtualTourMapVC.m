//
//  LBMGVirtualTourVC.m
//  Tours
//
//  Created by Alan Smithee on 4/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGVirtualTourMapVC.h"
#import "LBMGTourTypeVC.h"
#import "TourPoint.h"
#import "LBMGUtilities.h"

@interface LBMGVirtualTourMapVC ()

@end

@implementation LBMGVirtualTourMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.currentTour.isRouteBasedTour) {
        [self.mapView addOverlay:self.currentTour.routeLine];
    }
    self.mapView.showsUserLocation = NO;
    self.virtualPointPassedIndex = -1;
    [self showVirtualTourBeginView];
    self.userLocationAnnotation = [XCRPointAnnotation new];
    self.userLocationAnnotation.type = userLocation;
    
    if (self.currentTour.lastPointPassedIndex > -1) {
        [self hideVirtualTourBeginView];
    }
    
    [self.testOutputView setHidden:YES];
    
    NSMutableArray *personalData = [[NSMutableArray alloc] initWithArray:[LBMGUtilities getUserContentForTour:self.currentTour.tourID]];
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"lastPoint" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, descriptor2, nil];
    NSMutableArray *sortedPersonalData = [NSMutableArray arrayWithArray:[personalData sortedArrayUsingDescriptors:sortDescriptors]];
    [personalData removeAllObjects];
    
    int i = 0;
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    for (TourPoint *point in self.currentTour.route.tourPoints) {
        [personalData addObject:point];
        for (NSDictionary *personalItem in sortedPersonalData) {
            if ([[personalItem objectForKey:@"lastPoint"] integerValue] == i) {
                [personalData addObject:personalItem];
                [itemsToDelete addObject:personalItem];
            }
        }        
        
        // remove objects from sorted array
        for (NSDictionary *item in itemsToDelete) {
            [sortedPersonalData removeObject:item];
        }
        [itemsToDelete removeAllObjects];
        i++;
    }
    self.virtualTourPoints = personalData;
    
//    self.previousButton.hidden = NO;
    
    self.routeNameLabel.text = self.currentTour.routeData.name;
    self.routeDescription.text = self.currentTour.routeData.descriptionText;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Taking out the virtual/real swap buttom
    [self.realTourButton setHidden:YES];
    
    self.mapView.delegate = self;
    if (self.currentTour.useMapSettings) {
        self.mapView.region = self.currentTour.mapRegion;
        self.mapView.center = self.currentTour.mapCenter;
        self.needToUpdateUserLocation = TRUE;
    }
    
    if (self.virtualPointPassedIndex < 0 && self.tourStarted) {
        [self beginButtonPressed:nil];
    }
    
    if (self.needToUpdateUserLocation) {
        [self updateAnnotations];
        self.needToUpdateUserLocation = FALSE;
    }
    if (self.tourStarted)
        [self updateUserLocationAndMessageText];
    else
        self.directionsContainer.hidden = YES;
}

#pragma mark - Virtual Tour Splash Functions
- (void)showVirtualTourBeginView {
    [self.virtualTourBeginView setHidden:NO];
    [self.backButton setHidden:NO];
    [self.homeButton setHidden:YES];
    [self.realTourButton setHidden:YES];
    [self.previousButton setHidden:YES];
    [self.nextButton setHidden:YES];
}

- (void)hideVirtualTourBeginView {
    [self.virtualTourBeginView setHidden:YES];
    [self.backButton setHidden:YES];
    [self.homeButton setHidden:NO];
    
//    [self.realTourButton setHidden:NO];
    // Taking out the virtual/real swap buttom
    [self.realTourButton setHidden:YES];
    
//    [self.previousButton setHidden:NO];
    [self.nextButton setHidden:NO];
}

#pragma mark - Update UI Functions and helpers
- (void)updateUserLocationAndMessageText {
    [self updateProgress];
    [self.mapView removeAnnotation:self.userLocationAnnotation];
    
    TourPoint *associatedPoi;
    
    if ([[self.virtualTourPoints objectAtIndex:self.virtualPointPassedIndex] isKindOfClass:[TourPoint class]]) {
        TourPoint *currentPoint = [self.virtualTourPoints objectAtIndex:self.virtualPointPassedIndex];
        CLLocationDegrees latitude  = [currentPoint.latitude doubleValue];
        CLLocationDegrees longitude = [currentPoint.longitude doubleValue];
        self.userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        associatedPoi = [self findAssociatedPoiWithLatitude:currentPoint.latitude andLongitude:currentPoint.longitude];
    }
    else {
        NSDictionary *currentPoint = [self.virtualTourPoints objectAtIndex:self.virtualPointPassedIndex];
        CLLocationDegrees latitude  = [[currentPoint objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[currentPoint objectForKey:@"longitude"] doubleValue];
        self.userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        associatedPoi = [self findAssociatedPoiWithLatitude:[currentPoint objectForKey:@"latitude"] andLongitude:[currentPoint objectForKey:@"longitude"]];
    }
    
    if (associatedPoi) {
        self.messageLabel.text = associatedPoi.labelText;
    }
    else {
        self.messageLabel.text = @"";
    }

    [self.mapView addAnnotation:self.userLocationAnnotation];
    [self checkForAndHandleMediaPoint];
    [self checkIfTourFinished];
}

- (void)updateProgress {
    float progressValue = ((self.virtualPointPassedIndex + 1)/(float)[self.virtualTourPoints count]);
    [self.progressBar setValue:progressValue animated:YES];
}

- (void)checkIfTourFinished {
    if (self.virtualPointPassedIndex == ([self.virtualTourPoints count] - 1)) {
        self.tourCompleteButton.hidden = NO;
        self.messageLabel.hidden = YES;
    }
    else {
        self.tourCompleteButton.hidden = YES;
        self.messageLabel.hidden = NO;
    }
}

- (TourPoint *)findAssociatedPoiWithLatitude:(NSNumber *)latitude andLongitude:(NSNumber *)longitude {
    
    for (int i = 0; i < [self.virtualTourPoints count]; i++) {
        TourPoint *point = [self.virtualTourPoints objectAtIndex:i];
        if ([point.type isEqualToString:@"PoiPoint"]) {
            if ([point.latitude isEqualToNumber:latitude] && [point.longitude isEqualToNumber:longitude])
                return point;
        }
    }
    return nil;
}


#pragma mark -IBActions
- (IBAction)beginButtonPressed:(id)sender {
    self.tourStarted = TRUE;
    [self hideVirtualTourBeginView];
    self.virtualPointPassedIndex = 0;
    TourPoint *firstPoint = [self.virtualTourPoints objectAtIndex:0];
    [self activateWayPoint:firstPoint];
    [self updateUserLocationAndMessageText];
    self.directionsContainer.hidden = NO;
}

- (IBAction)switchToRealTimeTourButtonPressed:(id)sender {
    // Taking out the virtual/real swap buttom functionality
    return;
    
    [self silenceAudio];
    [self.tourMC switchToRealTimeTour];
}

- (IBAction)nextButtonPressed:(id)sender {
    [self.currentUserContent removeAllObjects];
    
    // find the next point with media in the sequence
    // if it is an audio point play the audio
    BOOL foundNext = FALSE;
    for (int i = self.virtualPointPassedIndex + 1; i < [self.virtualTourPoints count] && !foundNext; i++) {
        if ([[self.virtualTourPoints objectAtIndex:i] isKindOfClass:[TourPoint class]]) {
            TourPoint *point = [self.virtualTourPoints objectAtIndex:i];
            if ([point.type isEqualToString:@"AudioPoint"]) {
                foundNext = TRUE;
                [self activateWayPoint:point];
                self.virtualPointPassedIndex = i;
                [self navButtonPressed:nil];
                [self updateUserLocationAndMessageText];
                [self setPersonalLocation:NO];
            }
//            else if ([point.type isEqualToString:@"PoiPoint"]) {
//                foundNext = TRUE;
//                [self activateWayPoint:point];
//                self.virtualPointPassedIndex = i;
//                [self navButtonPressed:nil];
//                [self updateUserLocation];
//                [self setPersonalLocation:NO];
//            }
        }
        else {
            NSDictionary *personalItem = [self.virtualTourPoints objectAtIndex:i];
            [self.currentUserContent addObject:personalItem];
            self.virtualPointPassedIndex = i;
            [self setPersonalLocation:YES];
            [self navButtonPressed:nil];
            [self updateUserLocationAndMessageText];

            foundNext = TRUE;
        }
    }

    // if no next point is found jump to the end of the tour
    if (!foundNext || self.virtualPointPassedIndex >= [self.virtualTourPoints count] - 1) {
        self.nextButton.hidden = YES;
        self.virtualPointPassedIndex = [self.virtualTourPoints count] - 1;
        [self navButtonPressed:nil];
        [self updateUserLocationAndMessageText];
        [self setPersonalLocation:NO];
    }
    self.previousButton.hidden = NO;
}

- (IBAction)previousButtonPressed:(id)sender {
    [self.currentUserContent removeAllObjects];
    BOOL foundPrevious = FALSE;
    for (int i = self.virtualPointPassedIndex - 1; i >= 0 && !foundPrevious; i--) {
        if ([[self.virtualTourPoints objectAtIndex:i] isKindOfClass:[TourPoint class]]) {
            TourPoint *point = [self.virtualTourPoints objectAtIndex:i];
            if ([point.type isEqualToString:@"AudioPoint"]) {
                foundPrevious = TRUE;
                [self activateWayPoint:point];
                self.virtualPointPassedIndex = i;
                [self navButtonPressed:nil];
                [self updateUserLocationAndMessageText];
                [self setPersonalLocation:NO];
            }
//            else if ([point.type isEqualToString:@"PoiPoint"]) {
//                foundPrevious = TRUE;
//                [self activateWayPoint:point];
//                self.virtualPointPassedIndex = i;
//                [self navButtonPressed:nil];
//                [self updateUserLocation];
//                [self setPersonalLocation:NO];
//            }
        }
        else {
             NSDictionary *personalItem = [self.virtualTourPoints objectAtIndex:i];
            [self.currentUserContent addObject:personalItem];
            self.virtualPointPassedIndex = i;
            [self setPersonalLocation:YES];
            [self navButtonPressed:nil];
            [self updateUserLocationAndMessageText];
            foundPrevious = TRUE;
        }
    }
    // if the first point wasn't an audio point
    if ((!foundPrevious && self.virtualPointPassedIndex > 0) || self.virtualPointPassedIndex == 0) {
        self.previousButton.hidden = YES;
        self.virtualPointPassedIndex = 0;
        [self navButtonPressed:nil];
        [self updateUserLocationAndMessageText];
        [self setPersonalLocation:NO];
    }
    self.nextButton.hidden = NO;
}

- (IBAction)navButtonPressed:(id)sender {
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    
    if ([[self.virtualTourPoints objectAtIndex:[self getLastPointPassed]] isKindOfClass:[TourPoint class]]) {
        TourPoint *lastPoint = [self.virtualTourPoints objectAtIndex:[self getLastPointPassed]];
        latitude  = [lastPoint.latitude doubleValue];
        longitude = [lastPoint.longitude doubleValue];
    }
    else {
        NSDictionary *personalItem = [self.virtualTourPoints objectAtIndex:[self getLastPointPassed]];
        latitude  = [[personalItem objectForKey:@"latitude"] doubleValue];
        longitude = [[personalItem objectForKey:@"longitude"] doubleValue];
    }
    CLLocationCoordinate2D lastPassedPoint = CLLocationCoordinate2DMake(latitude, longitude);
    
    [self.mapView setCenterCoordinate:lastPassedPoint animated:YES];
    
}

- (IBAction)exitButtonTouched:(id)sender {
//    self.needToUpdateUserLocation = TRUE;
    [super exitButtonTouched:sender];
}

#pragma mark - helpers
- (double)getLatitude {
    TourPoint *point = [self.currentTour.route.tourPoints objectAtIndex:self.virtualPointPassedIndex];
    return [point.latitude doubleValue];
}

- (double)getLongitude {
    TourPoint *point = [self.currentTour.route.tourPoints objectAtIndex:self.virtualPointPassedIndex];
    return [point.longitude doubleValue];
}

- (int)getLastPointPassed {
    return self.virtualPointPassedIndex;
}

- (float)getDistanceFromPreviousTourPoint:(CLLocationCoordinate2D)location {
    TourPoint *lastPoint = [self.currentTour.route.tourPoints objectAtIndex:[self getLastPointPassed]];
    CLLocationDegrees latitude  = [lastPoint.latitude doubleValue];
    CLLocationDegrees longitude = [lastPoint.longitude doubleValue];
    
    CLLocationCoordinate2D lastPassedPoint = CLLocationCoordinate2DMake(latitude, longitude);
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastPassedPoint), MKMapPointForCoordinate(location));
}

- (void)setPersonalLocation:(BOOL)personal {
    if (personal) {
        [self.personalButton setImage:[UIImage imageNamed:@"tour_personal_on"] forState:UIControlStateNormal];
        self.isNearUserContent = TRUE;
    }
    else {
        [self.personalButton setImage:[UIImage imageNamed:@"tour_personal"] forState:UIControlStateNormal];
        self.isNearUserContent = FALSE;
    }
}

// keeps the user location annotation on top of all other annotations
- (void) mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *view in views) {
        
        if ([[view annotation] isKindOfClass:[XCRPointAnnotation class]]) {
            XCRPointAnnotation *point = (XCRPointAnnotation *)view.annotation;
            
            
            if (point.type == userLocation) {
                
                CGRect endFrame = view.frame;
//                CGRect visibleRect = [aMapView annotationVisibleRect];
                CGRect startFrame = endFrame;
//                startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
                startFrame.origin.y = startFrame.origin.y-100;
                view.frame = startFrame;
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    view.frame = endFrame;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [[view superview] bringSubviewToFront:view];
                    }
                }];
            }
        }
        else {
            [[view superview] sendSubviewToBack:view];
        }
    }
}


- (void)checkForAndHandleMediaPoint {
    // check if they're within a media point and highlight if so
    TourPoint *point = [self.virtualTourPoints objectAtIndex:self.virtualPointPassedIndex];
    CLLocationDegrees latitude  = [point.latitude doubleValue];
    CLLocationDegrees longitude = [point.longitude doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self processMediaLocation:location];
}

@end
