//
//  LMGMainMapViewController.h
//  TourGuide
//
//  Created by Alan Smithee on 8/30/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TourRoute.h"
#import <AVFoundation/AVFoundation.h>
#import "ALRadialMenu.h"
#import "LBMGCurrentTour.h"
#import "PoiPoint.h"

typedef enum {
	Unvisited,
	Visited,
    Clear
} poiState;

typedef enum {
	poi,
	personal,
    userLocation
} pinTypes;

@class Route;
@class BDAPAudioPlayer;
@class MediaPoint;
@class TourData;
@class TourPoint;
@class LBMGTourTypeVC;

@interface LBMGBaseTourMapVC : LBMGNoRotateViewController <MKMapViewDelegate, CLLocationManagerDelegate, MKOverlay, AVAudioPlayerDelegate, ALRadialMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) LBMGCurrentTour *currentTour;

//@property (nonatomic, strong) MKPolyline* routeLine;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *mediaCircles;
@property (strong, nonatomic) NSMutableArray *poiCircles;

@property (nonatomic, strong) MKPolyline* navLine;
@property (nonatomic, strong) MKPolygon* pathRect;

@property (nonatomic, strong) MKPolygonView* pathRectView;
@property (nonatomic, strong) MKPolylineView* routeLineView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) MediaPoint *currentMediaPoint;
@property (strong, nonatomic) MediaPoint *previousMediaPoint;
@property (strong, nonatomic) MKCircle *currentMediaCircle;

@property (nonatomic) int variance;
@property (nonatomic) int courseVariance;
@property (nonatomic) BOOL offRoute;
@property (nonatomic) BOOL withinPointRadius;

// user content
@property (nonatomic) BOOL isNearUserContent;

// progress bar
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (weak, nonatomic) IBOutlet UIView *progressContainer;

// header buttons
@property (weak, nonatomic) IBOutlet UIButton *tourCompleteButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;

// media button outlets
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *aroundMeButton;
@property (weak, nonatomic) IBOutlet UIButton *personalButton;
@property (weak, nonatomic) IBOutlet UIButton *navButton;
@property (strong, nonatomic) ALRadialMenu *radialMenu;

// audio 
@property (strong, nonatomic) BDAPAudioPlayer *audioPlayer;
@property (strong, nonatomic) BDAPAudioPlayer *mediaAudioPlayer;
@property (nonatomic, assign) BOOL isPlayingMediaAudio;
@property (nonatomic, assign) BOOL isPlayingNavAudio;
@property (nonatomic, copy) NSString *playingAudioName;
// test data output
@property (weak, nonatomic) IBOutlet UIView *testOutputView;
@property (weak, nonatomic) IBOutlet UILabel *latitudeDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseEntryLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeDistLabel;
@property (weak, nonatomic) IBOutlet UILabel *waypointLabel;
@property (weak, nonatomic) IBOutlet UILabel *varianceLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseVarianceLabel;

// direction header outlets
@property (weak, nonatomic) IBOutlet UIView *directionsContainer;
@property (weak, nonatomic) IBOutlet UIImageView *directionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *directionsBackgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) NSMutableArray *currentUserContent;
@property (nonatomic) int personalContentIndexPassed;
@property (nonatomic) CLLocationDegrees latitudeForPersonalContentHit;
@property (nonatomic) CLLocationDegrees longitudeForPersonalContentHit;

@property (weak, nonatomic) UIScrollView *scroller;
@property (strong, nonatomic) LBMGTourTypeVC *tourMC;
@property (assign, nonatomic) BOOL playedAudio;

// sectioning data
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *currentSection;
@property (nonatomic) int navIndex;
@property (nonatomic, strong) MKPolylineView *navLineView;

// used to determine which annotation to show as ticked
@property (nonatomic, strong) MKAnnotationView *currentlySelectedAnnotation;

// IBActions
- (IBAction)exitButtonTouched:(id)sender;

- (IBAction)videoButtonPressed:(id)sender;
- (IBAction)photoButtonPressed:(id)sender;
- (IBAction)tourCompleteButtonPressed:(id)sender;
- (IBAction)tourInfoButtonPressed:(id)sender;
- (IBAction)personalButtonPressed:(id)sender;

- (IBAction)varianceChanged:(id)sender;
- (IBAction)courseVarianceChanged:(id)sender;

// set up
- (void)setupLocationManagerAndMap;
- (void)stopLocationManagerAndMap;
- (void)updateAnnotations;

// new location handling
- (void)handleNewLocation:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)processPOILocation:(CLLocation *)newLocation;
- (void)processPersonalContentLocation:(CLLocation *)newLocation;
- (void)processMediaLocation:(CLLocation *)newLocation;
- (BOOL)checkForOutOfArea:(CLLocation *)newLocation;
- (void)activateWayPoint:(TourPoint *)point;

- (BOOL)mapCircleContainsPoint:(MKCircle *)circle withPoint:(CLLocation *)point;
- (void)blinkBackgroundColor:(UIColor *)color ForView:(UIView *)view;
- (void)playMediaAudioFileNamed:(NSString *)name;

- (double)getLatitude;
- (double)getLongitude;
- (int)getLastPointPassed;

- (IBAction)toggleDebugView:(id)sender;
- (void)silenceAudio;

- (void)showPOIMessageForNRBTours:(PoiPoint *)currentPOI;

- (void)switchToNextSection;

@end
