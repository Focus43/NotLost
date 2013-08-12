//
//  LBMGViewController.m
//  NotLost
//
//  Created by Alan Smithee on 6/27/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGNoRotateViewController.h"

@interface LBMGNoRotateViewController ()

@end

@implementation LBMGNoRotateViewController

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
    return NO;
}

- (void)scrolledIntoView
{
}



@end
