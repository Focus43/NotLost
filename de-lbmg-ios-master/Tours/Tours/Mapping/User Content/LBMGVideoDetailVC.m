//
//  LBMGVideoDetailViewController.m
//  Tours
//
//  Created by Alan Smithee on 4/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGVideoDetailVC.h"
#import "LBMGUtilities.h"

@interface LBMGVideoDetailVC ()

@end

@implementation LBMGVideoDetailVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    NSString *videoPath = [[LBMGUtilities userDataPathForTourID:self.tourID] stringByAppendingPathComponent:self.videoName];
    
    NSString *videoLocation = [self.videoPath stringByAppendingPathComponent:self.videoName];
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoLocation]];
    self.player.controlStyle = MPMovieControlStyleDefault;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.player.view.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    
    [self.view addSubview:self.player.view];
    [self.player play];
    
    [self.view bringSubviewToFront:self.exitButton];
}

- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.player stop];
}

@end
