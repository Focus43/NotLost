//
//  LMGMainMapViewController.h
//  TourGuide
//
//  Created by Paul Warren on 8/30/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MWPhotoBrowser.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
	Unvisited,
	Visited,
    Clear,
} pinOptions;

@class Route;


@interface LMGMainMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MWPhotoBrowserDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) IBOutlet UIButton *NotesButton;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *tourName;
@property (weak, nonatomic) IBOutlet UILabel *tourDescription;
@property (weak, nonatomic) IBOutlet UIView *progressContainer;
@property (weak, nonatomic) IBOutlet UIView *directionsContainer;
@property (weak, nonatomic) IBOutlet UIView *endTourView;

- (IBAction)NextSection:(id)sender;
- (IBAction)PreviousSection:(id)sender;
- (IBAction)photoButtonTouched:(id)sender;
- (IBAction)videoButtonTouched:(id)sender;
- (IBAction)notesButtonTouched:(id)sender;
- (IBAction)startTourButton:(id)sender;
- (IBAction)exitButtonTouched:(id)sender;
 
@end
