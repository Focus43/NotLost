//
//  LMGNavController.m
//  TourGuide
//
//  Created by Paul Warren on 9/17/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import "LMGNavController.h"

@interface LMGNavController ()

@end

@implementation LMGNavController

-(NSUInteger) supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

@end
