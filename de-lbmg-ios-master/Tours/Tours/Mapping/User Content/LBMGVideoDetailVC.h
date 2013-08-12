//
//  LBMGVideoDetailViewController.h
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LBMGVideoDetailVC : LBMGNoRotateViewController
@property (strong, nonatomic) NSString *videoPath;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, nonatomic) NSString *videoName;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

- (IBAction)exitButtonPressed:(id)sender;

@end
