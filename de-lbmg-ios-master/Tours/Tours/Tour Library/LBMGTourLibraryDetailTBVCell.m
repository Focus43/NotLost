//
//  LBMGTourLibraryDetailTBVCell.m
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGTourLibraryDetailTBVCell.h"

@implementation LBMGTourLibraryDetailTBVCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundImageView.image = [[UIImage imageNamed:@"inner_slither_highlight"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    } else {
        self.backgroundImageView.image = [[UIImage imageNamed:@"inner_slither"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundImageView.image = [[UIImage imageNamed:@"inner_slither_highlight"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    } else {
        self.backgroundImageView.image = [[UIImage imageNamed:@"inner_slither"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
}

- (void)setDownloading:(BOOL)state {
    _downloading = state;
    if (state) {
        [self startWatching];
    } else {
        [self stopWatching];
    }
}

- (void)startWatching {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadStatusChange:)
                                                 name:LBMGUtilitiesDownloadProgress
                                               object:nil];    
}

- (void)downloadStatusChange:(NSNotification *)notification {
    if(notification) {
        NSDictionary *notificationDict = [notification userInfo];
        NSNumber *progress = [notificationDict objectForKey:self.tourID];
        if (progress) {
            self.tourAddress.text = [NSString stringWithFormat:@"Downloading %3.0f%%", [progress floatValue]*100];
        }
    }
}

- (void)stopWatching {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

 - (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
