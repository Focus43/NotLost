//
//  LBMGTourEndViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/23/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourEndVC.h"
#import "LBMGTourTypeVC.h"
#import "LBMGSponsoredEventVC.h"
#import "Event.h"
#import "UIImageView+WebCache.h"
#import "LBMGFeaturedLinkCell.h"
#import "ThumbnailPhoto.h"

@interface LBMGTourEndVC ()

@end

@implementation LBMGTourEndVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tourNameLabel.text = self.tourName;
    self.tourDetailsLabel.text = self.detailText;
    
//    [self.featuredLinksTableView registerClass:[LBMGFeaturedLinkCell class] forCellReuseIdentifier:@"FeaturedLinkCell"];
    UINib *cellNib = [UINib nibWithNibName:@"LBMGFeaturedLinkCell" bundle:nil];
    [self.self.featuredLinksTableView registerNib:cellNib forCellReuseIdentifier:@"FeaturedLinkCell"];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tourCompletedContainer.hidden = !self.tourComplete;
    
    [SVProgressHUD showWithStatus:@"Loading Featured Listings"];
    [ApplicationDelegate.lbmgEngine getFeaturedLinksForTourID:[NSNumber numberWithInt:11] contentBlock:^(NSArray *array) {
        DLog(@"%@", array);
        [SVProgressHUD dismiss];
        NSMutableArray *eventObjects = [[NSMutableArray alloc] init];
        for (NSDictionary *event in array) {
            Event *newEvent = [Event instanceFromDictionary:event];
            [eventObjects addObject:newEvent];
        }
        self.featuredLinksArray = [[NSArray alloc] initWithArray:eventObjects];;
        [self.featuredLinksTableView reloadData];
        
    } errorBlock:^(NSError *error) {
        DLog(@"error");
        [SVProgressHUD showErrorWithStatus:@"Error Loading Featured Listings"];
    }];
    
}

- (IBAction)homeButtonTouched:(id)sender {
    [self.tourMC dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.tourMC popWithCompletionBlock:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.featuredLinksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBMGFeaturedLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedLinkCell" forIndexPath:indexPath];
    
    Event *event = self.featuredLinksArray[indexPath.row];
    [cell.image setImageWithURL:[NSURL URLWithString:event.thumbnailPhoto.url] placeholderImage:[UIImage imageNamed:@"blankPlaceHolder.png"]];
    
    cell.title.text = event.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event = self.featuredLinksArray[indexPath.row];
    LBMGSponsoredEventVC *eventVC = [LBMGSponsoredEventVC new];
    eventVC.event = event;
    
    [self presentViewController:eventVC animated:YES completion:nil];
}

@end
