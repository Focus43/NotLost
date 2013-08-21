//
//  LMGMainMapViewController.m
//  TourGuide
//
//  Created by Alan Smithee on 8/30/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#define DURATION 0.4
#define personalContentRadius @14

// displays the circular area around waypoints if enabled
#define TEST_MODE_STATS_VIEW TRUE
#define kTestModePlistKey @"ShowLocationAreas"


#import "LBMGBaseTourMapVC.h"
#import "PRPAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "XCRPointAnnotation.h"
#import "Photo.h"
//#import "Tour.h"
#import "TourPoint.h"
#import "TourData.h"
#import "MediaPoint.h"
#import "LBMGUtilities.h"
#import "BDAPAudioPlayer.h"
#import "LBMGPhotoVC.h"
#import "LBMGAppDelegate.h"
#import "LBMGPhotoCaptionVC.h"
#import "LBMGUserContentVC.h"
#import "LBMGAddCommentVC.h"
#import "LBMGVideoVC.h"
#import "LBMGTourTypeVC.h"
#import "UAPush.h"
#import "UIToggleButton.h"

@interface LBMGBaseTourMapVC ()

@property (assign, nonatomic) BOOL testMode;

@end

@implementation LBMGBaseTourMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.testMode = [[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestModePlistKey] boolValue];
    
    if (TEST_MODE_STATS_VIEW) {
        self.testOutputView.hidden = NO;
    }
    else {
        self.testOutputView.hidden = YES;
    }
    
    // set up the progress bar
    [self.progressBar setThumbImage:[UIImage imageNamed:@"progressbar_thumb"] forState:UIControlStateNormal];
    [self.progressBar setMinimumTrackImage:[UIImage imageNamed:@"progressbar_front"] forState:UIControlStateNormal];
    [self.progressBar setMaximumTrackImage:[UIImage imageNamed:@"progressbar_thumb"] forState:UIControlStateNormal];

    [self buildMediaCircles];
    [self buildPOICircles];
    [self buildTourSections];
    
    if (self.testMode) {
        [self addNavPointTestCircles];
    }

	// zoom in on the route.
	[self zoomInOnRoute];
        
    [self.progressBar setValue:0];
    
    self.isPlayingMediaAudio = NO;
    self.isPlayingNavAudio = NO;

    self.variance = 75;
    self.courseVariance = 50;

    self.radialMenu = [[ALRadialMenu alloc] init];
    self.radialMenu.delegate = self;
    
    self.currentUserContent = [[NSMutableArray alloc] init];
    
    self.navIndex = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentTour.userContent = [[NSMutableArray alloc] initWithContentsOfFile:[LBMGUtilities userDataPlistPathForTourID:self.currentTour.tourID]];
    [self updateAnnotations];
    
    if (self.currentTour.routeData.introAudio && !self.playedAudio) {
        NSString *introAudioPath = [[LBMGUtilities audioPathForTourID:self.currentTour.tourID] stringByAppendingPathComponent:self.currentTour.routeData.introAudio];
        [self playAudioFileNamed:introAudioPath];
        self.playedAudio = YES;
    }
}

- (void)viewDidUnload {
    [self setProgressBar:nil];
    [self setProgressContainer:nil];
    [super viewDidUnload];
}

- (void)setupLocationManagerAndMap {
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocationManagerAndMap {
    self.mapView.delegate = nil;
    self.locationManager.delegate = nil;

    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

#pragma mark - Map Item building functions
// creates the media circles and puts them in the mediaCircles array
- (void)buildMediaCircles {
    
    self.mediaCircles = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
    for (MediaPoint *way in self.currentTour.route.mediaPoints) {
        way.index = [NSNumber numberWithInt:i];
        MKCircle *circle = [self getCircleForLatitude:way.latitude andLogitude:way.longitude andMeters:way.radius];
        [self.mediaCircles addObject:circle];
        if (self.testMode) {
            [self.mapView addOverlay:circle];
        }
        i++;
    }
}

// creates the poi circles and adds them to the poiCircles array
- (void)buildPOICircles {
    self.poiCircles = [NSMutableArray arrayWithCapacity:1];
    for (PoiPoint *point in self.currentTour.route.poiPoints) {
        MKCircle *circle = [self getCircleForLatitude:point.latitude andLogitude:point.longitude andMeters:point.radius];
        [self.poiCircles addObject:circle];
        if (self.testMode) {
            [self.mapView addOverlay:circle];
        }
    }
    [self updateAnnotations];
}

- (void)buildTourSections {
    NSMutableArray *newSections = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray *section = [NSMutableArray arrayWithCapacity:1];
    
    int i = 0;
    for (TourPoint *way in self.currentTour.route.tourPoints) {
        way.index = [NSNumber numberWithInt:i];
        [section addObject:way];
        
        if ([way.type isEqualToString:@"PoiPoint"] || i == 0) {
            if (way != [self.currentTour.route.tourPoints lastObject]) {
                section = [NSMutableArray arrayWithCapacity:1];
                [newSections addObject:section];
                [section addObject:way];
            }
        }
        i++;
    }
    self.sections = [newSections copy];
}

- (void)addNavPointTestCircles {
    for (TourPoint *point in self.currentTour.route.tourPoints) {
        MKCircle *circle = [self getCircleForLatitude:point.latitude andLogitude:point.longitude andMeters:point.radius];
//        if ([point.type isEqualToString:@"NavigationPoint"])
            [self.mapView addOverlay:circle];
    }
}

- (void)zoomInOnRoute
{
	[self.mapView setVisibleMapRect:self.currentTour.routeRect];
}

#pragma mark - Section code
- (void)ZoomInOnSection
{
    
//    NSMutableArray *currentSectionPoints = [[NSMutableArray alloc] initWithCapacity:2];
//    [currentSectionPoints addObject:[[self.sections objectAtIndex:self.navIndex] objectAtIndex:0]];
//    [currentSectionPoints addObject:[[self.sections objectAtIndex:self.navIndex] lastObject]];
    
    MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
    
    NSArray *currentSectionPoints = [self.sections objectAtIndex:self.navIndex];
    
    for(int idx = 0; idx < currentSectionPoints.count; idx++)
    {
        TourPoint *coords = [currentSectionPoints objectAtIndex:idx];
        
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
    }
       
    CGPoint area = CGPointMake(northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    MKMapRect sectionRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, area.x, area.y);
    
//    [self.mapView setVisibleMapRect:sectionRect animated:YES];    
    [self.mapView setVisibleMapRect:sectionRect edgePadding:UIEdgeInsetsMake(66, 5, 66, 5) animated:YES];
}

- (void)addRouteSectionOverlay
{
    // create a c array of points.
	MKMapPoint* pointArr = malloc(sizeof(MKMapPoint) * self.currentSection.count);
	
	for(int idx = 0; idx < self.currentSection.count; idx++) {
        
		TourPoint *coords = [self.currentSection objectAtIndex:idx];
        
		CLLocationDegrees latitude  = [coords.latitude doubleValue];
		CLLocationDegrees longitude = [coords.longitude doubleValue];
        
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
		pointArr[idx] = point;
    }
	
    // create the polyline based on the array of points.
    [self.mapView removeOverlay:self.navLine];
	self.navLine = [MKPolyline polylineWithPoints:pointArr count:self.currentSection.count];
    [self.mapView addOverlay:self.navLine];
    
	free(pointArr);
}

- (void)switchToNextSection {
    
    if (self.navIndex >= 0 && self.navIndex < self.sections.count) {
        self.currentSection = [self.sections objectAtIndex:self.navIndex];
        
//        if (self.testMode)
            [self addRouteSectionOverlay];
        
        [self ZoomInOnSection];
    }
}

#pragma mark - MapKit
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	
	if(overlay == self.currentTour.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
		if(nil == self.routeLineView)
		{
			self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.currentTour.routeLine];
			self.routeLineView.strokeColor = [UIColor colorWithRed:0.000 green:0.000 blue:1.000 alpha:0.500];
			self.routeLineView.lineWidth = 10;
		}
		overlayView = self.routeLineView;
        
	}
    // used to add a section line
    else if(overlay == self.navLine) {
        
        self.navLineView = [[MKPolylineView alloc] initWithPolyline:self.navLine];
        self.navLineView.strokeColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.000 alpha:0.600];
        self.navLineView.lineWidth = 14;
		overlayView = self.navLineView;
        
	}
    else if (self.testMode) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay];
        if ([self.mediaCircles containsObject:overlay])
            circleView.fillColor = [[UIColor alloc] initWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
        else if ([self.poiCircles containsObject:overlay])
            circleView.fillColor = [[UIColor alloc] initWithRed:0/255.0 green:0/255.0 blue:255/255.0 alpha:0.4];
        else
            circleView.fillColor = [[UIColor alloc] initWithRed:0/255.0 green:255/255.0 blue:0/255.0 alpha:0.4];
        return circleView;
    }
    
	return overlayView;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self handleNewLocation:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[XCRPointAnnotation class]])
    {
        XCRPointAnnotation *annotate = annotation;
        // poi pin type
        if (annotate.type == poi) {
            if(annotate.poiState == Visited) {
                MKAnnotationView *pinView = nil;
                
                static NSString *defaultPinID = @"CustomTickAnnotationView";
                pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
                if (pinView == nil )
                    pinView = [[MKAnnotationView alloc]
                               initWithAnnotation:annotation reuseIdentifier:defaultPinID];
                
                pinView.canShowCallout = YES;
                pinView.centerOffset = CGPointMake(0, -22);
                pinView.image = [UIImage imageNamed:@"tour_pin_todo"];
                
                UIToggleButton *annotationToggle = [[UIToggleButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                [annotationToggle setToggleOffImage:[UIImage imageNamed:@"tour_annotation_checkbox_off"] andToggleOnImage:[UIImage imageNamed:@"tour_annotation_checkbox_on"]];
                [annotationToggle addTarget:self action:@selector(toggleAnnotation) forControlEvents:UIControlEventTouchUpInside];
                [annotationToggle setOn];
                
                pinView.leftCalloutAccessoryView = annotationToggle;
                
                return pinView;
            }
            else if (annotate.poiState == Unvisited) {
                MKAnnotationView *pinView = nil;
                
                static NSString *defaultPinID = @"CustomTickAnnotationView";
                pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
                if (pinView == nil )
                    pinView = [[MKAnnotationView alloc]
                               initWithAnnotation:annotation reuseIdentifier:defaultPinID];
                
                pinView.canShowCallout = YES;
                pinView.centerOffset = CGPointMake(0, -22);
                pinView.image = [UIImage imageNamed:@"tour_pin_poi"];
                
                UIToggleButton *annotationToggle = [[UIToggleButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                [annotationToggle setToggleOffImage:[UIImage imageNamed:@"tour_annotation_checkbox_off"] andToggleOnImage:[UIImage imageNamed:@"tour_annotation_checkbox_on"]];
                [annotationToggle addTarget:self action:@selector(toggleAnnotation) forControlEvents:UIControlEventTouchUpInside];
                [annotationToggle setOff];
                
                pinView.leftCalloutAccessoryView = annotationToggle;
                
                return pinView;
            }
        }
        // personal content pins
        else if (annotate.type == personal) {
            MKAnnotationView *pinView = nil;
            
            static NSString *defaultPinID = @"CustomTickAnnotationView";
            pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if (pinView == nil )
                pinView = [[MKAnnotationView alloc]
                           initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            pinView.canShowCallout = YES;
            pinView.centerOffset = CGPointMake(8, -21);
            pinView.image = [UIImage imageNamed:@"tour_pin_personal"];
            
            return pinView;
        }
        else if (annotate.type == userLocation) {
            MKAnnotationView *pinView = nil;
            
            static NSString *defaultPinID = @"CustomTickAnnotationView";
            pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if (pinView == nil )
                pinView = [[MKAnnotationView alloc]
                           initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            pinView.canShowCallout = YES;
            pinView.centerOffset = CGPointMake(0, 0);
            pinView.image = [UIImage imageNamed:@"virt_imhere_dot"];
            
            return pinView;
        }
    }
    return nil;
}

#pragma mark - New Location Handlers
- (void)processPOILocation:(CLLocation *)newLocation {
    BOOL passedThroughPOI = FALSE;
    int i = 0;
    for (PoiPoint *point in self.currentTour.route.poiPoints) {
        MKCircle *poiCircle = [self getCircleForLatitude:point.latitude andLogitude:point.longitude andMeters:point.radius];
        
        if (!point.onRoute && [self mapCircleContainsPoint:poiCircle withPoint:newLocation]) {
            // trigger poi stuff
            int index = [self.currentTour.route.poiPoints indexOfObject:point];
            NSNumber *visited = [self.currentTour.touchedPoints objectAtIndex:index];
            if (![visited boolValue]) {
                passedThroughPOI = TRUE;
                [self.currentTour.touchedPoints replaceObjectAtIndex:[self.currentTour.route.poiPoints indexOfObject:point] withObject:[NSNumber numberWithBool:YES]]; 
                [LBMGUtilities storeTouchedPois:self.currentTour.touchedPoints forId:self.currentTour.tourID];
            }
            
            [TestFlight passCheckpoint:@"POI detected"];
            [self showPOIMessageForNRBTours:[self.currentTour.route.poiPoints objectAtIndex:index]];
        }
        i++;
    }
    
    if (passedThroughPOI) {
        [self updateAnnotations];
    }
}

- (void)processMediaLocation:(CLLocation *)newLocation {
    
    if (self.currentMediaCircle) {
        if (![self mapCircleContainsPoint:self.currentMediaCircle withPoint:newLocation]) {
            self.previousMediaPoint = self.currentMediaPoint;
            self.currentMediaCircle = nil;
            self.currentMediaPoint = nil;
            
            [self.photoButton setImage:[UIImage imageNamed:@"tour_photos"] forState:UIControlStateNormal];
            [self.videoButton setImage:[UIImage imageNamed:@"tour_video"] forState:UIControlStateNormal];
            [TestFlight passCheckpoint:@"Leaving MediaPoint"];
        }
    }
    
    if (!self.currentMediaCircle) {
        int i = 0;
        MediaPoint *mediaPoint;
        for (MKCircle *circle in self.mediaCircles) {
            if ([self mapCircleContainsPoint:circle withPoint:newLocation]) {
                // reached a waypoint
                mediaPoint = [self.currentTour.route.mediaPoints objectAtIndex:i];
                self.currentMediaCircle = circle;
                [TestFlight passCheckpoint:@"Detected MediaPoint"];
                break;
            }
            i++;
        }
        if (mediaPoint) {
            self.currentMediaPoint = mediaPoint;
            if (mediaPoint.audio) {
                [self playMediaAudioFileNamed:mediaPoint.audio];
            }
            if ([mediaPoint.photos count] > 0) {
                [self.photoButton setImage:[UIImage imageNamed:@"tour_photos_on"] forState:UIControlStateNormal];
            }
            if ([mediaPoint.videos count] > 0) {
                [self.videoButton setImage:[UIImage imageNamed:@"tour_video_on"] forState:UIControlStateNormal];
            }
            
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"Detected MediaPoint - %@", mediaPoint.name]];
            
        } else {
            //                self.messageLabel.text = @"";
        }
    }
}

- (void)processPersonalContentLocation:(CLLocation *)newLocation {
    
    self.isNearUserContent = FALSE;
    for (NSDictionary *personalPoint in self.currentTour.userContent) {
        MKCircle *personalCircle = [self getCircleForLatitude:[personalPoint objectForKey:@"latitude"] andLogitude:[personalPoint objectForKey:@"longitude"] andMeters:personalContentRadius];
        
        if ([self mapCircleContainsPoint:personalCircle withPoint:newLocation]) {
            self.isNearUserContent = TRUE;
            [self.currentUserContent addObject:personalPoint];
        }
    }
    if (self.isNearUserContent) {
        [self.personalButton setImage:[UIImage imageNamed:@"tour_personal_on"] forState:UIControlStateNormal];
    }
    else {
        [self.personalButton setImage:[UIImage imageNamed:@"tour_personal"] forState:UIControlStateNormal];
        [self.currentUserContent removeAllObjects];
    }
}

- (BOOL)checkForOutOfArea:(CLLocation *)newLocation {
    CLLocationDegrees fromLatitude  = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:self.currentTour.lastPointPassedIndex]).latitude doubleValue];
    CLLocationDegrees fromLongitude = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:self.currentTour.lastPointPassedIndex]).longitude doubleValue];
    CLLocationCoordinate2D fromPoint = CLLocationCoordinate2DMake(fromLatitude, fromLongitude);
    
    
    CLLocationDegrees toLatitude  = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:(self.currentTour.lastPointPassedIndex + 1)]).latitude doubleValue];
    CLLocationDegrees toLongitude = [((TourPoint *)[self.currentTour.route.tourPoints objectAtIndex:(self.currentTour.lastPointPassedIndex + 1)]).longitude doubleValue];
    CLLocationCoordinate2D toPoint = CLLocationCoordinate2DMake(toLatitude, toLongitude);
    
    float distanceMeters = MKMetersBetweenMapPoints(MKMapPointForCoordinate(fromPoint), MKMapPointForCoordinate(newLocation.coordinate));
    double bearing = [self.currentTour calculateCourseFromLocation:fromPoint toLocation:toPoint];
    CLLocationCoordinate2D projectedPoint = [self coordinateFromCoord:fromPoint atDistanceM:distanceMeters atBearingDegrees:bearing];
    
    float meters = MKMetersBetweenMapPoints(MKMapPointForCoordinate(newLocation.coordinate), MKMapPointForCoordinate(projectedPoint));
   
    [self.routeDistLabel setText:[NSString stringWithFormat:@"%f", meters]];
    
    if (meters > self.variance)
        return true;
    return false;
}

#pragma mark - Location Helpers
// handles the activation of the media for a waypoint
- (void)activateWayPoint:(TourPoint *)point {
    if (point.audio) {
        NSString *audioPoint = [[LBMGUtilities audioPathForTourID:self.currentTour.tourID] stringByAppendingPathComponent:point.audio];
        if ([point.type isEqualToString:@"AudioPoint"] && self.currentTour.isRealTour) {
            [self playMediaAudioFileNamed:audioPoint];
        } else {
            [self playAudioFileNamed:audioPoint];
        }
    }
    
    if (self.currentTour.isRealTour && self.currentTour.lastPointPassedIndex >= [self.currentTour.route.tourPoints count] - 1) {
        self.tourCompleteButton.hidden = NO;
        self.messageLabel.hidden = YES;
        self.navIndex = 0;
        
        // close personal content radial since the buttons are still enabled and cannot be refreshed
        if (self.currentTour.personalOpen) {
            [self personalButtonPressed:nil];
        }
        
        [self.progressBar setValue:1.0];
        self.currentTour.lastPointPassedIndex = -1;
        NSString *tagString = [NSString stringWithFormat:@"tour_complete-%@",[self.tourMC.tourID stringValue]];
        DLog(@"%@", tagString);
        [[UAPush shared] addTagToCurrentDevice:tagString];
        [[UAPush shared] updateRegistration];
    }
    else {
        self.tourCompleteButton.hidden = YES;
        self.messageLabel.hidden = NO;
    }
}

- (BOOL)mapCircleContainsPoint:(MKCircle *)circle withPoint:(CLLocation *)point {
    float meters = MKMetersBetweenMapPoints(MKMapPointForCoordinate(circle.coordinate), MKMapPointForCoordinate(point.coordinate));
    return (meters <= circle.radius);
}

- (void)updateAnnotations {
    self.mapView.delegate = self;
    [self.mapView removeAnnotations:[self.mapView annotations]];
    int i = 0;
    int touchedCount = 0;
    for (NSNumber *touched in self.currentTour.touchedPoints) {
        PoiPoint *way = [self.currentTour.route.poiPoints objectAtIndex:i];
        XCRPointAnnotation *pin = [XCRPointAnnotation new];
        pin.type = poi;
        pin.coordinate = CLLocationCoordinate2DMake([way.latitude doubleValue], [way.longitude doubleValue]);
        pin.title = way.labelText;
        
        // needed in order to make the annotation callouts show for POIs without labelText
        if ([way.labelText length] == 0)
            pin.title = @" ";
        
        pin.poiIndex = i;
        // set the name here to give it selection text
        
        if ([touched boolValue]) {
            pin.poiState = Visited;
            touchedCount++;
        }
        [self.mapView addAnnotation:pin];
        i++;
    }
    for (NSDictionary *personalItem in self.currentTour.userContent) {
        XCRPointAnnotation *pin = [XCRPointAnnotation new];
        pin.type = personal;
        CLLocationDegrees latitude  = [[personalItem objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[personalItem objectForKey:@"longitude"] doubleValue];
        pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [self.mapView addAnnotation:pin];
    }
    if (!self.currentTour.isRouteBasedTour) {
        float progressValue = (CGFloat)touchedCount/self.currentTour.touchedPoints.count;
        [self.progressBar setValue:progressValue animated:YES];
    }
}

#pragma mark - Calculation Functions
- (double)radiansFromDegrees:(double)degrees
{
    return degrees * (M_PI / 180.0);
}

- (double)degreesFromRadians:(double)radians
{
    return radians * (180.0 / M_PI);
}

// from http://stackoverflow.com/questions/6633850/calculate-new-coordinate-x-meters-and-y-degree-away-from-one-coordinate
// calculates the point between two points at a certain distance in meters
- (CLLocationCoordinate2D)coordinateFromCoord:(CLLocationCoordinate2D)fromCoord atDistanceM:(double)distanceM atBearingDegrees:(double)bearingDegrees {
    
    //6,371 = Earth's radius in km, multiply by 1000 to get m
    double distanceRadians = distanceM / (6371.0 * 1000);

    double bearingRadians = [self radiansFromDegrees:bearingDegrees];
    double fromLatRadians = [self radiansFromDegrees:fromCoord.latitude];
    double fromLonRadians = [self radiansFromDegrees:fromCoord.longitude];
    
    double toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians)
                               + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) );
    
    double toLonRadians = fromLonRadians + atan2(sin(bearingRadians)
                                                 * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians)
                                                 - sin(fromLatRadians) * sin(toLatRadians));
    
    // adjust toLonRadians to be in the range -180 to +180...
    toLonRadians = fmod((toLonRadians + 3 * M_PI), (2 * M_PI)) - M_PI;
    
    CLLocationCoordinate2D result;
    result.latitude = [self degreesFromRadians:toLatRadians];
    result.longitude = [self degreesFromRadians:toLonRadians];
    return result;
}

#pragma mark - Media Functions
- (void)playAudioFileNamed:(NSString *)name {
    
    DLog(@"play Audio - %@", name);
    NSURL *url = [NSURL fileURLWithPath:name];
    
    if (self.isPlayingNavAudio && [self.playingAudioName isEqualToString:name]) {
        DLog(@"trying to play twice");
        return;
    }

    [self.audioPlayer pause];
    self.audioPlayer = nil;
    NSError *error;
    self.audioPlayer = [[BDAPAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    if (!error) {
        self.isPlayingNavAudio = YES;
        self.playingAudioName = name;
        if (self.isPlayingMediaAudio) {
            [self.mediaAudioPlayer fadeToVolume:0.0 duration:0.3 completion:^{
                [self.mediaAudioPlayer pause];
                [self.audioPlayer play];
            }];
        } else {
            [self.audioPlayer play];
        }
    }
//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Starting New Audio - %@", name]];
}

- (void)playMediaAudioFileNamed:(NSString *)name {
    
    DLog(@"play Audio - %@", name);
    NSURL *url = [NSURL fileURLWithPath:name];
    
    if (self.isPlayingMediaAudio && [self.playingAudioName isEqualToString:name]) {
        DLog(@"trying to play twice");
        return;
    }
    
    [self.mediaAudioPlayer pause];
    self.mediaAudioPlayer = nil;
    NSError *error;
    self.mediaAudioPlayer = [[BDAPAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.mediaAudioPlayer.delegate = self;
    if (!error) {
        self.isPlayingMediaAudio = YES;
        self.playingAudioName = name;
        [self.mediaAudioPlayer play];
        if (self.isPlayingNavAudio) {
            [self.mediaAudioPlayer pause];
        }
    }
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Starting New Audio - %@", name]];
}

#pragma mark - AVAudioPlayer
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    if (player == self.mediaAudioPlayer) {
        self.isPlayingMediaAudio = NO;
    } else if (self.isPlayingMediaAudio) {
        self.isPlayingNavAudio = NO;
        self.mediaAudioPlayer.volume = 0;
        [self.mediaAudioPlayer fadeToVolume:1.0 duration:0.3];
    } else {
        self.isPlayingNavAudio = NO;
    }
}

#pragma mark - IBActions
- (IBAction)exitButtonTouched:(id)sender
{
    [self silenceAudio];
    [self.tourMC popWithCompletionBlock:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self stopLocationManagerAndMap];
        self.currentTour.useMapSettings = FALSE;
    }];
}

- (IBAction)videoButtonPressed:(id)sender
{
    LBMGVideoVC *videoView = [LBMGVideoVC new];
    videoView.tourID = self.currentTour.tourID;
    videoView.tourData = self.currentTour.routeData;
    videoView.currentVideos = self.previousMediaPoint.videos;
    if (self.currentMediaPoint) {
        videoView.currentVideos = self.currentMediaPoint.videos;
    }
    [self presentViewController:videoView animated:YES completion:nil];
}

- (IBAction)photoButtonPressed:(id)sender
{
    LBMGPhotoVC *photoView = [LBMGPhotoVC new];
    photoView.tourID = self.currentTour.tourID;
    photoView.tourData = self.currentTour.routeData;
    photoView.currentPhotos = self.previousMediaPoint.photos;
    if (self.currentMediaPoint) {
        photoView.currentPhotos = self.currentMediaPoint.photos;
    }
    [self presentViewController:photoView animated:YES completion:nil];
}

- (IBAction)tourCompleteButtonPressed:(id)sender
{
    [self silenceAudio];
    [self.tourMC goToTourEndView:YES];
}

- (IBAction)tourInfoButtonPressed:(id)sender
{
    [self silenceAudio];
    [self.tourMC goToTourEndView:NO];
}

- (void)silenceAudio
{
    [self.audioPlayer pause];
    self.audioPlayer = nil;
    [self.mediaAudioPlayer pause];
    self.mediaAudioPlayer = nil;
}

- (IBAction)varianceChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.variance = slider.value;
    slider.value = self.variance;
    self.varianceLabel.text = [NSString stringWithFormat:@"%i", self.variance];
}

- (IBAction)courseVarianceChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.courseVariance = slider.value;
    slider.value = self.courseVariance;
    self.courseVarianceLabel.text = [NSString stringWithFormat:@"%i", self.courseVariance];
}

- (IBAction)personalButtonPressed:(id)sender {
    BOOL success = [self.radialMenu buttonsWillAnimateFromButton:sender inView:self.view];
    if (success) {
        if (self.currentTour.personalOpen) {
            self.videoButton.userInteractionEnabled = YES;
            self.photoButton.userInteractionEnabled = YES;
            self.navButton.userInteractionEnabled = YES;
            self.aroundMeButton.userInteractionEnabled = YES;
            [UIView animateWithDuration:1 animations:^{
                [self.videoButton setAlpha:1];
                [self.photoButton setAlpha:1];
                [self.navButton setAlpha:1];
                [self.aroundMeButton setAlpha:1];
            }];
            
            self.currentTour.personalOpen = FALSE;
        }
        else {
            self.videoButton.userInteractionEnabled = NO;
            self.photoButton.userInteractionEnabled = NO;
            self.navButton.userInteractionEnabled = NO;
            self.aroundMeButton.userInteractionEnabled = NO;
            [UIView animateWithDuration:1 animations:^{
                [self.videoButton setAlpha:.2];
                [self.photoButton setAlpha:.2];
                [self.navButton setAlpha:.2];
                [self.aroundMeButton setAlpha:.2];
            }];
                        
            self.currentTour.personalOpen = TRUE;
        }
    }
}

#pragma mark - Helpers
- (MKMapPoint)mapPointFromWay:(TourPoint *)way {
    
    CLLocationDegrees latitude  = [way.latitude doubleValue];
    CLLocationDegrees longitude = [way.longitude doubleValue];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    return MKMapPointForCoordinate(coordinate);
}

- (void)blinkBackgroundColor:(UIColor *)color ForView:(UIView *)view {
    
    UIColor *startColor = view.backgroundColor;
    view.layer.backgroundColor = color.CGColor;
    [UIView animateWithDuration:1.0 animations:^{
        view.layer.backgroundColor = startColor.CGColor;
    }];
    
}

- (MKCircle *)getCircleForLatitude:(NSNumber *)latitudeNum andLogitude:(NSNumber *)longitudeNum andMeters:(NSNumber *)meters {
    
    CLLocationDegrees latitude  = [latitudeNum doubleValue];
    CLLocationDegrees longitude = [longitudeNum doubleValue];
    
    return [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius:[meters doubleValue]];
}

- (float)getDistanceFromTourPoint:(CLLocationCoordinate2D)location withPointIndex:(int)index {
    TourPoint *lastPoint = [self.currentTour.route.tourPoints objectAtIndex:index];
    CLLocationDegrees latitude  = [lastPoint.latitude doubleValue];
    CLLocationDegrees longitude = [lastPoint.longitude doubleValue];
    
    CLLocationCoordinate2D lastPassedPoint = CLLocationCoordinate2DMake(latitude, longitude);
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastPassedPoint), MKMapPointForCoordinate(location));
}

#pragma mark - Radial Menu Delegate Methods
- (NSInteger)numberOfItemsInRadialMenu:(ALRadialMenu *)radialMenu {
    return 4;
}

- (NSInteger)arcSizeForRadialMenu:(ALRadialMenu *)radialMenu {
    return 70;
}

- (NSInteger)arcRadiusForRadialMenu:(ALRadialMenu *)radialMenu {
    return 125;
}

- (UIImage *)radialMenu:(ALRadialMenu *)radialMenu imageForIndex:(NSInteger)index {
    if (index == 1) {
        return [UIImage imageNamed:@"tour_personal_photo"];
    }
    else if (index == 2) {
        return [UIImage imageNamed:@"tour_personal_video"];
    }
    else if (index == 3) {
        return [UIImage imageNamed:@"tour_personal_note"];
    }
    else if (index == 4) {
        if (self.isNearUserContent)
            return [UIImage imageNamed:@"tour_personal_content_available"];
        return [UIImage imageNamed:@"tour_personal_content"];
    }
    return nil;
}

- (UIImage *)radialMenu:(ALRadialMenu *)radialMenu highlightImageForIndex:(NSInteger)index {
    if (index == 1) {
        return [UIImage imageNamed:@"tour_personal_photo_on"];
    }
    else if (index == 2) {
        return [UIImage imageNamed:@"tour_personal_video_on"];
    }
    else if (index == 3) {
        return [UIImage imageNamed:@"tour_personal_note_on"];
    }
    else if (index == 4) {
        return [UIImage imageNamed:@"tour_personal_content_on"];
    }
    return nil;
}

- (BOOL)radialMenu:(ALRadialMenu *)radialMenu buttonEnabledAtIndex:(NSInteger) index {
    if (self.currentTour.isRealTour && self.tourCompleteButton.hidden) {
        return TRUE;
    }
    else {
        if (index == 4)
            return TRUE;
        return FALSE;
    }
}


- (void)radialMenu:(ALRadialMenu *)radialMenu didSelectItemAtIndex:(NSInteger)index {
    if (index == 1) {
        [self personalPhotoButtonPressed];
    }
    else if (index == 2) {
        [self personalVideoButtonPressed];
    }
    else if (index == 3) {
        [self personalCommentButtonPressed];
    }
    else if (index == 4) {
        [self personalContentButtonPressed];
    }
}

#pragma mark - Personal Content Button Actions
- (void)personalPhotoButtonPressed {
    [self setPersonalContentAddedSettings];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    // Place image picker on the screen
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)personalVideoButtonPressed {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self setPersonalContentAddedSettings];
        
        UIImagePickerController *videoRecorder = [[UIImagePickerController alloc] init];
        NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:videoRecorder.sourceType];
        if (![sourceTypes containsObject:(NSString *)kUTTypeMovie]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device does not support video recording." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        videoRecorder.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoRecorder.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        videoRecorder.videoQuality = UIImagePickerControllerQualityTypeMedium;
        videoRecorder.videoMaximumDuration = 120;
        videoRecorder.delegate = self;
        
        [self presentViewController:videoRecorder animated:YES completion:nil];
    }
}

- (void)personalCommentButtonPressed {
    [self setPersonalContentAddedSettings];
    LBMGAddCommentVC *commentView = [LBMGAddCommentVC new];
    commentView.tourID = self.currentTour.tourID;
    commentView.lastPointPassedIndex = self.personalContentIndexPassed;
    commentView.userLocation = [[CLLocation alloc] initWithLatitude:self.latitudeForPersonalContentHit longitude:self.longitudeForPersonalContentHit];
    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)personalContentButtonPressed {
    LBMGUserContentVC *userContentController = [LBMGUserContentVC new];
    userContentController.tourID = self.currentTour.tourID;
    userContentController.content = self.currentTour.userContent;
    userContentController.currentContent = self.currentUserContent;
    [self presentViewController:userContentController animated:YES completion:nil];
}

- (void)setPersonalContentAddedSettings {
    self.personalContentIndexPassed = self.currentTour.lastPointPassedIndex;
    self.latitudeForPersonalContentHit = [self getLatitude];
    self.longitudeForPersonalContentHit = [self getLongitude];
}

#pragma mark - UIImagePickerController Delegate methods
//delegate methode will be called after picking photo either from camera or library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    // if the content is a video
    if ([type isEqualToString:(NSString *)kUTTypeVideo] || [type isEqualToString:(NSString *)kUTTypeMovie]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        NSString *filename = [NSString stringWithFormat:@"video_%i.MOV", [self.currentTour.userContent count]];
        NSString *videoStoragePath = [[LBMGUtilities userDataPathForTourID:self.currentTour.tourID] stringByAppendingPathComponent:filename];
        
        [videoData writeToFile:videoStoragePath atomically:YES];
        
        // create dictionary for user content plist
        NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filename, @"video", nil];
        NSString *latitude = [NSString stringWithFormat:@"%f", [self getLatitude]];
        NSString *longitude = [NSString stringWithFormat:@"%f", [self getLongitude]];
        [videoDict setObject:latitude forKey:@"latitude"];
        [videoDict setObject:longitude forKey:@"longitude"];
        [videoDict setObject:[NSString stringWithFormat:@"%i", [self getLastPointPassed]] forKey:@"lastPoint"];
        
        CLLocationDegrees latitudeValue  = self.latitudeForPersonalContentHit;
        CLLocationDegrees longitudeValue = self.longitudeForPersonalContentHit;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeValue, longitudeValue);
        
        NSNumber *distance = [NSNumber numberWithDouble:[self getDistanceFromTourPoint:coordinate withPointIndex:self.personalContentIndexPassed]];
        [videoDict setObject:distance forKey:@"distance"];
        
        [LBMGUtilities updateUserContentForTour:self.currentTour.tourID withItem:videoDict];
    }
    // if the content is a picture
    else {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSString *filename = [NSString stringWithFormat:@"photo_%i.jpg", [self.currentTour.userContent count]];
        [self dismissViewControllerAnimated:YES completion:^{
            
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            NSString *filePath = [[LBMGUtilities userDataPathForTourID:self.currentTour.tourID] stringByAppendingPathComponent:filename];
            NSError *error;
            
            [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
            
            LBMGPhotoCaptionVC *photoCaptionVC = [LBMGPhotoCaptionVC new];
            photoCaptionVC.imageFilename = filename;
            photoCaptionVC.thumbnailImage = image;
            photoCaptionVC.tourID = self.currentTour.tourID;
            photoCaptionVC.latitude = [self getLatitude];
            photoCaptionVC.longitude = [self getLongitude];
            photoCaptionVC.previousPoint = [NSString stringWithFormat:@"%i", [self getLastPointPassed]];
            
            CLLocationDegrees latitudeValue  = self.latitudeForPersonalContentHit;
            CLLocationDegrees longitudeValue = self.longitudeForPersonalContentHit;
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeValue, longitudeValue);
            
            float distance = [self getDistanceFromTourPoint:coordinate withPointIndex:self.personalContentIndexPassed];
            
            photoCaptionVC.pointDistance = distance;
            
            [self presentViewController:photoCaptionVC animated:YES completion:nil];
        }];
        [LBMGUtilities createAndStoreThumbnailForImage:image named:filename atPath:[LBMGUtilities userDataPathForTourID:self.currentTour.tourID]];
    }
}

#pragma mark - Annotation functions
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    DLog(@"didSelectAnnotationView");
    self.currentlySelectedAnnotation = view;
}

- (void)toggleAnnotation {
    XCRPointAnnotation *annotate = self.currentlySelectedAnnotation.annotation;
    [self.mapView removeAnnotation:annotate];
    if (annotate.type == poi) {
        if(annotate.poiState == Visited) {
            [self.currentTour.touchedPoints replaceObjectAtIndex:annotate.poiIndex withObject:[NSNumber numberWithBool:NO]];
            annotate.poiState = Unvisited;
        } else {
            [self.currentTour.touchedPoints replaceObjectAtIndex:annotate.poiIndex withObject:[NSNumber numberWithBool:YES]];
            annotate.poiState = Visited;
        }
        [LBMGUtilities storeTouchedPois:self.currentTour.touchedPoints forId:self.currentTour.tourID];
    }
    
    [self.mapView addAnnotation:annotate];
    [self.mapView selectAnnotation:annotate animated:NO];
    [self updateProgressForNRBTour];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    DLog(@"didDeselectAnnotationView");
    
}

#pragma mark - Debug view
- (IBAction)toggleDebugView:(id)sender {
    if (self.testOutputView.hidden) {
        self.testOutputView.hidden = NO;
        [self addNavPointTestCircles];
    } else {
        self.testOutputView.hidden = YES;
    }
}

- (void)hideDebugView:(id)sender {
    self.testOutputView.hidden = YES;
    [self addNavPointTestCircles];
}

- (void)updateProgressForNRBTour {
    if (!self.currentTour.isRouteBasedTour) {
        int touchedCount = 0;
        for (NSNumber *touched in self.currentTour.touchedPoints) {
            if ([touched boolValue]) {
                touchedCount+= 1;
            }
        }
        
        float progressValue = (CGFloat)touchedCount/self.currentTour.touchedPoints.count;
        [self.progressBar setValue:progressValue animated:YES];
    }
}

@end
