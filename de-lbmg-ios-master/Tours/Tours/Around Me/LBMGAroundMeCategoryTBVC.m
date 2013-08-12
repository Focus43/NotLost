//
//  LBMGAroundMeCategoryTBVC.m
//  Tours
//
//  Created by Paul Warren on 5/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAroundMeCategoryTBVC.h"
#import "LBMGAroundMeChildExpandingTVC.h"
#import "LBMGTourLibraryTBVCell.h"
#import "LBMGBaseTourMapVC.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGAppDelegate.h"
#import "LBMGUtilities.h"
#import "TourDetail.h"
#import "LBMGAroundMeCategoryCell.h"
#import "LBMGTourTypeVC.h"
//#import "TourPlace.h"
#import "LBMGSponsoredEventVC.h"
#import "Event.h"
#import "Category.h"
#import "EventSubCategory.h"
#import "LBMGAroundMeMasterPageVC.h"
#import "LBMGAroundMeChildTBVC.h"


@interface LBMGAroundMeCategoryTBVC ()

@property (retain, nonatomic) LBMGAroundMeChildExpandingTVC *childTBVC;
@property (strong, nonatomic) NSDictionary *favorites;

@end

@implementation LBMGAroundMeCategoryTBVC

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGAroundMeCategoryCell" bundle:nil];
    [self.toursTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.maskingLayerView.frame = self.view.frame;
    self.view.layer.mask = self.maskingLayerView.layer;
    
    self.favorites = [LBMGUtilities fetchFavorites];
    self.masterPage.tapitAd.hidden = NO;
    self.masterPage.tapitAd.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.masterPage.tapitAd.alpha = 1;
    }];
}

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGAroundMeCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Category *category = self.places[indexPath.row];
    cell.tourNameLabel.text = category.name;
    cell.tourNameLabel.textAlignment = NSTextAlignmentLeft;
    cell.areaName = self.areaName;
    cell.categoryName = category.name;
    cell.categoryID = category.categoryID;
    if ([self isFavorite:category.name]) {
        cell.favoriteButton.selected = YES;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath;
    
    Category *category = self.places[indexPath.row];
    
    if (category.subCategories && category.subCategories.count) {
        self.childTBVC = [LBMGAroundMeChildExpandingTVC new];
        self.childTBVC.scroller = self.scroller;
        self.childTBVC.places = category.subCategories;
        self.childTBVC.categoryName = category.name;
        self.childTBVC.areaName = self.areaName;
        self.childTBVC.masterPage = self.masterPage;
        self.childTBVC.previousPage = self;
        self.childTBVC.oldTitleText = self.masterPage.titleLabel.text;
        
        CGRect childFrame = self.childTBVC.view.frame;
        childFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
        self.childTBVC.view.frame = childFrame;
        
        [self.scroller addSubview:self.childTBVC.view];
        self.childTBVC.view.frame = CGRectOffset(self.childTBVC.view.frame, 560, 0);
        self.scroller.contentSize = CGSizeMake(960, self.scroller.frame.size.height);
        [self.scroller setContentOffset:CGPointMake(560, 0) animated:YES];
        
        NSString *masterText = self.masterPage.titleLabel.text;
        masterText = [masterText stringByAppendingString:[NSString stringWithFormat:@" - %@", category.name]];
        self.masterPage.titleLabel.text = masterText;
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (BOOL)isFavorite:(NSString *)categoryName
{
    NSString *keyName = [NSString stringWithFormat:@"%@+%@",self.areaName, categoryName];
    return (BOOL)[self.favorites objectForKey:keyName];
}

#pragma mark - Buttons

- (IBAction)backButtonTouched:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.scroller.contentOffset = CGPointMake(0, 0);
        self.masterPage.titleLabel.text = self.oldTitleText;
        self.masterPage.tapitAd.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self.previousPage deselectCurrentRow];
    }];
}

- (void)deselectCurrentRow {
    [self.toursTableView deselectRowAtIndexPath:self.selectedIndex animated:YES];
}

@end
