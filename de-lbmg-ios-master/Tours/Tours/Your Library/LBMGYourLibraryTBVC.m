//
//  LBMGYourLibraryTBVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGYourLibraryTBVC.h"
#import "LBMGTourLibraryDetailTBVCell.h"
#import "LBMGTourTypeVC.h"
#import "LBMGMainMasterPageVC.h"
#import "TourDetail.h"
#import "PRPAlertView.h"

@interface LBMGYourLibraryTBVC ()

@property (nonatomic, strong) NSArray *IDList;
@property (nonatomic, strong) NSArray *detailArray;

@end

@implementation LBMGYourLibraryTBVC

static NSString *DetailCellIdentifier = @"DetailCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNibDetail = [UINib nibWithNibName:@"LBMGTourLibraryDetailTBVCell" bundle:nil];
    [self.toursListTBLV registerNib:cellNibDetail forCellReuseIdentifier:DetailCellIdentifier];
    
    [self fetchYourTours];
    
    self.topToursNearYouTBVC = [[LBMGTopToursNearYouTBVC alloc] init];
    self.topToursNearYouTBVC.availableTours = self.availableTours;
    [self.topToursContainerView addSubview:self.topToursNearYouTBVC.view];
    [self addChildViewController:self.topToursNearYouTBVC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadComplete:)
                                                 name:LBMGUtilitiesDownloadComplete
                                               object:nil];
}

- (void)fetchYourTours {
    self.IDList = [LBMGUtilities GetSavedTourIdPaths];
    
    // If network not available fetch last used list of details
    self.detailArray = [LBMGUtilities getStoredTourDetails];
    [self.toursListTBLV reloadData];
    
    if (self.IDList.count) {
        [SVProgressHUD showWithStatus:@"Loading Updated List"];
        [ApplicationDelegate.lbmgEngine getTourDetailsWithIDs:self.IDList contentBlock:^(NSArray *responseArray) {
//          DLog(@"%@", responseArray);
            [SVProgressHUD dismiss];
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[responseArray count]];
            for (id valueMember in responseArray) {
                TourDetail *populatedMember = [TourDetail instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            
            self.detailArray = myMembers;
            [self.toursListTBLV reloadData];
        } errorBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Tour Details unavailable"];
            NSLog(@"ERROR");
        }];
    }
}

- (void)downloadComplete:(NSNotification*)notification {
    
    [self.toursListTBLV reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGTourLibraryDetailTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
    
    TourDetail *tour = self.detailArray[indexPath.row];
    cell.typeIcon.hidden = NO;
    cell.downloading = NO;
    [cell.activityIndicator stopAnimating];
    cell.tourNameLabel.text = tour.name;
    cell.tourAddress.text = [NSString stringWithFormat:@"%@ %3.2f miles", tour.address, [tour.distance floatValue]];
    if ([LBMGUtilities tourDownloadingForID:tour.tourDetailId]) {
        cell.tourAddress.text = @"Downloading";
        cell.typeIcon.hidden = YES;
        [cell.activityIndicator startAnimating];
        cell.downloading = YES;
        cell.tourID = tour.tourDetailId;
    }
    else if ([LBMGUtilities tourExistsForID:tour.tourDetailId]) {
        cell.typeIcon.image = [UIImage imageNamed:@"disclosureicon"];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TourDetail *tour = self.detailArray[indexPath.row];
    if (![LBMGUtilities tourDownloadingForID:tour.tourDetailId]) {    // Not currently Downloading tour
        
        CGFloat version = [tour.version floatValue];
        TourData *oldTourData = [LBMGUtilities getTourDataForTour:tour.tourDetailId];
        
        if (oldTourData.version && [oldTourData.version floatValue] != version) {  // New version request user to choose to re-download
            
            [PRPAlertView showWithTitle:@"New Version Available" message:@"A new version of this tour is available \n Would you like to download it now?"
                            cancelTitle:@"NO" cancelBlock:^{
                                [self startTour:tour atRow:indexPath.row];
                            } otherTitle:@"YES" otherBlock:^{
                                [self fetchTourDetail:tour];
                            }];
        }
        else if ([LBMGUtilities tourExistsForID:tour.tourDetailId]) {
            
            [self startTour:tour atRow:indexPath.row];
            [self removeRefreshTimer];
            
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.detailArray.count != 0 &&  indexPath.row <= (self.detailArray.count - 1)) {
        TourDetail *tour = self.detailArray[indexPath.row];
        if (![LBMGUtilities tourDownloadingForID:tour.tourDetailId]) {    // Not currently Downloading tour
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TourDetail *tour = self.detailArray[indexPath.row];
    if (![LBMGUtilities tourDownloadingForID:tour.tourDetailId]) {    // Not currently Downloading tour
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            TourDetail *rowToDelete = self.detailArray[indexPath.row];
            [LBMGUtilities deleteTourWithId:rowToDelete.tourDetailId];
            [LBMGUtilities removeTourDetails:tour];
            
            NSMutableArray *newList = [[NSMutableArray alloc] initWithArray:self.detailArray];
            [newList removeObjectAtIndex:indexPath.row];
            
            self.detailArray = newList;
            
            [self.toursListTBLV reloadData];
            [self.topToursNearYouTBVC createToursNearYouList];
            [self.topToursNearYouTBVC.tableView reloadData];
        }
    }
}

#pragma mark - IBActions
- (IBAction)backButtonTouched:(id)sender {
    self.locationManager = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        DLog(@"dismissed");
    }];
}

- (void)startTour:(TourDetail *)tour atRow:(NSInteger)row
{
    LBMGTourTypeVC *typeController = [LBMGTourTypeVC new];
    typeController.tourID = tour.tourDetailId;
    typeController.tourDetail = self.detailArray[row];
    typeController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:typeController animated:YES completion:^{
    }];
}

- (void)fetchTourDetail:(TourDetail *)tour {
    
    [self.toursListTBLV reloadData];
    
    [SVProgressHUD showWithStatus:@"Loading Tour Details"];
    [ApplicationDelegate.lbmgEngine getTourWithID:[tour.tourDetailId intValue] latitude:39.745342 longitude:-104.994707 contentBlock:^(NSDictionary *responseDict) {
        NSLog(@"%@", responseDict);
        TourData *newTourData = [TourData instanceFromDictionary:responseDict];
        [LBMGUtilities storeTourData:responseDict forId:tour.tourDetailId];
        
        if ([newTourData.assets_zip_url length] > 0) {
            [SVProgressHUD showSuccessWithStatus:@"Starting Download"];
            [LBMGUtilities downloadZippedDataForID:tour.tourDetailId atPath:newTourData.assets_zip_url withError:^(MKNetworkOperation * op, NSError * error) {
                [self showTourDownloadError];
                
                // remove invalid files
                [LBMGUtilities removeHangingDownloadFiles];
                [LBMGUtilities removeTourRoutePlist:tour.tourDetailId];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LBMGUtilitiesDownloadComplete
                                                                    object:nil
                                                                  userInfo:nil];
            }];
            [ApplicationDelegate.lbmgEngine logTourDownloadWithId:tour.tourDetailId latitude:0.0 andLongitude:0.0 contentBlock:^(NSDictionary *dictionary) {
                DLog(@"%@", dictionary);
            } errorBlock:^(NSError *error) {
                DLog(@"ERROR logging tour download");
            }];
            [self fetchYourTours];
            [self.toursListTBLV reloadData];
            
            [LBMGUtilities removeTourDetails:tour];
            [LBMGUtilities addNewTourDetails:tour];
        }
        else {
            [self showTourDownloadError];
            // remove invalid files
            [LBMGUtilities removeHangingDownloadFiles];
            [LBMGUtilities removeTourRoutePlist:tour.tourDetailId];
        }
    }errorBlock:^(NSError *error) {
        [self showTourDownloadError];
    }];
}

- (void)showTourDownloadError {
    [SVProgressHUD showErrorWithStatus:@"Download Unavailable"];
}

- (void)removeRefreshTimer {
    [self.dataRefreshTimer invalidate];
}

@end
