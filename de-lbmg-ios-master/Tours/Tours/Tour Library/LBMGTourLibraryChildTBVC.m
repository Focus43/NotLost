


//
//  LBMGTourLibraryChildTBVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourLibraryChildTBVC.h"
#import "LBMGTourLibraryTBVCell.h"
#import "LBMGBaseTourMapVC.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGAppDelegate.h"
#import "LBMGTourLibraryTBVCell.h"
#import "LBMGUtilities.h"
#import "LBMGTourLibraryChildExpandingTVC.h"
#import "TourList.h"
#import "Tours.h"
#import "TourSection.h"
#import "LBMGTourLibraryMasterPageVC.h"


@interface LBMGTourLibraryChildTBVC ()

@property (retain, nonatomic) LBMGTourLibraryChildExpandingTVC *childTBVC;

@end

@implementation LBMGTourLibraryChildTBVC

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGTourLibraryTBVCell" bundle:nil];
    [self.tableViewController.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.view.layer.mask = self.maskingLayerView.layer;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.toursTableView selectRowAtIndexPath:self.selectedRow animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)reloadData {
    self.userLatitude = self.masterVC.locationManager.location.coordinate.latitude;
    self.userLongitude = self.masterVC.locationManager.location.coordinate.longitude;
    [self.masterVC getData];
    [self.tableViewController.refreshControl endRefreshing];
}

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tourList.tourData.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 40;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGTourLibraryTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    TourSection *section = self.tourList.tourData[indexPath.row];
    cell.tourName = section.sectionName;
    cell.tourDistance = section.distance;
//    cell.tourTime.text = [NSString stringWithFormat:@"%@ miles", self.times[indexPath.row]];
    
    [cell animateForDuration:1.0+(indexPath.row+1.0)/10];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // find the array for next level of routes
    // 
    TourSection *section = self.tourList.tourData[indexPath.row];
    
    if (section.places && section.places.count) {
        self.childTBVC = [LBMGTourLibraryChildExpandingTVC new];
        self.childTBVC.userLatitude = self.userLatitude;
        self.childTBVC.userLongitude = self.userLongitude;
        self.childTBVC.scroller = self.scroller;
        self.childTBVC.places = section.places;
        self.childTBVC.previousPage = self;
        self.childTBVC.masterVC = self.masterVC;
        
        CGRect childFrame = self.childTBVC.view.frame;
        childFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
        self.childTBVC.view.frame = childFrame;
        
        [self.scroller addSubview:self.childTBVC.view];
        self.childTBVC.view.frame = CGRectOffset(self.childTBVC.view.frame, 280, 0);
        self.scroller.contentSize = CGSizeMake(640, self.scroller.frame.size.height);
//        self.masterVC.RefreshButton.hidden = YES;
        [self.scroller setContentOffset:CGPointMake(280, 0) animated:YES];
        
        self.selectedRow = indexPath;
        self.inSubview = YES;
    }
}

- (void)setTourList:(TourList *)tourList {
    if (_tourList != tourList) {
        _tourList = tourList;
        if (!self.inSubview) {
            [self.tableViewController.tableView reloadData];
        }
        
        if (self.childTBVC) {
            TourSection *section = tourList.tourData[self.selectedRow.row];
            self.childTBVC.places = section.places;
        }
    }
}

- (void)deselectCurrentRow {
    [self.toursTableView deselectRowAtIndexPath:self.selectedRow animated:YES];
}

@end
