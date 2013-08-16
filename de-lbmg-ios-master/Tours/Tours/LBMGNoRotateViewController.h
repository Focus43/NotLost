//
//  LBMGViewController.h
//  NotLost
//
//  Created by Alan Smithee on 6/27/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGNoRotateViewController : UIViewController

@property (nonatomic, strong) UIView *swipeClosedView;
@property (nonatomic, strong) UIViewController *mainVC;

- (void)scrolledIntoView;
- (void)addCloseNavGesture;

@end
