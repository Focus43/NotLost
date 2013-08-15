//
//  LBMGNavTableVC.m
//  NotLost
//
//  Created by Stine Richvoldsen on 8/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGNavTableVC.h"
#import "LBMGNavTableCell.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGYourLibraryTBVC.h"
#import "LBMGTourLibraryMasterPageVC.h"
#import <QuartzCore/QuartzCore.h> 

@interface LBMGNavTableVC ()

@end

@implementation LBMGNavTableVC

static NSString *CellIdentifier = @"NavCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navList = [NSArray arrayWithObjects:@"Tours", @"Around Me", @"Calendar", @"SHARP", @"Your Content", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    CGRect bounds = self.view.bounds;
//    self.view.frame = CGRectMake(0, 50, bounds.size.width, bounds.size.height-50);
//    self.frameRect = self.view.frame;
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGNavTableCell" bundle:nil];
    [self.tableViewController.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.view.layer.mask = self.maskingLayerView.layer;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
//    self.selectedRow = [NSIndexPath indexPathWithIndex:self.masterVC.pageControl.currentPage];
    [self.navTableView selectRowAtIndexPath:self.selectedRow animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)flipTableCellsOut
{
    NSArray *idxPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForItem:0 inSection:0], [NSIndexPath indexPathForItem:1 inSection:0], [NSIndexPath indexPathForItem:2 inSection:0], [NSIndexPath indexPathForItem:3 inSection:0], [NSIndexPath indexPathForItem:4 inSection:0], nil];
    [self.tableViewController.tableView deleteRowsAtIndexPaths:idxPaths withRowAnimation:UITableViewRowAnimationLeft];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.masterVC.navIsVisible) {
        return [self.navList count];
    } else {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LBMGNavTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.navigationString = self.navList[indexPath.row];
    cell.navigationLabel.text = self.navList[indexPath.row];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"inner_slither"] stretchableImageWithLeftCapWidth:10 topCapHeight:5]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"inner_slither_highlight"] stretchableImageWithLeftCapWidth:10 topCapHeight:5]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) { return; }
    // Hack to deal with personal library
    if (indexPath.row == 4) {
        LBMGYourLibraryTBVC *yourLibrary = [LBMGYourLibraryTBVC new];
        yourLibrary.availableTours = self.masterVC.tourLibraryMaster.tourList;
        yourLibrary.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        yourLibrary.locationManager = self.masterVC.tourLibraryMaster.locationManager;
        [self.masterVC presentViewController:yourLibrary animated:YES completion:^{
            // move nav and scrollview back to left under the modal
            [self.masterVC hideNavTable];            
        }];
    } else {
        [self.masterVC hideNavTable];
        [self.masterVC scootToPage:indexPath.row];
    }

    self.masterVC.navIsVisible = false;
    [self.view removeFromSuperview];
}

- (void)deselectCurrentRow {
    [self.navTableView deselectRowAtIndexPath:self.selectedRow animated:YES];
}

@end
