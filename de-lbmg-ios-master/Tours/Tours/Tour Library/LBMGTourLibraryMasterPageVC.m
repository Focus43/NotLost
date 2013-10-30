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

// refreshes every 5 minutes = 300 seconds
const float autoRefreshInterval = 300.0;

@interface LBMGTourLibraryMasterPageVC ()

@property (strong, nonatomic) LBMGTourLibraryChildTBVC *routeTBVC;
@property (nonatomic) BOOL eventHudIsShowing;

- (void)handleSimultaneousListingHUD:(NSNotification *)note;

@end

@implementation LBMGTourLibraryMasterPageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pagedScrollView.contentSize = CGSizeMake(1000, self.pagedScrollView.frame.size.height-self.adButton.frame.size.height);
    [self startLocationServices];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadComplete:)
                                                 name:LBMGUtilitiesDownloadComplete
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSimultaneousListingHUD:)
                                                 name:SVProgressHUDWillAppearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSimultaneousListingHUD:)
                                                 name:SVProgressHUDWillDisappearNotification
                                               object:nil];
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
    if ( !_eventHudIsShowing )
        [SVProgressHUD showWithStatus:@"Loading Tours"];
    
    [ApplicationDelegate.lbmgEngine getNearbyToursWithLatitude:self.locationManager.location.coordinate.latitude andLongitude:self.locationManager.location.coordinate.longitude contentBlock:^(NSArray *responseArray) {
//        NSLog(@"%@", responseArray);
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

- (IBAction)adButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.mcdonalds.com/us/en/promotions/premium_mcwrap.html"]];
}

#pragma mark - Notification Methods

- (void)downloadComplete:(NSNotification*)notification {
    [self updateYourLibraryButton];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleSimultaneousListingHUD:(NSNotification *)note
{
    if ( [note.name isEqualToString:@"SVProgressHUDWillAppearNotification"] && [[note.userInfo objectForKey:@"SVProgressHUDStatusUserInfoKey" ] isEqualToString:@"Loading Events"] ) {
        _eventHudIsShowing = YES;
    } else if ( [note.name isEqualToString:@"SVProgressHUDWillDisappearNotification"] && [[note.userInfo objectForKey:@"SVProgressHUDStatusUserInfoKey" ] isEqualToString:@"Loading Events"] ) {
       _eventHudIsShowing = NO;
    }
        
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

@end
