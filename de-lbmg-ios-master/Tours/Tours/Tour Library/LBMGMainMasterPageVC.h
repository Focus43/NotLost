//
//  LBMGMainMasterPageVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMGMainMasterPageVC : LBMGNoRotateViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *contentList;
@property (weak, nonatomic) IBOutlet UIScrollView *pagedScrollView;

@end
