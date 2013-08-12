//
//  LMGMainMapViewController.m
//  TourGuide
//
//  Created by Paul Warren on 8/30/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#define TOUCHED_POINTS @"TouchedPoints"
#define DURATION 0.4


#import "LMGMainMapViewController.h"
#import "Route.h"
#import "OutlineRoute.h"
#import "WayPoint.h"
#import "PRPAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "XCRPointAnnotation.h"
#import "Photo.h"
#import "BDAPAudioPlayer.h"


@interface LMGMainMapViewController ()
{
    int navIndex;
    CGFloat progress;
    NSTimeInterval mediaAudioDuration;
}

@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolyline* navLine;
@property (nonatomic, strong) MKPolygon* pathRect;
@property (nonatomic, strong) MKPolygonView* pathRectView;
@property (nonatomic, strong) MKPolylineView* routeLineView;
@property (nonatomic, strong) MKPolylineView* navLineView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) WayPoint *fromPoint;
@property (strong, nonatomic) WayPoint *toPoint;
@property (strong, nonatomic) WayPoint *currentPOI;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *CurrentSection;
@property (strong, nonatomic) NSMutableArray *navCircles;
@property (strong, nonatomic) NSMutableArray *mediaCircles;
@property (strong, nonatomic) NSArray *sectionCircles;
@property (assign, nonatomic) MKMapRect routeRect;
@property (assign, nonatomic) BOOL directionsWanted;
@property (assign, nonatomic) BOOL showingAlert;
@property (strong, nonatomic) BDAPAudioPlayer *audioPlayer;
@property (strong, nonatomic) BDAPAudioPlayer *mediaAudioPlayer;
@property (strong, nonatomic) MKCircle *currentCircle;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *touchedPoints;
@property (nonatomic, assign) MKMapRect currentWayRect;
@property (nonatomic, assign) int highestIndex;
@property (nonatomic, assign) int removedIndex;
@property (nonatomic, weak) WayPoint *lastPoint1;
@property (nonatomic, weak) WayPoint *lastPoint2;
@property (nonatomic, weak) WayPoint *lastPoint3;
@property (nonatomic, weak) WayPoint *lastPoint4;
@property (nonatomic, assign) BOOL isPlayingMediaAudio;
@property (nonatomic, assign) BOOL isPlayingNavAudio;



@end

@implementation LMGMainMapViewController
@synthesize messageLabel = _messageLabel;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.progressBar setThumbImage:[UIImage imageNamed:@"progressbar_handle"] forState:UIControlStateNormal];
    [self.progressBar setMinimumTrackImage:[UIImage imageNamed:@"progressbar_front"] forState:UIControlStateNormal];
    [self.progressBar setMaximumTrackImage:[UIImage imageNamed:@"progressbar_maximum"] forState:UIControlStateNormal];

    self.isPlayingMediaAudio = NO;
    self.isPlayingNavAudio = NO;
	self.highestIndex = 0;
	// create the overlay
	[self loadRoute];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults arrayForKey:TOUCHED_POINTS]) {
        self.touchedPoints = [NSMutableArray arrayWithArray:[defaults arrayForKey:TOUCHED_POINTS]];
    }
    if (self.touchedPoints.count != self.route.wayPoints.count) {
        [self clearTouchPoints];
    }
    [self buildSections];
    [self buildMediaCircles];
	
    self.toPoint = [self.route.wayPoints objectAtIndex:0];
	
//    [self setupCoreLocation];
    
	// zoom in on the route.
	[self zoomInOnRoute];
    
    self.removedIndex = 0;
    navIndex = 0;
    [self nextRoute];
    
    [self.mapView addOverlay:self.routeLine];
    self.directionsWanted = YES;
    self.showingAlert = NO;
    
    [self pushRightSideButton:self.photoButton on:NO animated:NO];
    [self pushRightSideButton:self.videoButton on:NO animated:NO];
    [self pushRightSideButton:self.NotesButton on:NO animated:NO];
    
    self.tourName.text = self.route.routeName;
    self.tourDescription.text = self.route.descriptionText;
    
    [self.view addSubview:self.coverView];
    self.progressContainer.transform = CGAffineTransformMakeTranslation(0, -self.progressContainer.bounds.size.height);
    self.directionsContainer.transform = CGAffineTransformMakeTranslation(0, self.directionsContainer.bounds.size.height);
    
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryLevelDidChangeNotification" object:device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:device];
}

- (void)batteryChanged:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    DLogS(@"State: %i Charge: %f", device.batteryState, device.batteryLevel);
    if (device.batteryLevel > 0.4) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    } else {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)clearTouchPoints {
    
    self.touchedPoints = [[NSMutableArray alloc] initWithCapacity:self.route.wayPoints.count];
    for (WayPoint *way in self.route.wayPoints) {
        [self.touchedPoints addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)nextRoute {
    
    if (navIndex < self.sections.count) {
        self.CurrentSection = [self.sections objectAtIndex:navIndex];
        self.fromPoint = [self.CurrentSection objectAtIndex:0];
        self.toPoint = [self.CurrentSection lastObject];
        [self navRoute];
        
        [self.mapView removeAnnotations:[self.mapView annotations]];
        
        int i = 0;
        for (NSNumber *touched in self.touchedPoints) {
            WayPoint *way = [self.route.wayPoints objectAtIndex:i];
            if (way.poi) {
                XCRPointAnnotation *fromPin = [XCRPointAnnotation new];
                fromPin.coordinate = CLLocationCoordinate2DMake([way.latitude doubleValue], [way.longitude doubleValue]);
                fromPin.title = way.name;
            
                if ([touched boolValue]) {
                    fromPin.tag = Visited;
                    if (i > self.highestIndex) self.highestIndex = i; //  To define progress
                }
                [self.mapView addAnnotation:fromPin];
            }
            i++;
        }
        CGFloat sections = self.route.wayPoints.count;
        [self.progressBar setValue:self.highestIndex/sections animated:YES];
        
    }
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Switch to route %d", navIndex]];
}

- (void)setupCoreLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [self.locationManager startUpdatingLocation];
}


// Based on POIs being the Start and Endpoints of Sections

- (void)buildSections {
    
    NSMutableArray *newSections = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray *section = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *circles = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *sectCircles = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *circSection = [NSMutableArray arrayWithCapacity:1];
    
    int i = 0;
    for (WayPoint *way in self.route.wayPoints) {
        way.index = [NSNumber numberWithInt:i];
        [section addObject:way];
        MKCircle *circle = [self getCircleForLatitude:way.latitude andLogitude:way.longitude andMeters:way.radiusMeters];
        [circles addObject:circle];
        [circSection addObject:circle];
        if (way.poi) {
            if (way != [self.route.wayPoints lastObject]) {
                section = [NSMutableArray arrayWithCapacity:1];
                [newSections addObject:section];
                [section addObject:way];
                
                circSection = [NSMutableArray arrayWithCapacity:1];
                [sectCircles addObject:circSection];
                [circSection addObject:circle];
            }
            XCRPointAnnotation *toPin = [XCRPointAnnotation new];
            toPin.coordinate = CLLocationCoordinate2DMake([way.latitude doubleValue], [way.longitude doubleValue]);
            toPin.title = self.toPoint.name;
            toPin.tag = Unvisited;
            [self.mapView addAnnotation:toPin];
        }
        i++;
    }
    self.sections = [newSections copy];
    self.navCircles = circles;
    self.sectionCircles = [sectCircles copy];
}

- (void)buildMediaCircles {
    
    self.mediaCircles = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
    for (WayPoint *way in self.route.mediaPoints) {
        way.index = [NSNumber numberWithInt:i];
        MKCircle *circle = [self getCircleForLatitude:way.latitude andLogitude:way.longitude andMeters:way.radiusMeters];
        [self.mediaCircles addObject:circle];
        i++;
    }
}

// creates the route (MKPolyline) overlay
-(void) loadRoute
{
    MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
	
	// create a c array of points.
	MKMapPoint* pointArr = malloc(sizeof(MKMapPoint) * self.route.outlineRoute.count);
	
	for(int idx = 0; idx < self.route.outlineRoute.count; idx++)
	{
		OutlineRoute *coords = [self.route.outlineRoute objectAtIndex:idx];

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
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:self.route.outlineRoute.count];
    
    
    CGPoint area = CGPointMake(northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
	self.routeRect = MKMapRectMake(southWestPoint.x-area.x/2, southWestPoint.y-area.y/2, area.x*2, area.y*2);
    
	free(pointArr);	
}

- (void)navRoute
{
    // create a c array of points.
	MKMapPoint* pointArr = malloc(sizeof(MKMapPoint) * self.CurrentSection.count);
	
	for(int idx = 0; idx < self.CurrentSection.count; idx++) {
        
		OutlineRoute *coords = [self.CurrentSection objectAtIndex:idx];
        
		CLLocationDegrees latitude  = [coords.latitude doubleValue];
		CLLocationDegrees longitude = [coords.longitude doubleValue];
        
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
		pointArr[idx] = point;
    }
	
    // create the polyline based on the array of points.
    [self.mapView removeOverlay:self.navLine];
	self.navLine = [MKPolyline polylineWithPoints:pointArr count:self.CurrentSection.count];
    [self.mapView addOverlay:self.navLine];
        
	free(pointArr);
}

-(void) zoomInOnRoute
{
	[self.mapView setVisibleMapRect:self.routeRect];
}

#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
		if(nil == self.routeLineView)
		{
			self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
			self.routeLineView.strokeColor = [UIColor colorWithRed:0.000 green:0.000 blue:1.000 alpha:0.500];
			self.routeLineView.lineWidth = 10;
		}
		overlayView = self.routeLineView;
        
	} else if(overlay == self.navLine) {
    
        self.navLineView = [[MKPolylineView alloc] initWithPolyline:self.navLine];
        self.navLineView.strokeColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.000 alpha:0.600];
        self.navLineView.lineWidth = 14;
		overlayView = self.navLineView;
        
	} else if(overlay == self.pathRect) {
        
        self.pathRectView = [[MKPolygonView alloc] initWithPolygon:self.pathRect];
        self.pathRectView.strokeColor = [UIColor redColor];
        self.pathRectView.lineWidth = 5;
		overlayView = self.pathRectView;
	}

	return overlayView;
}

#pragma mark -
#pragma mark MapKit

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation)
    {		
		// make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude)) {
            NSTimeInterval age = abs([newLocation.timestamp timeIntervalSinceNow]);
            if( age > 60  ){
                DLogS(@" Old location just return.. ");
                return;
            }
            
            if (signbit(newLocation.horizontalAccuracy)) {
                // Negative accuracy means an invalid or unavailable measurement
                DLogS(@" Bad accuracy, ignore…");
            }
            else {
                // Valid measurement.
                [TestFlight passCheckpoint:[NSString stringWithFormat:@"New Valid Location=%@",newLocation]];
                
                [self processNewLocation:newLocation];
                [self processMediaLocation:newLocation];
            }
            
        }
    }
}

- (void)processNewLocation:(CLLocation *)newLocation {
    
    if (!MKMapRectContainsPoint(self.routeRect, MKMapPointForCoordinate(newLocation.coordinate))) {  // Not in main Location Rect
        [self checkForOutOfArea:newLocation];
        
    } else {
        WayPoint *way;
        
        for (int i = self.removedIndex; i < self.navCircles.count; i++) {
            MKCircle *circle = [self.navCircles objectAtIndex:i];
            if (MKMapRectContainsPoint([circle boundingMapRect], MKMapPointForCoordinate(newLocation.coordinate))) {
                // reached a waypoint
                int dependancy = i-1;
                if (way.dependancy) {
                    dependancy = i - [way.dependancy intValue];
                }
                if (dependancy < 0) dependancy = 0;
                if ([self.lastPoint1.index intValue] == dependancy ||
                    [self.lastPoint2.index intValue] == dependancy ||
                    [self.lastPoint3.index intValue] == dependancy ||
                    [self.lastPoint4.index intValue] == dependancy) {
                    // Fulfilled it dependancies
                    way = [self.route.wayPoints objectAtIndex:i];
                    [self adjustNavIndexForCircle:circle];
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"found Next waypoint - index = %d name = %@", i, way.name]];
                    self.removedIndex = i+1;
                    [self addNewWayToPrevList:[self.route.wayPoints objectAtIndex:i]];
                    [self.mapView setCenterCoordinate:newLocation.coordinate animated:YES];
               } else {
                   WayPoint *tempWay = [self.route.wayPoints objectAtIndex:i];
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Failed Dependancy - index = %d name = %@", i, tempWay.name]];

                   // look to see if outside of point to point area before logging Failed dependancy
                   if (!MKMapRectContainsPoint(self.currentWayRect, MKMapPointForCoordinate(newLocation.coordinate))) {
                       [self addNewWayToPrevList:[self.route.wayPoints objectAtIndex:i]];
                   }
                }
                break;
            }
        }
        if (way) {
            [self buildMapRectForPoints:way];
            if (way.name) {
                self.messageLabel.text = way.name;
                [self blinkBackgroundColor:[UIColor colorWithRed:1.000 green:0.741 blue:0.180 alpha:1.000] ForView:self.messageLabel];
            }
            if (way.audioItem) {
                [self playAudioFileNamed:way.audioItem];
            }
            if (way.poi) {   // Mark as visited and calculate next route
                
                
                int index = [self.route.wayPoints indexOfObject:way];
                NSNumber *visited = [self.touchedPoints objectAtIndex:index];
                if (![visited boolValue]) {
                    [self.touchedPoints replaceObjectAtIndex:[self.route.wayPoints indexOfObject:way] withObject:[NSNumber numberWithBool:YES]];
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setValue:self.touchedPoints forKey:TOUCHED_POINTS];
                    [defaults synchronize];
                }
                if (index+1 == self.navCircles.count) {
                    [self endOfRoute];
                } else {
                    [self nextRoute];
                }
                
                [TestFlight passCheckpoint:[NSString stringWithFormat:@"POI detected - index = %d", index]];
            }
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"Detected WayPoint - %@", way.name]];
        }
    }
}

- (void)endOfRoute {
    
    self.tourName.text = @"Tour Completed";
    self.tourDescription.text = @"Congratulations you have completed the tour\nIf you would like to restart the tour press the Begin button below";
    if (self.isPlayingMediaAudio) {
        [self.mediaAudioPlayer stopWithFadeDuration:0.3];
        self.isPlayingMediaAudio = NO;
    }
    [self showStartView];
    
}

- (void)addNewWayToPrevList:(WayPoint *)way {
    if (self.lastPoint1 != way) {
        DLog(@"last Point - %@", way.name);
        self.lastPoint4 = self.lastPoint3;
        self.lastPoint3 = self.lastPoint2;
        self.lastPoint2 = self.lastPoint1;
        self.lastPoint1 = way;
    }
}

- (void)processMediaLocation:(CLLocation *)newLocation {
    
        if (self.currentCircle) {
            if (!MKMapRectContainsPoint([self.currentCircle boundingMapRect], MKMapPointForCoordinate(newLocation.coordinate))) {  // Leave Current circle
                self.currentCircle = nil;
                [self pushRightSideButton:self.photoButton on:NO animated:YES];
                [self pushRightSideButton:self.videoButton on:NO animated:YES];
                [self pushRightSideButton:self.NotesButton on:NO animated:YES];
                [TestFlight passCheckpoint:@"Leaving Media WayPoint"];
            }
        } else {
            int i = 0;
            WayPoint *way;
            for (MKCircle *circle in self.mediaCircles) {
                if (MKMapRectContainsPoint([circle boundingMapRect], MKMapPointForCoordinate(newLocation.coordinate))) {
                    // reached a waypoint
                    way = [self.route.mediaPoints objectAtIndex:i];
                    self.currentCircle = circle;
//                    [self adjustNavIndexForCircle:circle];
                    [TestFlight passCheckpoint:@"Detected Media WayPoint"];
                    break;
                }
                i++;
            }
            if (way) {
                self.currentPOI = way;
                if (way.audioItem) {
                    [self playMediaAudioFileNamed:way.audioItem];
                }
                [self showButtonsForWay:way];
                [TestFlight passCheckpoint:[NSString stringWithFormat:@"Detected MediaPoint - %@", way.name]];
                
            } else {
                //                self.messageLabel.text = @"";
            }
        }
//    }
}

- (void)checkForOutOfArea:(CLLocation *)newLocation {
    if (self.directionsWanted && !self.showingAlert) {
        self.showingAlert = YES;
        [PRPAlertView showWithTitle:@"Guide to Start"
                            message:@"Would you like to switch to the Maps App to guide you to the start point"
                        cancelTitle:@"No"
                        cancelBlock:^(void) {
                            self.directionsWanted = NO;
                            self.showingAlert = NO;
                        }
                         otherTitle:@"YES"
                         otherBlock:^(void) {
                             self.showingAlert = NO;
                             CLLocationDegrees latitude  = [self.fromPoint.latitude doubleValue];
                             CLLocationDegrees longitude = [self.fromPoint.longitude doubleValue];
                             
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
                         }];
    } else {
        self.messageLabel.text = @"Out Of Area";
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"Switch to route %d", navIndex]];
    }
}

- (void)adjustNavIndexForCircle:(MKCircle *)circle {
    
    int i = 0;
    for (NSArray *sectCircles in self.sectionCircles) {
        for (MKCircle *circleInSection in sectCircles) {
            if (circleInSection == circle) {
                navIndex = i;
//                [self nextRoute];
            }
        }
        i++;
    }
}

- (void)buildMapRectForPoints:(WayPoint *)way {
    
    double pointMeter = MKMapPointsPerMeterAtLatitude(way.latitude.doubleValue)*20;  //  20 Meters either side
    
    MKMapPoint point = [self mapPointFromWay:way];
    
    self.CurrentSection = [self.sections objectAtIndex:navIndex];
    int index = [self.CurrentSection indexOfObject:way];
    DLog(@"way @ index %d of %d", index, self.CurrentSection.count);
    if (index > self.CurrentSection.count-2) return;
    
    WayPoint *next = [self.CurrentSection objectAtIndex:index+1];
    MKMapPoint nextPoint = [self mapPointFromWay:next];
    
    double lowX = fmin(point.x, nextPoint.x)-pointMeter;
    double lowY = fmin(point.y, nextPoint.y)-pointMeter;
    double width = fabs(point.x - nextPoint.x)+pointMeter*2;
    double height = fabs(point.y - nextPoint.y)+pointMeter*2;
    
    
    self.currentWayRect = MKMapRectMake (lowX, lowY, width, height);
    DLog(@"Built new Section - navindex = %d", navIndex);

//	MKMapPoint* pointArr = malloc(sizeof(MKMapPoint) * self.CurrentSection.count);
//	
//    pointArr[0] = MKMapPointMake(lowX, lowY);
//    pointArr[1] = MKMapPointMake(lowX+width, lowY);
//    pointArr[2] = MKMapPointMake(lowX+width, lowY+height);
//    pointArr[3] = MKMapPointMake(lowX, lowY+height);
	
    // create the polyline based on the array of points.
//    [self.mapView removeOverlay:self.pathRect];
//	_pathRect = [MKPolygon polygonWithPoints:pointArr count:4];
//    [self.mapView addOverlay:self.pathRect];
//	free(pointArr);

}

- (MKMapPoint)mapPointFromWay:(WayPoint *)way {
    
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
        if(annotate.tag == Visited) {
            MKAnnotationView *pinView = nil;

            static NSString *defaultPinID = @"CustomTickAnnotationView";
            pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if (pinView == nil )
                pinView = [[MKAnnotationView alloc]
                           initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            pinView.canShowCallout = YES;
            pinView.centerOffset = CGPointMake(8, -15);
            pinView.image = [UIImage imageNamed:@"checkmark"];
            
            return pinView;
        } else if (annotate.tag == Unvisited) {
            // Try to dequeue an existing pin view first.
            MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
            
            if (!pinView)
            {
                // If an existing pin view was not available, create one.
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:@"CustomPinAnnotation"];
                pinView.pinColor = MKPinAnnotationColorRed;
                pinView.animatesDrop = YES;
                pinView.canShowCallout = YES;
                
            } else
                pinView.annotation = annotation;
            
            return pinView;
        }
    }
    
    return nil;
}

- (MKCircle *)getCircleForLatitude:(NSNumber *)latitudeNum andLogitude:(NSNumber *)longitudeNum andMeters:(NSNumber *)meters {
    
    CLLocationDegrees latitude  = [latitudeNum doubleValue];
    CLLocationDegrees longitude = [longitudeNum doubleValue];
 
    return [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius:[meters doubleValue]];
}

- (void)playAudioFileNamed:(NSString *)name {
    
    NSArray *parts = [name componentsSeparatedByString:@"."];
    
    if (parts.count < 2) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:[parts objectAtIndex:0]
                                         ofType:[parts objectAtIndex:1]]];

    [self.audioPlayer pause];
    self.audioPlayer = nil;
    NSError *error;
    self.audioPlayer = [[BDAPAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    if (!error) {
        self.isPlayingNavAudio = YES;
        if (self.isPlayingMediaAudio) {
            [self.mediaAudioPlayer fadeToVolume:0.0 duration:0.3 completion:^{
                [self.mediaAudioPlayer pause];
                [self.audioPlayer play];
            }];
        } else {
            [self.audioPlayer play];
        }
    }
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Starting New Audio - %@", name]];
}

- (void)playMediaAudioFileNamed:(NSString *)name {
    
    NSArray *parts = [name componentsSeparatedByString:@"."];
    
    if (parts.count < 2) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:[parts objectAtIndex:0]
                                         ofType:[parts objectAtIndex:1]]];
    
    [self.mediaAudioPlayer pause];
    self.mediaAudioPlayer = nil;
    NSError *error;
    self.mediaAudioPlayer = [[BDAPAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.mediaAudioPlayer.delegate = self;
    if (!error) {
        self.isPlayingMediaAudio = YES;
        [self.mediaAudioPlayer play];
        if (self.isPlayingNavAudio) {
            [self.mediaAudioPlayer pause];
        }
    }
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Starting New Audio - %@", name]];
}

- (void)showButtonsForWay:(WayPoint *)way {
//    if (way.poi) {
        if (way.photos) [self pushRightSideButton:self.photoButton on:YES animated:YES];
        if (way.videos) [self pushRightSideButton:self.videoButton on:YES animated:YES];
//        if (way.notes) [self pushRightSideButton:self.photoButton animated:YES];
//    }
}

- (void)pushRightSideButton:(UIButton *)button on:(BOOL)on animated:(BOOL)animated{
    
    CGPoint center = button.center;
    if (on & !button.tag) {
        center.x -= button.bounds.size.width;
        button.tag = 1;
    } else if (!on & button.tag) {
        center.x += button.bounds.size.width;
        button.tag = 0;
    }
    
    CGFloat duration = animated?0.5:0.0;
    [UIView animateWithDuration:duration animations:^{
        button.center = center;
    } completion:^(BOOL finished) {
        DLog(@"%@",button);
    }];    
}
                    
- (void)viewDidUnload {
    [self setMessageLabel:nil];
    [self setPhotoButton:nil];
    [self setVideoButton:nil];
    [self setNotesButton:nil];
    [self setProgressBar:nil];
    [self setCoverView:nil];
    [self setTourName:nil];
    [self setTourDescription:nil];
    [self setProgressContainer:nil];
    [self setDirectionsContainer:nil];
    [self setEndTourView:nil];
    [super viewDidUnload];
}

- (IBAction)NextSection:(id)sender {
    navIndex++;
    if (navIndex > self.sections.count-1) navIndex = 0;
    [self nextRoute];
}

- (IBAction)PreviousSection:(id)sender {
    navIndex--;
    if (navIndex < 0) navIndex = self.sections.count-1;
    [self nextRoute];
}

- (IBAction)photoButtonTouched:(id)sender {
    
    if (!self.currentPOI.photos.count) return;
    
    
    self.photos = [NSMutableArray array];
    
    for (Photo *nextPhoto in self.currentPOI.photos) {
        MWPhoto *photo;
        NSArray *parts = [nextPhoto.photo componentsSeparatedByString:@"."];
        NSString *extension = @"png";
        if (parts.count > 1) {
            extension = [parts objectAtIndex:1];
        }
        photo = [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:[parts objectAtIndex:0] ofType:extension]];
        if (nextPhoto.caption) photo.caption = nextPhoto.caption;
        [self.photos addObject:photo];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
    [browser setInitialPageIndex:0]; // Example: allows second image to be presented first
                                     // Present
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentModalViewController:nav animated:YES];
//    [self presentModalViewController:browser animated:YES];
}

- (IBAction)videoButtonTouched:(id)sender {


    if (!self.currentPOI.videos.count) return;
    
    NSArray *parts = [[self.currentPOI.videos objectAtIndex:0] componentsSeparatedByString:@"."];
    NSString *extension = @"MOV";
    if (parts.count > 1) {
        extension = [parts objectAtIndex:1];
    }
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:[parts objectAtIndex:0]
                      ofType:extension];
    if (path) {
        NSURL *url = [NSURL fileURLWithPath:path];
        MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentMoviePlayerViewControllerAnimated:movie];
    }
    
}

- (IBAction)notesButtonTouched:(id)sender {
    
}

- (IBAction)startTourButton:(id)sender {
    
    [UIView animateWithDuration:DURATION animations:^{
        self.coverView.transform = CGAffineTransformMakeTranslation(0, 190);
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [UIView animateWithDuration:DURATION animations:^{
            self.progressContainer.transform = CGAffineTransformMakeTranslation(0, 0);
            self.directionsContainer.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:^(BOOL finished) {
            self.tourName.text = self.route.routeName;
            self.tourDescription.text = self.route.descriptionText;
            if (self.locationManager) {
                [self.locationManager startUpdatingLocation];
            } else {
                [self setupCoreLocation];
            }
            self.messageLabel.text = @"seeking Location...";
        }];
    }];
    
}

- (IBAction)exitButtonTouched:(id)sender {
    [PRPAlertView showWithTitle:@"Restart Tour?"
                        message:@"Would you like to restart the tour?"
                    cancelTitle:@"No"
                    cancelBlock:^(void) {}
                    otherTitle:@"YES"
                    otherBlock:^(void) {
                        [self showStartView];
                    }];
}

- (void)showStartView {
    [self.locationManager stopUpdatingLocation];
    [self clearTouchPoints];
    self.removedIndex = 0;
    [self nextRoute];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.touchedPoints forKey:TOUCHED_POINTS];
    [defaults synchronize];
    self.progressBar.value = 0;
    [self.view addSubview:self.coverView];
    [UIView animateWithDuration:DURATION animations:^{
        self.progressContainer.transform = CGAffineTransformMakeTranslation(0, -self.progressContainer.bounds.size.height);
        self.directionsContainer.transform = CGAffineTransformMakeTranslation(0, self.directionsContainer.bounds.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:DURATION animations:^{
            self.coverView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

#pragma mark - AVAudioPlayer

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    if (player == self.mediaAudioPlayer) {
        self.isPlayingMediaAudio = NO;
    } else if (self.isPlayingMediaAudio) {
        self.isPlayingNavAudio = NO;
        [self.mediaAudioPlayer fadeToVolume:1.0 duration:0.3];
    } else {
        self.isPlayingNavAudio = NO;
    }
}


@end
