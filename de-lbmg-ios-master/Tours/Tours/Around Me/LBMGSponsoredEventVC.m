//
//  LBMGEventVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGSponsoredEventVC.h"
#import "LBMGPhotoCell.h"
#import "Photo.h"
#import "UIImageView+WebCache.h"
#import "LBMGPhotoDetailVC.h"
#import <QuartzCore/QuartzCore.h>

#define kPhotoCell @"photoCell"

@interface LBMGSponsoredEventVC ()

@end

@implementation LBMGSponsoredEventVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self populateViewWithEventData];
    [self setupTabButtons];
    
    self.scrollView.contentSize = CGSizeMake(300, 1000);
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGPhotoCell" bundle:nil];
    [self.mediaCollectionView registerNib:cellNib forCellWithReuseIdentifier:kPhotoCell];
    
    self.mediaCollectionView.contentSize = CGSizeMake(300, 400);
    
    [self resizeContent];
    self.coverImageView.layer.cornerRadius = 8.0;
}

- (void)populateViewWithEventData {
    
    self.website2Label.text = self.event.secondary_website;
    
    self.descriptionLabel.text = self.event.descriptionText; 
    
    if ([self.event.cover_image isKindOfClass:[NSDictionary class]]) {
        NSString *coverImagePath = [self.event.cover_image objectForKey:@"url"];
        [self.coverImageView setImageWithURL:[NSURL URLWithString:coverImagePath] placeholderImage:nil];
    }
}

- (void)setupTabButtons {
    UIColor *defaultBackgroundColor = [UIColor clearColor];
    UIColor *highlightedBackgroundColor = [UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1];
    
    UIColor *defaultFontColor = [UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1];
    UIColor *highlightedFontColor = [UIColor whiteColor];
    
    UIColor *defaultShadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    UIColor *highlightedShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    
    [self.infoButton setToggleOffColor:defaultBackgroundColor fontColor:defaultFontColor withShadowColor:defaultShadowColor];
    [self.infoButton setToggleOnColor:highlightedBackgroundColor fontColor:highlightedFontColor withShadowColor:highlightedShadowColor];
    
    [self.reviewButton setToggleOffColor:defaultBackgroundColor fontColor:defaultFontColor withShadowColor:defaultShadowColor];
    [self.reviewButton setToggleOnColor:highlightedBackgroundColor fontColor:highlightedFontColor withShadowColor:highlightedShadowColor];
    
    [self.mediaButton setToggleOffColor:defaultBackgroundColor fontColor:defaultFontColor withShadowColor:defaultShadowColor];
    [self.mediaButton setToggleOnColor:highlightedBackgroundColor fontColor:highlightedFontColor withShadowColor:highlightedShadowColor];
    
    [self.infoButton setOn];
}

- (void)resizeContent {
    CGRect frame = self.descriptionLabel.frame;
    frame.size.height = self.descriptionLabel.contentSize.height;
    self.descriptionLabel.frame = frame;

    frame.size.height = MAX(self.view.frame.size.height - self.scrollView.frame.origin.y - 20, 170 + self.descriptionLabel.contentSize.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, frame.size.height + 20);
}

- (IBAction)infoButtonPressed:(id)sender {
    [self.reviewView setHidden:YES];
    [self.mediaView setHidden:YES];
    [self.infoView setHidden:NO];
    [self.scrollView setHidden:NO];
    [self.infoButton setOn];
    [self.reviewButton setOff];
    [self.mediaButton setOff];
}

- (IBAction)reviewButtonPressed:(id)sender {
    [self.reviewView setHidden:NO];
    [self.mediaView setHidden:YES];
    [self.infoView setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.infoButton setOff];
    [self.reviewButton setOn];
    [self.mediaButton setOff];
}

- (IBAction)mediaButtonPressed:(id)sender {
    [self.reviewView setHidden:YES];
    [self.mediaView setHidden:NO];
    [self.infoView setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.infoButton setOff];
    [self.reviewButton setOff];
    [self.mediaButton setOn];
}


- (IBAction)website2ButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.secondary_website]];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.event.images count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBMGPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCell forIndexPath:indexPath];
    Photo *currentPhoto = [self.event.images objectAtIndex:indexPath.row];
    
    [cell.photoImageView setImageWithURL:[NSURL URLWithString:currentPhoto.thumb_url] placeholderImage:nil];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LBMGPhotoDetailVC *detailPhotoView = [LBMGPhotoDetailVC new];
    detailPhotoView.photos = self.event.images;
    detailPhotoView.currentlyShowingIndex = indexPath.row;
    detailPhotoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [self presentViewController:detailPhotoView animated:YES completion:^{}];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 90, 10);
}

@end
