//
//  LBMGPhotoDetailViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/5/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGPhotoDetailVC.h"
#import "Photo.h"
#import "LBMGUtilities.h"
#import "LBMGPhotoDetailCell.h"
#import "UIImageView+WebCache.h"

#define kPhotoDetailCell @"photoDetailCell"

@interface LBMGPhotoDetailVC ()

@end

@implementation LBMGPhotoDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // needed for custom cell to keep from crashing
    UINib *cellNib = [UINib nibWithNibName:@"LBMGPhotoDetailCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kPhotoDetailCell];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    self.collectionView.collectionViewLayout = flowLayout;
    
    if (self.isTutorial) {
        self.shareButton.hidden = YES;
        self.pageControl.hidden = NO;
        self.pageControl.numberOfPages = [self.photos count];
        self.pageControl.currentPage = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // shows the currently selected image
    if (self.currentlyShowingIndex > -1 && [self.photos count] > self.currentlyShowingIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentlyShowingIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView reloadData];
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyShowingIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self performSelector:@selector(scrollToCurrentImage) withObject:nil afterDelay:0.01];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [self.collectionView reloadData];
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyShowingIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollToCurrentImage
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyShowingIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGPhotoDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoDetailCell forIndexPath:indexPath];
    Photo *currentPhoto = [self.photos objectAtIndex:indexPath.row];
    
    cell.captionLabel.text = currentPhoto.caption;
    cell.scale = 1;
    cell.delegate = self;
    cell.singleTapped = self.singleTapped;
    
    NSString *imagePath;
    if ([currentPhoto.url length] > 0) {
        [SVProgressHUD showWithStatus:@"Loading Picture"];
        cell.imagePath = currentPhoto.url;
    }
    
    if ([currentPhoto.photo length] > 0) {
        if (self.isTutorial) {
            imagePath = currentPhoto.photo;
            cell.labelContainer.hidden = YES;
        } else {
            imagePath = [self.photoDirectory stringByAppendingPathComponent:currentPhoto.photo];
        }
        
        cell.photoImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        cell.currentImage = [UIImage imageWithContentsOfFile:imagePath];
        [cell configureZoom];
    }
    
    self.currentCell = cell;
    [cell loadWebImageIfNeeded];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        return CGSizeMake([[UIScreen mainScreen] bounds].size.height, 300);
    }
    return CGSizeMake(320, [[UIScreen mainScreen] bounds].size.height - 20);
}

- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)shareButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", nil];
    
    // show actionsheet in window because current view doesn't work due to horizontal scroller
    [actionSheet showInView:self.view];
}

// keeps track of the index that is currently on screen
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    LBMGPhotoDetailCell* currentCell = ([[collectionView visibleCells]count] > 0) ? [[collectionView visibleCells] objectAtIndex:0] : nil;
    if(cell != nil){
        self.currentlyShowingIndex = [collectionView indexPathForCell:currentCell].row;
    }
    
    if (self.isTutorial) {
        self.pageControl.currentPage = self.currentlyShowingIndex;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // save to camera roll button
    if (buttonIndex == 0) {
        
        Photo *currentPhoto = [self.photos objectAtIndex:self.currentlyShowingIndex];
        NSString *imagePath = [self.photoDirectory stringByAppendingPathComponent:currentPhoto.photo];
        UIImage *currentImage = [UIImage imageWithContentsOfFile:imagePath];
        
        UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil);
    }
}

#pragma mark - LBMGPhotoDetailProtocol Methods
- (void)singleTapped:(BOOL)showItems withDuration:(float)duration {
    if (showItems) {
        [UIView animateWithDuration:duration animations:^{
            self.shareButton.alpha = 1;
            self.exitButton.alpha = 1;
        }];
        self.singleTapped = FALSE;
    }
    else {
        [UIView animateWithDuration:duration animations:^{
            self.shareButton.alpha = 0;
            self.exitButton.alpha = 0;
        }];
        self.singleTapped = TRUE;
    }
}


@end
