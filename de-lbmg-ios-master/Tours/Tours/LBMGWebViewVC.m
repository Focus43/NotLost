//
//  LBMGWebViewVC.m
//  NotLost
//
//  Created by Stine Richvoldsen on 8/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGWebViewVC.h"

@interface LBMGWebViewVC ()

@end

@implementation LBMGWebViewVC

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    DLog(@"web viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.header.text = self.headerString;
//    if (self.shouldPreload)
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
