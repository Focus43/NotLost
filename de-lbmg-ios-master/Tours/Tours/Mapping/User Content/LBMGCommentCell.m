//
//  LBMGCommentCell.m
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGCommentCell.h"

@implementation LBMGCommentCell

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
        [self.cellImageView setHidden:YES];
        [self.highlightedImageView setHidden:NO];
    }
    else {
        [self.cellImageView setHidden:NO];
        [self.highlightedImageView setHidden:YES];
    }
}

@end
