//
//  LBMGPhotoDetailCell.m
//  Tours
//
//  Created by Alan Smithee on 4/5/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGPhotoDetailCell.h"
#import "UIImageView+WebCache.h"

#define MAX_ZOOM 6.0
#define ANIMATION_DURATION 0.25

@implementation LBMGPhotoDetailCell

//http://developer.apple.com/library/ios/#DOCUMENTATION/WindowsViews/Conceptual/UIScrollView_pg/ZoomZoom/ZoomZoom.html
- (void)configureZoom {
   
    self.scrollView.minimumZoomScale = 1;
    
    self.scrollView.maximumZoomScale = MAX_ZOOM;
    
    float imgHeight = self.currentImage.size.height;
    float imgWidh = self.currentImage.size.width;
    self.scrollView.contentSize = CGSizeMake(imgWidh * MAX_ZOOM, imgHeight * MAX_ZOOM);
    
    self.scrollView.delegate = self;
    
    self.scrollView.zoomScale = self.scale;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    if (self.singleTapped) {
        self.labelContainer.alpha = 0;
    }
    else {
        self.labelContainer.alpha = 1;
    }
}

- (void)loadWebImageIfNeeded {
    if ([self.imagePath length] > 0) {
        NSURL *url = [NSURL URLWithString:self.imagePath];
        [self.photoImageView setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            self.currentImage = image;
            [self configureZoom];
        }];
    }
    [SVProgressHUD dismiss];
}

- (void)doubleTap {
    
    if (self.scrollView.zoomScale > 1) {
        // zoom out
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.scrollView.zoomScale = 1;
        }];
    }
    else {
        // zoom in
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.scrollView.zoomScale = 2;
        }];
    }
}

- (void)singleTap {
    [self.delegate singleTapped:self.singleTapped withDuration:ANIMATION_DURATION];
    if (self.singleTapped) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.labelContainer.alpha = 1;
        }];
        self.singleTapped = FALSE;
    }
    else {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.labelContainer.alpha = 0;
        }];
        self.singleTapped = TRUE;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

@end
