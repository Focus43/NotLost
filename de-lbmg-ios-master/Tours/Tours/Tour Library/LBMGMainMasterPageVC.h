//
//  LBMGMainMasterPageVC.h
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBMGCalendarMasterVC, LBMGNavTableVC, LBMGTourLibraryMasterPageVC, LBMGAroundMeMasterPageVC, LBMGWebViewVC;

@interface LBMGMainMasterPageVC : LBMGNoRotateViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *contentList;
@property (weak, nonatomic) IBOutlet UIScrollView *pagedScrollView;
@property (strong, nonatomic) IBOutlet UIView *maskingLayerView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIButton *mainNavButton;

@property (nonatomic) BOOL navIsVisible;

@property (nonatomic, strong) LBMGTourLibraryMasterPageVC *tourLibraryMaster;
@property (nonatomic, strong) LBMGAroundMeMasterPageVC *aroundMeMaster;
@property (nonatomic, strong) LBMGCalendarMasterVC *calendarMaster;
@property (nonatomic, strong) LBMGWebViewVC *sharpMaster;
@property (nonatomic, strong) LBMGWebViewVC *gearMaster;
@property (strong, nonatomic) LBMGNavTableVC *navTableVC;

- (void)scootToPage:(NSInteger)page;
- (void)hideNavTable;

@end
