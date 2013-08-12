//
//  LBMGTourLibraryChildExpandingTVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourLibraryChildExpandingTVC.h"
#import "LBMGTourLibraryTBVCell.h"
#import "LBMGBaseTourMapVC.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGAppDelegate.h"
#import "LBMGTourLibraryTBVCell.h"
#import "LBMGUtilities.h"
#import "TourDetail.h"
#import "LBMGTourLibraryDetailTBVCell.h"
#import "LBMGTourTypeVC.h"
#import "TourPlace.h"
#import "PRPAlertView.h"
#import "LBMGTourLibraryChildTBVC.h"
#import "LBMGTourLibraryMasterPageVC.h"

@interface LBMGTourLibraryChildExpandingTVC ()

@property (strong, nonatomic) NSMutableArray *displayArray;
@property (strong, nonatomic) NSArray *oldIndexArray;

@end

@implementation LBMGTourLibraryChildExpandingTVC


static NSString *CellIdentifier = @"Cell";
static NSString *DetailCellIdentifier = @"DetailCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGTourLibraryTBVCell" bundle:nil];
    [self.toursTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    UINib *cellNibDetail = [UINib nibWithNibName:@"LBMGTourLibraryDetailTBVCell" bundle:nil];
    [self.toursTableView registerNib:cellNibDetail forCellReuseIdentifier:DetailCellIdentifier];
    self.view.layer.mask = self.maskingLayerView.layer;
    
    self.currentOpenIndex = -1;
    [self rebuildDisplayArray];
//    [self.toursTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadComplete:)
                                                 name:LBMGUtilitiesDownloadComplete
                                               object:nil];

    if ([self.displayArray count] == 1) {
        NSIndexPath *firstItemIP = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.toursTableView selectRowAtIndexPath:firstItemIP animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.toursTableView.delegate tableView:self.toursTableView didSelectRowAtIndexPath:firstItemIP];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setSelectedRow];
}

- (void)downloadComplete:(NSNotification*)notification {
    
    [self.toursTableView reloadData];
    [self setSelectedRow];
}


//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displayArray.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 40;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.displayArray[indexPath.row] isKindOfClass:[TourPlace class]]) {
        LBMGTourLibraryTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        TourPlace *place = self.displayArray[indexPath.row];
        cell.tourNameLabel.text = place.placeName;
        cell.tourNameLabel.textAlignment = NSTextAlignmentLeft;
        //    cell.tourTime.text = [NSString stringWithFormat:@"%@ miles", self.times[indexPath.row]];
        return cell;
    } else {
        LBMGTourLibraryDetailTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
        
        TourDetail *tour = self.displayArray[indexPath.row];
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
        } else if ([LBMGUtilities tourExistsForID:tour.tourDetailId]) {
            cell.typeIcon.image = [UIImage imageNamed:@"disclosureicon"];
        }
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.displayArray[indexPath.row] isKindOfClass:[TourPlace class]]) {
        int itemIndex = [self.places indexOfObject:self.displayArray[indexPath.row]];
        if (itemIndex != self.currentOpenIndex) {
            self.currentOpenIndex = itemIndex;
        } else {
            self.currentOpenIndex = -1;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [self rebuildDisplayArray];

        //        [tableView reloadData];
    } else {
        
        TourDetail *tour = self.displayArray[indexPath.row];
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
            } else if ([LBMGUtilities tourExistsForID:tour.tourDetailId]) {
                
                [self startTour:tour atRow:indexPath.row];
                [self.masterVC removeRefreshTimer];
                
            } else {     // No tour yet. Can start initial download
                
                [self fetchTourDetail:tour];                
            }        
        }
        [self setSelectedRow];
    }
}

- (void)fetchTourDetail:(TourDetail *)tour {
    
    [SVProgressHUD showWithStatus:@"Loading Tour Details"];
    [ApplicationDelegate.lbmgEngine getTourWithID:[tour.tourDetailId intValue] latitude:39.745342 longitude:-104.994707 contentBlock:^(NSDictionary *responseDict) {
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
            [ApplicationDelegate.lbmgEngine logTourDownloadWithId:tour.tourDetailId latitude:self.userLatitude andLongitude:self.userLongitude contentBlock:^(NSDictionary *dictionary) {
                DLog(@"%@", dictionary);
            } errorBlock:^(NSError *error) {
                DLog(@"ERROR logging tour download");
            }];
            [self.toursTableView reloadData];
            [self setSelectedRow];
            
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

- (void)startTour:(TourDetail *)tour atRow:(NSInteger)row
{
    TourPlace *selectedPlace = [self.places objectAtIndex:self.currentOpenIndex];
    int selectedIndex = row - self.currentOpenIndex - 1;
    TourDetail *detailedTour = [selectedPlace.tours objectAtIndex:selectedIndex];
    LBMGTourTypeVC *typeController = [LBMGTourTypeVC new];
    typeController.tourID = tour.tourDetailId;
    typeController.place = selectedPlace;
    typeController.tourDetail = detailedTour;
    typeController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[(LBMGAppDelegate *)[[UIApplication sharedApplication] delegate] viewController] presentViewController:typeController animated:YES completion:nil];
}

- (void)rebuildDisplayArray {
    
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.places.count];
    NSMutableArray *newIndexArray = [NSMutableArray arrayWithCapacity:5];
    int i = 0;
    for (TourPlace *place in self.places) {
        [newArray addObject:place];
        if (i == self.currentOpenIndex) {
            int j = i+1;
            for (TourDetail *tour in place.tours) {
                [newArray addObject:tour];
                [newIndexArray addObject:[NSIndexPath indexPathForItem:j inSection:0]];
                j++;
            }
        }
        i++;
    }
    self.displayArray = newArray;
    
    NSArray *deleteIndexPaths = self.oldIndexArray;
    NSArray *insertIndexPaths = newIndexArray;
    UITableView *tv = self.toursTableView;
    
    [tv beginUpdates];
        [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        [tv deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [tv endUpdates];
    self.oldIndexArray = newIndexArray;    
}


#pragma mark - Buttons

- (IBAction)backButtonTouched:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.scroller.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self.previousPage deselectCurrentRow];
        self.previousPage.inSubview = NO;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Helpers

- (void)setSelectedRow {
    [self.toursTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentOpenIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}


- (void)setPlaces:(NSArray *)places {
    if (_places != places) {
        _places = places;
        [self rebuildDisplayArray];
        [self.toursTableView reloadData];
        [self setSelectedRow];
    }
}

@end