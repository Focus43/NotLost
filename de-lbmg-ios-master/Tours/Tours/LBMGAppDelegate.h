//
//  LBMGAppDelegate.h
//  Tours
//
//  Created by Alan Smithee on 3/18/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"
#import "LBMGEngine.h"

#define ApplicationDelegate ((LBMGAppDelegate *)[UIApplication sharedApplication].delegate)

@class LBMGMainMasterPageVC;

@interface LBMGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LBMGMainMasterPageVC *viewController;

@property (strong, nonatomic) LBMGEngine *lbmgEngine;

@property (strong, nonatomic) NSDictionary *sponsoredEvents;

@end
