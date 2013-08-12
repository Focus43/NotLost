//
//  LBMGTopToursNearYouTBVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTopToursNearYouTBVC.h"
#import "LBMGYourLibraryTBVC.h"
#import "TourSection.h"
#import "TourPlace.h"
#import "TourDetail.h"
#import "TourData.h"
#import "LBMGTopTourCell.h"

@interface LBMGTopToursNearYouTBVC ()

@end

@implementation LBMGTopToursNearYouTBVC

static NSString *topTourCellIdentifier = @"LBMGTopTourCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // if there are no available tours try downloading the tour list - this could happen if they user gets
    // to the your library screen before the tours list finishes downloading on the Tour Library screen
    if (self.availableTours.tourData.count == 0) {
        [ApplicationDelegate.lbmgEngine getNearbyToursWithLatitude:self.locationManager.location.coordinate.latitude andLongitude:self.locationManager.location.coordinate.longitude contentBlock:^(NSArray *responseArray) {
            [SVProgressHUD dismiss];
            NSDictionary *tourData = [NSDictionary dictionaryWithObject:responseArray forKey:@"TourData"];
            self.availableTours = [TourList instanceFromDictionary:tourData];
            [self createToursNearYouList];
            [self.tableView reloadData];
            
        }errorBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Tours Unavailable"];
            NSLog(@"ERROR");
        }];
        
        [self.locationManager stopUpdatingLocation];
    }
    else {
        [self createToursNearYouList];
    }
    
    UINib *cellNibDetail = [UINib nibWithNibName:@"LBMGTopTourCell" bundle:nil];
    [self.tableView registerNib:cellNibDetail forCellReuseIdentifier:topTourCellIdentifier];
}

- (void)createToursNearYouList {
    // create the list of top tours near you to display
    NSArray *IDList = [[NSArray alloc] init];
    
    IDList = [LBMGUtilities GetSavedTourIdPaths];
    
    NSMutableArray *topTours = [[NSMutableArray alloc] init];
    
    // for each section
    for (TourSection *section in self.availableTours.tourData) {
        // for each place
        for (TourPlace *place in section.places) {
            // for each tour
            for (TourDetail *tour in place.tours) {
                // only add a tour to the list if it has not been downloaded and is not currently downloading
                if (![LBMGUtilities tourDownloadingForID:tour.tourDetailId] && ![IDList containsObject:tour.tourDetailId]) {    // Not currently Downloading tour
                    [topTours addObject:tour];
                }
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedTopTours = [topTours sortedArrayUsingDescriptors:sortDescriptors];
    
    self.topToursNearYou = [[NSMutableArray alloc] initWithArray:sortedTopTours];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topToursNearYou count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LBMGTopTourCell *cell = [tableView dequeueReusableCellWithIdentifier:topTourCellIdentifier forIndexPath:indexPath];
    
    TourDetail *tour = self.topToursNearYou[indexPath.row];
    cell.titleLabel.text = tour.name;
    cell.subtitleLabel.text = tour.address;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f miles", [tour.distance floatValue]];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // start tour download and remove from this table view
    
    TourDetail *tour = self.topToursNearYou[indexPath.row];
    if (![LBMGUtilities tourDownloadingForID:tour.tourDetailId]) {    // Not currently Downloading tour
        [self.parentViewController fetchTourDetail:tour];
        [self.topToursNearYou removeObject:tour];
        [self.tableView reloadData];
    }
}

@end
