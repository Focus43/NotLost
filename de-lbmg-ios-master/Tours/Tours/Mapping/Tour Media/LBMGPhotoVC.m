//
//  LBMGPhotoViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGPhotoVC.h"
#import "LBMGPhotoCell.h"
#import "Photo.h"
#import "LBMGUtilities.h"
#import "LBMGPhotoDetailVC.h"

#define kPhotoCell @"photoCell"

@interface LBMGPhotoVC ()

@end

@implementation LBMGPhotoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.photoData = self.tourData.tourPhotos;
    
    // needed for custom cell to keep from crashing
    UINib *cellNib = [UINib nibWithNibName:@"LBMGPhotoCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kPhotoCell];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.pushedToDetail)
        [self goToDetailView];
}

- (void)goToDetailView {
    self.pushedToDetail = TRUE;
    if ([self.currentPhotos count] > 0) {
        LBMGPhotoDetailVC *detailPhotoView = [LBMGPhotoDetailVC new];
        detailPhotoView.photos = self.photoData;
        detailPhotoView.photoDirectory = [LBMGUtilities imagePathForTourID:self.tourID];
        if ([self.currentPhotos count] > 0)
            detailPhotoView.currentlyShowingIndex = [self.photoData indexOfObject:[self.currentPhotos objectAtIndex:0]];
        else
            detailPhotoView.currentlyShowingIndex = -1;
        detailPhotoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:detailPhotoView animated:YES completion:nil];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBMGPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCell forIndexPath:indexPath];
    Photo *currentPhoto = [self.photoData objectAtIndex:indexPath.row];
    
    if ([self.currentPhotos containsObject:currentPhoto])
        [cell setCurrent:YES];
    else
        [cell setCurrent:NO];

    NSString *imageFolderPath = [LBMGUtilities imagePathForTourID:self.tourID];
    NSString *imagePath = [NSString stringWithFormat:@"%@/thmb_%@", imageFolderPath, currentPhoto.photo];
    
    cell.photoImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    cell.cellLabel.text = currentPhoto.mediaLabelText;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LBMGPhotoDetailVC *detailPhotoView = [LBMGPhotoDetailVC new];
    detailPhotoView.photos = self.photoData;
    detailPhotoView.photoDirectory = [LBMGUtilities imagePathForTourID:self.tourID];
    detailPhotoView.currentlyShowingIndex = indexPath.row;
    detailPhotoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:detailPhotoView animated:YES completion:^{}];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
