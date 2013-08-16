//
//  LBMGViewController.m
//  NotLost
//
//  Created by Alan Smithee on 6/27/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGNoRotateViewController.h"
#import "LBMGMainMasterPageVC.h"

@interface LBMGNoRotateViewController ()

- (void)handleSwipeClosed:(UISwipeGestureRecognizer *)recognizer;

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

#pragma -- mark swipe navigation closed

- (void)addCloseNavGesture
{
    if (!self.swipeClosedView) {
        CGRect frame = self.mainVC.view.frame;
        frame.size.width = 100;
        self.swipeClosedView = [[UIView alloc] initWithFrame:frame];
        
        UISwipeGestureRecognizer *swipeClosed = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleSwipeClosed:)];
        [swipeClosed setDirection:(UISwipeGestureRecognizerDirectionLeft )];
        [self.swipeClosedView addGestureRecognizer:swipeClosed];
    }
    
    [self.view addSubview:self.swipeClosedView];
    [self.view bringSubviewToFront:self.swipeClosedView];
}

- (void)handleSwipeClosed:(UISwipeGestureRecognizer *)recognizer
{
    DLog(@"direction = %u", recognizer.direction);
    if (recognizer.direction != UISwipeGestureRecognizerDirectionLeft) return;
    
    // if swiped left, close nav and remove the gesture view
    LBMGMainMasterPageVC *mainController = self.mainVC;
    [mainController hideNavTable];
}


@end
