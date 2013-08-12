//
//  LBMGPhotoCell.m
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGPhotoCell.h"

@implementation LBMGPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCurrent:(BOOL)current {
    if (current) {
        [self.photoFrameImageView setHidden:YES];
        [self.currentPhotoFrameImageView setHidden:NO];
    }
    else {
        [self.photoFrameImageView setHidden:NO];
        [self.currentPhotoFrameImageView setHidden:YES];
    }
}

@end
