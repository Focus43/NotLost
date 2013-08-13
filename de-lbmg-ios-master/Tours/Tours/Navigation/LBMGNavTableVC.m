//
//  LBMGNavTableVC.m
//  NotLost
//
//  Created by Stine Richvoldsen on 8/12/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGNavTableVC.h"
#import "LBMGNavTableCell.h"
#import <QuartzCore/QuartzCore.h> 

@interface LBMGNavTableVC ()

@end

@implementation LBMGNavTableVC

static NSString *CellIdentifier = @"NavCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navList = [NSArray arrayWithObjects:@"tours", @"around me", @"calendar", @"SHARP", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGNavTableCell" bundle:nil];
    [self.tableViewController.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.view.layer.mask = self.maskingLayerView.layer;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navTableView selectRowAtIndexPath:self.selectedRow animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.navList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGNavTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    TourSection *section = self.navList[indexPath.row];
    cell.navigationString = self.navList[indexPath.row];
    
    [cell animateForDuration:1.0+(indexPath.row+1.0)/10];
    
    return cell;
}

@end
