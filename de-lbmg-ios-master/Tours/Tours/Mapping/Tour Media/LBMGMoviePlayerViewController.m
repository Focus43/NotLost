//
//  LBMGMoviePlayerViewController.m
//  NotLost
//
//  Created by Alan Smithee on 6/27/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGMoviePlayerViewController.h"

@interface LBMGMoviePlayerViewController ()

@end

@implementation LBMGMoviePlayerViewController

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
	// Do any additional setup after loading the view.
}

#pragma mark - Rotation Methods
// rotation support for iOS 5.x and earlier, note for iOS 6.0 and later this will not be called
//
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // return YES for supported orientations
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

- (BOOL)shouldAutorotate {
    return YES;
}


@end
