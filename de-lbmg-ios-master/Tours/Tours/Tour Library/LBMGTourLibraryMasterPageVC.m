//
//  LBMGTourLibraryMasterPageVC.m
//  Tours
//
//  Created by Alan Smithee on 3/27/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourLibraryMasterPageVC.h"
#import "LBMGTourLibraryChildTBVC.h"
#import <QuartzCore/QuartzCore.h>
#import "TourList.h"
#import "LBMGYourLibraryTBVC.h"
#import "TapIt.h"

// This is the TEST zone id for the Interstitial Example
// go to http://ads.tapit.com/ to get your's
#define ZONE_ID @"30784"


// refreshes every 5 minutes = 300 seconds
const float autoRefreshInterval = 300.0;

@interface LBMGTourLibraryMasterPageVC ()

@property (strong, nonatomic) LBMGTourLibraryChildTBVC *routeTBVC;
@property (strong, nonatomic) TourList *tourList;

@property (strong, nonatomic) TapItInterstitialAd *interstitialAd;

@end

@implementation LBMGTourLibraryMasterPageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pagedScrollView.contentSize = CGSizeMake(1000, self.pagedScrollView.frame.size.height);
    [self startLocationServices];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadComplete:)
                                                 name:LBMGUtilitiesDownloadComplete
                                               object:nil];
    [self loadInterstitial];
}

- (void)loadInterstitial
{
    self.interstitialAd = [[TapItInterstitialAd alloc] init];
    self.interstitialAd.delegate = self;
    self.interstitialAd.animated = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            //                            @"test", @"mode", // enable test mode to test banner ads in your app
                            nil];
    TapItRequest *request = [TapItRequest requestWithAdZone:ZONE_ID andCustomParameters:params];
//    AppDelegate *myAppDelegate = (AppDelegate *)([[UIApplication sharedApplication] delegate]);
//    [request updateLocation:myAppDelegate.locationManager.location];
    [self.interstitialAd loadInterstitialForRequest:request];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateYourLibraryButton];
}

- (void)displayRoute {
    // build first Level TableView
    if (!self.routeTBVC) {
        self.routeTBVC = [LBMGTourLibraryChildTBVC new];
        self.routeTBVC.scroller = self.pagedScrollView;
        
        CGRect childFrame = self.routeTBVC.view.frame;
        childFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
        self.routeTBVC.view.frame = childFrame;
        
        [self.pagedScrollView insertSubview:self.routeTBVC.view atIndex:0];
        self.routeTBVC.masterVC = self;
    }
    self.routeTBVC.tourList = self.tourList;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.lastRefreshTime];
    if (interval >= 300 || !self.tourList) {
        [self getData];
    }
    else {
        [self setNextDataRefresh];
    }
}

- (void)scrolledIntoView
{
    [self loadInterstitial];
}



- (void)removeRefreshTimer {
    [self.dataRefreshTimer invalidate];
}

- (void)updateYourLibraryButton {
    NSArray *savedList = [LBMGUtilities GetSavedTourIdPaths];
    if (savedList.count > 0) {
        self.yourLibraryButton.hidden = NO;
    } else {
        self.yourLibraryButton.hidden = YES;
    }
}

- (void)startLocationServices {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // 1 Kilometer
    [self.locationManager startUpdatingLocation];
}

-(void)getData
{
    [SVProgressHUD showWithStatus:@"Loading Tours"];
    [ApplicationDelegate.lbmgEngine getNearbyToursWithLatitude:self.locationManager.location.coordinate.latitude andLongitude:self.locationManager.location.coordinate.longitude contentBlock:^(NSArray *responseArray) {
        NSLog(@"%@", responseArray);
        [SVProgressHUD dismiss];
        NSDictionary *tourData = [NSDictionary dictionaryWithObject:responseArray forKey:@"TourData"];
        self.tourList = [TourList instanceFromDictionary:tourData];
        [self displayRoute];
        
        self.lastRefreshTime = [NSDate date];
        [self setNextDataRefresh];
        
    }errorBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Tours Unavailable"];
        NSLog(@"ERROR");
        [self setNextDataRefresh];
    }];
    [self.locationManager stopUpdatingLocation];

}

- (void)setNextDataRefresh {
    [self.dataRefreshTimer invalidate];
    self.dataRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:autoRefreshInterval target:self selector:@selector(getData) userInfo:nil repeats:NO];
}

- (IBAction)yourLibraryTouched:(id)sender {

    LBMGYourLibraryTBVC *yourLibrary = [LBMGYourLibraryTBVC new];
    yourLibrary.availableTours = self.tourList;
    yourLibrary.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    yourLibrary.locationManager = self.locationManager;
    [self presentViewController:yourLibrary animated:YES completion:^{
        DLog(@"Presented");
    }];
    [self removeRefreshTimer];
}

- (IBAction)refreshTouched:(id)sender {
    [self getData];
}

#pragma mark - Notification Methods

- (void)downloadComplete:(NSNotification*)notification {
    [self updateYourLibraryButton];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - scrolview delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0) {
        self.RefreshButton.hidden = YES;
    } else {
        self.RefreshButton.hidden = NO;
    }
}

#pragma mark -
#pragma mark TapItInterstitialAdDelegate methods

- (void)tapitInterstitialAd:(TapItInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
//    [self updateUIWithState:StateError];
}

- (void)tapitInterstitialAdDidUnload:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad did unload");
//    [self updateUIWithState:StateNone];
    self.interstitialAd = nil; // don't reuse interstitial ad!
}

- (void)tapitInterstitialAdWillLoad:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad will load");
}

- (void)tapitInterstitialAdDidLoad:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad did load");
//    [self.interstitialAd presentFromViewController:self];
    if (!interstitialAd.presentingController) {
        [self.interstitialAd presentFromViewController:self];
    }
//    [self updateUIWithState:StateReady];
}

- (BOOL)tapitInterstitialAdActionShouldBegin:(TapItInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Ad action should begin");
    return YES;
}

- (void)tapitInterstitialAdActionDidFinish:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad action did finish");
}


@end
