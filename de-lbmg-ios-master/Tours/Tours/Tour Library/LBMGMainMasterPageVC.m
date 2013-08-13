//
//  LBMGMainMasterPageVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGMainMasterPageVC.h"
#import "LBMGTourLibraryChildTBVC.h"
#import "LBMGTourLibraryMasterPageVC.h"
#import "LBMGAroundMeMasterPageVC.h"
#import "LBMGCalendarMasterVC.h"
#import "LBMGBaseTourMapVC.h"
#import "LBMGNavTableVC.h"

//static NSString *kNameKey = @"nameKey";
//static NSString *kImageKey = @"imageKey";

@interface LBMGMainMasterPageVC ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIButton *mainNavButton;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@property (nonatomic, strong) LBMGTourLibraryMasterPageVC *tourLibraryMaster;
@property (nonatomic, strong) LBMGAroundMeMasterPageVC *aroundMeMaster;
@property (nonatomic, strong) LBMGCalendarMasterVC *calendarMaster;
@property (strong, nonatomic) LBMGNavTableVC *navTableVC;

- (IBAction)showMainNav:(id)sender;

@end

@implementation LBMGMainMasterPageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentList = [NSArray arrayWithObjects:[UIColor redColor],
                        [UIColor darkGrayColor],
                        [UIColor purpleColor],
                        nil];

    NSUInteger numberPages = self.contentList.count;
    

    self.viewControllers = [NSArray arrayWithObjects:
                            self.tourLibraryMaster,
                            self.aroundMeMaster,
                            self.calendarMaster,
                            nil];
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = 0;
    
    self.pagedScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, 80);
    self.pagedScrollView.pagingEnabled = YES;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    // remove all the subviews from our scrollview
//    for (UIView *view in self.scrollView.subviews)
//        {
//        [view removeFromSuperview];
//        }
//    
//    NSUInteger numPages = self.contentList.count;
//    
//    // adjust the contentSize (larger or smaller) depending on the orientation
//    self.scrollView.contentSize =
//    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame));
//    
//    // clear out and reload our pages
//    self.viewControllers = nil;
//    NSMutableArray *controllers = [[NSMutableArray alloc] init];
//    for (NSUInteger i = 0; i < numPages; i++)
//        {
//		[controllers addObject:[NSNull null]];
//        }
//    self.viewControllers = controllers;
//    
//    [self loadScrollViewWithPage:self.pageControl.currentPage - 1];
//    [self loadScrollViewWithPage:self.pageControl.currentPage];
//    [self loadScrollViewWithPage:self.pageControl.currentPage + 1];
//    [self gotoPage:NO]; // remain at the same page (don't animate)
//}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.contentList.count)
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [self.viewControllers objectAtIndex:page];
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = CGRectMake(CGRectGetWidth(frame) * page, frame.size.height - self.view.bounds.size.height, 320, self.view.bounds.size.height);
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
//        NSDictionary *numberItem = [self.contentList objectAtIndex:page];
//        controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:kImageKey]];
//        controller.numberTitle.text = [numberItem valueForKey:kNameKey];
    } else if (page == self.pageControl.currentPage) {
        [controller viewWillAppear:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollView.contentOffset = scrollView.contentOffset;
    [self.tourLibraryMaster removeRefreshTimer];
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page != self.pageControl.currentPage) {   // Only if the page has changed
        self.pageControl.currentPage = page;
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
        
        // a possible optimization would be to unload the views+controllers which are no longer visible
        
        // find currentPage
        LBMGNoRotateViewController *controller = [self.viewControllers objectAtIndex:page];
        [controller scrolledIntoView];
    }
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

#pragma mark - New Main Nav

- (IBAction)showMainNav:(id)sender
{
    [self displayNavTable];
}

- (void)displayNavTable {
    // build first Level TableView
    if (!self.navTableVC) {
        self.navTableVC = [LBMGNavTableVC new];
        self.navTableVC.scroller = self.scrollView;
        
        CGRect childFrame = self.navTableVC.view.frame;
        childFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
        self.navTableVC.view.frame = childFrame;
        
        [self.view insertSubview:self.navTableVC.view atIndex:0];
        [self.view bringSubviewToFront:self.navTableVC.view];
        
        self.navTableVC.masterVC = self;
    }
}

#pragma mark - VC getters

- (LBMGTourLibraryMasterPageVC *)tourLibraryMaster
{
    if (!_tourLibraryMaster) {
        _tourLibraryMaster = [LBMGTourLibraryMasterPageVC new];
    }
    return _tourLibraryMaster;
}

- (LBMGAroundMeMasterPageVC *)aroundMeMaster
{
    if (!_aroundMeMaster) {
        _aroundMeMaster = [LBMGAroundMeMasterPageVC new];
    }
    return _aroundMeMaster;
}

- (LBMGCalendarMasterVC *)calendarMaster
{
    if (!_calendarMaster) {
        _calendarMaster = [LBMGCalendarMasterVC new];
    }
    return _calendarMaster;
}

@end
