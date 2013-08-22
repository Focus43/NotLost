//
//  LBMGTourTypeViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/10/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourTypeVC.h"
#import "LBMGBaseTourMapVC.h"
#import "LBMGAppDelegate.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGRealTourMapVC.h"
#import "LBMGCurrentTour.h"
#import "LBMGVirtualTourMapVC.h"
#import <QuartzCore/QuartzCore.h>
#import "PRPAlertView.h"

@interface LBMGTourTypeVC ()

{
    CGFloat titleCenter;
    CGFloat detailCenter;
}

@end

@implementation LBMGTourTypeVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadCurrentTour];
    
    // Do any additional setup after loading the view from its nib.
    if (self.place.placeName) {
        self.titleLabel.text = self.place.placeName;
    } else {
        self.titleLabel.text = @"Your Content";
    }
    self.tourLabel.text = self.tourDetail.name;
    self.tourDetailsLabel.text = [NSString stringWithFormat:@"%i Points of Interest, %3.2f miles", [self.currentTour.route.poiPoints count], [self.tourDetail.distance floatValue]];
    
    self.scroller.pagingEnabled = YES;
    
    self.scroller.contentSize = CGSizeMake(640, self.scroller.frame.size.height);
    titleCenter = self.titleView.center.x;
    detailCenter = self.detailView.center.x;
    self.titleView.center = CGPointMake(titleCenter-self.titleView.bounds.size.width, self.titleView.center.y);
    self.detailView.center = CGPointMake(detailCenter+self.detailView.bounds.size.width, self.detailView.center.y);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 animations:^ {
        self.virtualTourButton.alpha = 1;
        self.realTourButton.alpha = 1;
        self.titleView.center = CGPointMake(titleCenter, self.titleView.center.y);
        self.detailView.center = CGPointMake(detailCenter, self.detailView.center.y);
        [self.view layoutIfNeeded];
    }];
}

- (void)loadCurrentTour {
    if (!self.currentTour) {
        self.currentTour = [[LBMGCurrentTour alloc] init];
        self.currentTour.tourID = self.tourID;
        [self.currentTour loadAndBuildData];
    }
}

#pragma mark - SwitchScreen Methods
- (void)switchToVirtualTour {
    self.currentTour.isRealTour = NO;
    
    self.virtualTour.tourStarted = YES;
    self.virtualTour.virtualPointPassedIndex = self.currentTour.lastPointPassedIndex;
    
    [self.scroller addSubview:self.virtualTour.view];
    [UIView transitionFromView:self.realTour.view toView:self.virtualTour.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

- (void)switchToRealTimeTour {
    self.currentTour.isRealTour = YES;
        
    [self.scroller addSubview:self.realTour.view];
    [UIView transitionFromView:self.virtualTour.view toView:self.realTour.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

- (void)goToTourEndView:(BOOL)complete {
    [self.scroller addSubview:self.tourEnd.view];
    self.tourEnd.tourComplete = complete;
    [self.tourEnd viewWillAppear:YES];
    [self push];
}

#pragma mark - IBActions
- (IBAction)virtualTourButtonPressed:(id)sender {
    if (self.currentTour.route.tourPoints.count != 0) {
        self.currentTour.isRealTour = NO;

        [self testForRetart:self.virtualTour];

//        [self addChildViewController:self.virtualTour];
//        [self.scroller addSubview:self.virtualTour.view];
//        [self push];
    }
    else {
        UIAlertView *tourError = [[UIAlertView alloc] initWithTitle:@"" message:@"Tour Incomplete" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [tourError show];
    }
}

- (IBAction)realTimeTourButtonPressed:(id)sender {
    if (self.currentTour.route.tourPoints.count != 0) {
        self.currentTour.isRealTour = YES;
        LBMGRealTourMapVC *testTour = self.realTour;
        [self testForRetart:testTour];
//        [self addChildViewController:self.virtualTour];
//        [self.scroller addSubview:self.realTour.view];
//        [self push];
    }
    else {
        UIAlertView *tourError = [[UIAlertView alloc] initWithTitle:@"" message:@"Tour Incomplete" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [tourError show];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Push/Pop
- (void)push {
    [UIView animateWithDuration:0.25 animations:^{
        self.scroller.contentOffset = CGPointMake(self.scroller.contentOffset.x + 320, 0);
    } completion:nil ];
}

- (void)popWithCompletionBlock:(void (^)(BOOL))block {
    [UIView animateWithDuration:0.25 animations:^{
        self.scroller.contentOffset = CGPointMake(self.scroller.contentOffset.x - 320, 0);
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    } completion:block];
}

#pragma mark - Property getters

- (LBMGVirtualTourMapVC *)virtualTour
{
    if (!_virtualTour) {
        _virtualTour = [LBMGVirtualTourMapVC new];
        _virtualTour.tourMC = self;
        _virtualTour.currentTour = self.currentTour;
        _virtualTour.scroller = self.scroller;
        _virtualTour.view.frame = CGRectOffset(self.view.bounds, 320, 0);
    }
    return _virtualTour;
}

- (LBMGRealTourMapVC *)realTour
{
    if (!_realTour) {
        _realTour = [LBMGRealTourMapVC new];
        _realTour.currentTour = self.currentTour;
        _realTour.tourMC = self;
        _realTour.address = self.tourDetail.address;
        _realTour.scroller = self.scroller;
        _realTour.title = self.place.placeName;
#warning set tour description!
//        _realTour.description = self.description;
        _realTour.view.frame = CGRectOffset(self.view.bounds, 320, 0);
    }
    return _realTour;
}

- (LBMGTourEndVC *)tourEnd {
    if (!_tourEnd) {
        _tourEnd = [LBMGTourEndVC new];
        _tourEnd.tourMC = self;
        _tourEnd.scroller = self.scroller;
        _tourEnd.tourName = self.tourLabel.text;
        _tourEnd.detailText = self.tourDetailsLabel.text;
        _tourEnd.view.frame = CGRectOffset(self.view.bounds, 2 * 320, 0);
    }
    return _tourEnd;
}

- (void)testForRetart:(UIViewController *)controller
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *storedIndex = [userDefaults objectForKey:[self.currentTour.tourID stringValue]];
    
    BOOL touched = NO;
    for (NSNumber *touchedPoint in self.currentTour.touchedPoints) {
        if ([touchedPoint boolValue]) {
            touched = YES;
            // TODO: break here to not keep going thru array
        }
    }
    if (touched) {
    
        [PRPAlertView showWithTitle:@"Continue or Restart?" message:@"Do you want to continue this tour or restart"
                        cancelTitle:@"Continue" cancelBlock:^{
                            [self startTour:controller];
                        } otherTitle:@"Restart" otherBlock:^{
                            [self resetTour];
                        }];
    } else {
        [self startTour:controller];
    }

}

- (void)startTour:(UIViewController *)controller
{
    [self addChildViewController:controller];
    [self.scroller addSubview:controller.view];
    [self push];

}

- (void)resetTour
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:[self.tourID stringValue]];
    [LBMGUtilities deleteTouchedPoisForID:self.tourID];
    if (self.currentTour.isRealTour) {
        [self.currentTour loadAndBuildData];
        self.realTour = nil;
        [self startTour:self.realTour];
    } else {
        [self.currentTour loadAndBuildData];
        self.virtualTour = nil;
        [self startTour:self.virtualTour];
    }
}


@end
