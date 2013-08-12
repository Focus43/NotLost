//
//  LBMGVideoCell.m
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGVideoCell.h"

@implementation LBMGVideoCell

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
        [self.videoImageView setHidden:YES];
        [self.highlightedVideoImageView setHidden:NO];
    }
    else {
        [self.videoImageView setHidden:NO];
        [self.highlightedVideoImageView setHidden:YES];
    }
}

@end
