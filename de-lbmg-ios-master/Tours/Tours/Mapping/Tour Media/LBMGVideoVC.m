//
//  LBMGVideoViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/10/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGVideoVC.h"
#import "LBMGVideoCell.h"
#import "LBMGVideoDetailVC.h"
#import "LBMGUtilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LBMGMoviePlayerViewController.h"

#define kVideoCell @"videoCell"

@interface LBMGVideoVC ()

@end

@implementation LBMGVideoVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.videoData = self.tourData.tourVideos;
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGVideoCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kVideoCell];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.videoData count];
//    return [self.currentVideos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBMGVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCell forIndexPath:indexPath];
    
    NSString *currentVideo = [self.videoData objectAtIndex:indexPath.row];
    if ([self.currentVideos containsObject:currentVideo])
        [cell setCurrent:YES];
    else
        [cell setCurrent:NO];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *videoName = [[self.videoData objectAtIndex:indexPath.row] objectForKey:@"video"];
//    LBMGVideoDetailVC *detailVideoView = [LBMGVideoDetailVC new];
//    detailVideoView.videoName = videoName;
//    detailVideoView.videoPath = [LBMGUtilities videoPathForTourID:self.tourID];
//    detailVideoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:detailVideoView animated:YES completion:nil];
    
    NSString *videoPath = [LBMGUtilities videoPathForTourID:self.tourID];
    NSString *videoLocation = [videoPath stringByAppendingPathComponent:videoName];
    LBMGMoviePlayerViewController *movieViewController = [[LBMGMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoLocation]];
    movieViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    movieViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Self is the UIViewController you are presenting the movie player from.
    [self presentMoviePlayerViewControllerAnimated:movieViewController];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
