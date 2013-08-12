//
//  LBMGAroundMeChildExpandingTVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAroundMeChildExpandingTVC.h"
#import "LBMGTourLibraryTBVCell.h"
#import "LBMGBaseTourMapVC.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGAppDelegate.h"
#import "LBMGAroundMeCategoryCell.h"
#import "LBMGUtilities.h"
#import "TourDetail.h"
#import "LBMGTourLibraryDetailTBVCell.h"
#import "LBMGTourTypeVC.h"
//#import "TourPlace.h"
#import "LBMGSponsoredEventVC.h"
#import "LBMGEventVC.h"
#import "Event.h"
#import "Category.h"
#import "EventSubCategory.h"
#import "EventDescription.h"
#import "LBMGAroundMeFeaturedCell.h"
#import "LBMGAroundMeMasterPageVC.h"
#import "LBMGAroundMeCategoryTBVC.h"


@interface LBMGAroundMeChildExpandingTVC ()

@property (strong, nonatomic) NSMutableArray *displayArray;
@property (strong, nonatomic) NSArray *oldIndexArray;
@property (strong, nonatomic) NSDictionary *favorites;

@end

@implementation LBMGAroundMeChildExpandingTVC

static NSString *CellIdentifier = @"Cell";
static NSString *DetailCellIdentifier = @"DetailCell";
static NSString *FeaturedCellIdentifier = @"FeaturedCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGAroundMeCategoryCell" bundle:nil];
    [self.toursTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    UINib *cellNibDetail = [UINib nibWithNibName:@"LBMGTourLibraryDetailTBVCell" bundle:nil];
    [self.toursTableView registerNib:cellNibDetail forCellReuseIdentifier:DetailCellIdentifier];
    UINib *cellNibFeatured = [UINib nibWithNibName:@"LBMGAroundMeFeaturedCell" bundle:nil];
    [self.toursTableView registerNib:cellNibFeatured forCellReuseIdentifier:FeaturedCellIdentifier];
    
    self.view.layer.mask = self.maskingLayerView.layer;
    
    self.favorites = [LBMGUtilities fetchFavorites];

    self.currentOpenIndex = -1;
    [self rebuildDisplayArray];
    
    if ([self.displayArray count] == 1) {
        NSIndexPath *firstItemIP = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.toursTableView selectRowAtIndexPath:firstItemIP animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.toursTableView.delegate tableView:self.toursTableView didSelectRowAtIndexPath:firstItemIP];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displayArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (![self.displayArray[indexPath.row] isKindOfClass:[EventSubCategory class]]) {
        EventDescription *event = self.displayArray[indexPath.row];
        if (event.sponsored) {
            return 50;
        }
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.displayArray[indexPath.row] isKindOfClass:[EventSubCategory class]]) {
        LBMGAroundMeCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        EventSubCategory *subCategory = self.displayArray[indexPath.row];
        cell.tourNameLabel.text = subCategory.name;
        cell.areaName = self.areaName;
        cell.categoryName = self.categoryName;
        cell.subCategoryName = subCategory.name;
        cell.subCategoryID = subCategory.subCategoryID;
        if ([self isFavorite:subCategory.name]) {
            cell.favoriteButton.selected = YES;
        }

        return cell;
    } else {
        
        EventDescription *event = self.displayArray[indexPath.row];
        if (!event.sponsored) {
            LBMGTourLibraryDetailTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
            
            cell.tourNameLabel.text = event.name;
            cell.tourAddress.text = event.descriptionText;
            cell.typeIcon.image = [UIImage imageNamed:@"disclosureicon"];
            return cell;
        } else {
            LBMGAroundMeFeaturedCell *cell = [tableView dequeueReusableCellWithIdentifier:FeaturedCellIdentifier forIndexPath:indexPath];
            
            cell.tourNameLabel.text = event.name;
            cell.tourAddress.text = event.descriptionText;
            return cell;
            
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self.displayArray[indexPath.row] isKindOfClass:[EventSubCategory class]]) {
        int itemIndex = [self.places indexOfObject:self.displayArray[indexPath.row]];
        if (itemIndex != self.currentOpenIndex) {
            self.currentOpenIndex = itemIndex;
        } else {
            self.currentOpenIndex = -1;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [self rebuildDisplayArray];
        
    } else {
        
        EventDescription *event = self.displayArray[indexPath.row];
        
        [SVProgressHUD showWithStatus:@"Loading Details"];
        //curl -u 'lbmg:de2013' -H "Accept:application/vnd.lbmg+json;version=1" http://lbmg-staging.herokuapp.com/api/events/1.json
        [ApplicationDelegate.lbmgEngine getEventWithId:[event.eventDescriptionId intValue] factual:event.factualId contentBlock:^(NSDictionary *response) {
            [SVProgressHUD dismiss];
            NSLog(@"%@", response);

            Event *event = [Event instanceFromDictionary:response];
            
            LBMGEventMasterVC *eventVC;

            if (event.sponsored) {
                eventVC = [LBMGSponsoredEventVC new];
            } else {
                eventVC = [LBMGEventVC new];
            }
            eventVC.event = event;

            [[(LBMGAppDelegate *)[[UIApplication sharedApplication] delegate] viewController] presentViewController:eventVC animated:YES completion:nil];
            
            [self selectCurrentRow];

        } errorBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Event details unavailable"];
        }];
        [self selectCurrentRow];
    }
}

- (void)rebuildDisplayArray {
    
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.places.count];
    NSMutableArray *newIndexArray = [NSMutableArray arrayWithCapacity:5];
    int i = 0;
    for (EventSubCategory *subCategory in self.places) {
        [newArray addObject:subCategory];
        if (i == self.currentOpenIndex) {
            int j = i+1;
            for (EventDescription *event in subCategory.events) {
                [newArray addObject:event];
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

- (BOOL)isFavorite:(NSString *)subCategoryName
{
    NSString *keyName = keyName = [NSString stringWithFormat:@"%@+%@+%@",self.areaName, self.categoryName, subCategoryName];
    return (BOOL)[self.favorites objectForKey:keyName];
}

#pragma mark - Buttons

- (IBAction)backButtonTouched:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.scroller.contentOffset = CGPointMake(280, 0);
        self.masterPage.titleLabel.text = self.oldTitleText;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self.previousPage deselectCurrentRow];
    }];
}

#pragma mark - Helpers

- (void) selectCurrentRow {
    [self.toursTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentOpenIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
