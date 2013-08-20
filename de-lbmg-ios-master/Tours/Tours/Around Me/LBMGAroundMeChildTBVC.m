//
//  LBMGAroundMeChildTBVC.m
//  Tours
//
//  Created by Paul Warren on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAroundMeChildTBVC.h"
#import "LBMGAroundMeCategoryTBVC.h"
#import "LBMGAroundMeChildExpandingTVC.h"
#import "LBMGTourLibraryTBVCell.h"
#import "EventCategories.h"
#import <QuartzCore/QuartzCore.h>
#import "LBMGSponsoredEventVC.h"
#import "Event.h"
#import "LBMGAppDelegate.h"
#import "LBMGMainMasterPageVC.h"
#import "Category.h"
#import "LBMGAroundMeMasterPageVC.h"

@interface LBMGAroundMeChildTBVC ()

@property (retain, nonatomic) LBMGAroundMeCategoryTBVC *childTBVC;

@end

@implementation LBMGAroundMeChildTBVC

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGTourLibraryTBVCell" bundle:nil];
    [self.eventsTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.view.layer.mask = self.maskingLayerView.layer;
    
}

#pragma mark - Tableview delegate/datasource

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGTourLibraryTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EventCategories *events = self.eventsArray[indexPath.row];
    cell.tourName = events.name;
    if ([events.distance intValue] < 1000) {
        cell.tourDistance = events.distance;
    }
//    cell.tourTime.text = [NSString stringWithFormat:@"%@ miles", self.times[indexPath.row]];
    
    [cell animateForDuration:1-1.0/indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentlySelectedRow = indexPath;
    EventCategories *events = self.eventsArray[indexPath.row];
    
    if (events.categories && events.categories.count) {
        self.childTBVC = [LBMGAroundMeCategoryTBVC new];
        self.childTBVC.scroller = self.scroller;
        self.childTBVC.places = events.categories;
        self.childTBVC.areaName = events.name;
        self.childTBVC.masterPage = self.masterPage;
        self.childTBVC.previousPage = self;
        
        CGRect childFrame = self.childTBVC.view.frame;
        childFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
        self.childTBVC.view.frame = childFrame;
        
        [self.scroller addSubview:self.childTBVC.view];
        self.childTBVC.view.frame = CGRectOffset(self.view.frame, 280, 0);
        self.scroller.contentSize = CGSizeMake(640, self.scroller.frame.size.height);
        [self.scroller setContentOffset:CGPointMake(280, 0) animated:YES];
        
        self.masterPage.titleLabel.text = events.name;
        
        // hide main nav and search buttons
        self.masterPage.mainVC.mainNavButton.hidden = YES;
        self.masterPage.searchButton.hidden = YES;
    }
}

- (void)deselectCurrentRow {
    [self.eventsTableView deselectRowAtIndexPath:self.currentlySelectedRow animated:YES];
}

@end
