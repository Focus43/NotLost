//
//  LBMGUserContentViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/8/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGUserContentVC.h"
#import "LBMGPhotoCell.h"
#import "LBMGCommentCell.h"
#import "LBMGVideoCell.h"
#import "Photo.h"
#import "LBMGUtilities.h"
#import "LBMGPhotoDetailVC.h"
#import "LBMGCommentVC.h"
#import "LBMGVideoDetailVC.h"

#define kPhotoCell   @"photoCell"
#define kCommentCell @"commentCell"
#define kVideoCell   @"videoCell"

@interface LBMGUserContentVC ()

@end

@implementation LBMGUserContentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // needed for custom cell to keep from crashing
    UINib *cellNib = [UINib nibWithNibName:@"LBMGPhotoCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kPhotoCell];
    
    cellNib = [UINib nibWithNibName:@"LBMGCommentCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCommentCell];
    
    cellNib = [UINib nibWithNibName:@"LBMGVideoCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kVideoCell];
    
    self.content = [LBMGUtilities getUserContentForTour:self.tourID];
    self.photos = [[NSMutableArray alloc] init];
    self.mappedContent = [LBMGUtilities getUserContentForTour:self.tourID];
    
    if ([self.currentContent count] > 0) {
        int index = [self.content indexOfObject:[self.currentContent objectAtIndex:0]];
        
        if (!(index == NSNotFound)) {
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            
        }
    }
    
    [self addPhotosToPhotosArray];
}

- (void)addPhotosToPhotosArray {
    int added = 0;
    for (NSMutableDictionary *item in self.mappedContent) {
        if ([item objectForKey:@"photo"]) {
            Photo *photo = [[Photo alloc] init];
            photo.photo = [item objectForKey:@"photo"];
            photo.caption = [item objectForKey:@"caption"];
            [self.photos addObject:photo];
            
            
            [item setObject:[NSString stringWithFormat:@"%i", added] forKey:@"photoMapping"];
            added++;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.content count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *itemData = [self.content objectAtIndex:indexPath.row];
    if ([itemData objectForKey:@"comment"]) {
        LBMGCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommentCell forIndexPath:indexPath];
        
        cell.textLabel.text = [itemData objectForKey:@"comment"];
        if ([self.currentContent containsObject:itemData])
            [cell setCurrent:YES];
        else
            [cell setCurrent:NO];
        
        return cell;
    }
    else if ([itemData objectForKey:@"photo"]) {
        
        LBMGPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCell forIndexPath:indexPath];
        NSString *photo = [itemData objectForKey:@"photo"];
        NSString *imageFolderPath = [LBMGUtilities userDataPathForTourID:self.tourID];
        NSString *imagePath = [NSString stringWithFormat:@"%@/thmb_%@", imageFolderPath, photo];
        
        cell.photoImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        if ([self.currentContent containsObject:itemData])
            [cell setCurrent:YES];
        else
            [cell setCurrent:NO];
        
        return cell;
    }
    else if ([itemData objectForKey:@"video"]) {
        LBMGVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCell forIndexPath:indexPath];
        
        if ([self.currentContent containsObject:itemData])
            [cell setCurrent:YES];
        else
            [cell setCurrent:NO];
        
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemData = [self.content objectAtIndex:indexPath.row];
    if ([itemData objectForKey:@"comment"]) {
        LBMGCommentVC *detailCommentView = [LBMGCommentVC new];

        detailCommentView.commentText = [itemData objectForKey:@"comment"];
        detailCommentView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:detailCommentView animated:YES completion:^{}];
    }
    else if ([itemData objectForKey:@"photo"]) {
        LBMGPhotoDetailVC *detailPhotoView = [LBMGPhotoDetailVC new];
        detailPhotoView.photos = self.photos;
        detailPhotoView.photoDirectory = [LBMGUtilities userDataPathForTourID:self.tourID];
        
        NSDictionary *selectedPhoto = [self.mappedContent objectAtIndex:indexPath.row];
        
        detailPhotoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        detailPhotoView.currentlyShowingIndex = [[selectedPhoto objectForKey:@"photoMapping"] integerValue];

        
        [self presentViewController:detailPhotoView animated:YES completion:^{}];
    }
    else if ([itemData objectForKey:@"video"]) {
        LBMGVideoDetailVC *detailVideoView = [LBMGVideoDetailVC new];
        detailVideoView.videoName = [itemData objectForKey:@"video"];
        detailVideoView.videoPath = [LBMGUtilities userDataPathForTourID:self.tourID];
        detailVideoView.videoPath = [LBMGUtilities userDataPathForTourID:self.tourID];
        
        detailVideoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:detailVideoView animated:YES completion:nil];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
