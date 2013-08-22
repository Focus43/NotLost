//
//  LBMGWebViewVC.h
//  NotLost
//
//  Created by Stine Richvoldsen on 8/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGNoRotateViewController.h"

@interface LBMGWebViewVC : LBMGNoRotateViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *header;

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *headerString;
@property (nonatomic) BOOL shouldPreload;

@end
