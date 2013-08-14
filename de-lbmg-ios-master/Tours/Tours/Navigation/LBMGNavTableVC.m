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
    
    CGRect bounds = self.view.bounds;
    self.view.frame = CGRectMake(0, 50, bounds.size.width, bounds.size.height-50);
//    self.frameRect = self.view.frame;
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGNavTableCell" bundle:nil];
    [self.tableViewController.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.view.layer.mask = self.maskingLayerView.layer;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navTableView selectRowAtIndexPath:self.selectedRow animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)flipTableCellsOut
{
    NSArray *idxPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForItem:0 inSection:0], [NSIndexPath indexPathForItem:1 inSection:0], [NSIndexPath indexPathForItem:2 inSection:0], [NSIndexPath indexPathForItem:3 inSection:0], [NSIndexPath indexPathForItem:4 inSection:0], nil];
    [self.tableViewController.tableView deleteRowsAtIndexPaths:idxPaths withRowAnimation:UITableViewRowAnimationLeft];
}

//- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
//{
//    
//}

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
    
//    [cell animateForDuration:1.0+(indexPath.row+1.0)/10];
    [cell animateForDuration:1.0+(indexPath.row+1.0)/10 forVisibility:false];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRowAtIndexPath row: %d", indexPath.row);
    // Hack to deal with personal library
    if (indexPath.row == 4) {
        LBMGYourLibraryTBVC *yourLibrary = [LBMGYourLibraryTBVC new];
        yourLibrary.availableTours = self.masterVC.tourLibraryMaster.tourList;
        yourLibrary.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        yourLibrary.locationManager = self.masterVC.tourLibraryMaster.locationManager;
        [self presentViewController:yourLibrary animated:YES completion:^{
            DLog(@"Presented");
        }];
    } else {
        [self.masterVC scootToPage:indexPath.row];
    }

}

- (void)deselectCurrentRow {
    [self.navTableView deselectRowAtIndexPath:self.selectedRow animated:YES];
}

@end
