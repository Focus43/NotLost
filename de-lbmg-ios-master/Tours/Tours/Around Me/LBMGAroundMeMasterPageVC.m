//
//  LBMGAroundMeMasterPageVCViewController.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGAroundMeMasterPageVC.h"
#import "LBMGTourLibraryChildTBVC.h"
#import <QuartzCore/QuartzCore.h>
#import "EventCategories.h"
#import <MapKit/MapKit.h>
#import "LBMGAroundMeChildTBVC.h"
#import "LBMGYourLibraryTBVC.h"
#import "LBMGAroundMeCategoryCell.h"
#import "EventDescription.h"
#import "LBMGSponsoredEventVC.h"
#import "LBMGEventVC.h"
#import "Event.h"
#import "Category.h"
#import "EventSubCategory.h"
#import "EventDescription.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGAroundMeFeaturedCell.h"
#import "LBMGTourLibraryDetailTBVCell.h"

@interface LBMGAroundMeMasterPageVC ()

@property (strong, nonatomic) LBMGAroundMeChildTBVC *eventTBVC;
@property (nonatomic, strong) NSArray *detailArray;
@property (nonatomic, strong) NSArray *suggestionsArray;
@property (nonatomic, strong) NSArray *searchResultArray;
@property (nonatomic) BOOL hasStartedTyping;

- (void)handleSwipeClosed:(UISwipeGestureRecognizer *)recognizer;

@end


@implementation LBMGAroundMeMasterPageVC

static NSString *CellIdentifier = @"Cell";
static NSString *DetailCellIdentifier = @"DetailCell";
static NSString *FeaturedCellIdentifier = @"FeaturedCell";


- (void)displayEvents
{
    // build first Level TableView

    if (!self.eventTBVC) {
        self.eventTBVC = [LBMGAroundMeChildTBVC new];
        self.eventTBVC.scroller = self.pagedScrollView;
        self.eventTBVC.eventsArray = self.detailArray;
        self.eventTBVC.maskingLayerView = self.maskingLayerView;
        self.eventTBVC.masterPage = self;
//        [self.pagedScrollView addSubview:self.eventTBVC.view];
        
        CGRect childFrame = self.eventTBVC.view.frame;
        childFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
        self.eventTBVC.view.frame = childFrame;
        
        [self.pagedScrollView insertSubview:self.eventTBVC.view atIndex:0];
    }
    
}

- (void)viewDidLoad
{
    self.pagedScrollView.contentSize = CGSizeMake(1000, self.pagedScrollView.frame.size.height);
    
    [self startLocationServices];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGAroundMeCategoryCell" bundle:nil];
    [self.searchTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    UINib *cellNibDetail = [UINib nibWithNibName:@"LBMGTourLibraryDetailTBVCell" bundle:nil];
    [self.searchTableView registerNib:cellNibDetail forCellReuseIdentifier:DetailCellIdentifier];
    UINib *cellNibFeatured = [UINib nibWithNibName:@"LBMGAroundMeFeaturedCell" bundle:nil];
    [self.searchTableView registerNib:cellNibFeatured forCellReuseIdentifier:FeaturedCellIdentifier];
    
    NSString *favoritesUpdatedNotification = @"LBMGFavoritesUpdatedNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:favoritesUpdatedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.detailArray) {
        [self getData];
    }
    
}

- (void)startLocationServices {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // 1 Kilometer
    [self.locationManager startUpdatingLocation];
}

-(void)getData
{
    [SVProgressHUD showWithStatus:@"Loading Events"];
    [ApplicationDelegate.lbmgEngine getAroundMeWithLatitude:self.locationManager.location.coordinate.latitude andLongitude:self.locationManager.location.coordinate.longitude contentBlock:^(NSArray *responseArray) {
        NSLog(@"%@", responseArray);
        [SVProgressHUD dismiss];
        NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[responseArray count]];
        for (id valueMember in responseArray) {
            EventCategories *populatedMember = [EventCategories instanceFromDictionary:valueMember];
            [myMembers addObject:populatedMember];
        }
        
        self.detailArray = myMembers;
        [self displayEvents];
        
        [LBMGUtilities buildSponseredEvents:self.detailArray];
        
        
    }errorBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Events Unavailable"];
        NSLog(@"ERROR");
    }];
}

- (void)scrolledIntoView
{
}

- (IBAction)yourLibraryTouched:(id)sender {
    
    LBMGYourLibraryTBVC *yourLibrary = [LBMGYourLibraryTBVC new];
    yourLibrary.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:yourLibrary animated:YES completion:^{
        DLog(@"Presented");
    }];
}


- (IBAction)searchButtonTouched:(id)sender {
    
    [self.searchTextView becomeFirstResponder];
    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        // hide main nav button, since it interferes with the current page nav
        self.mainVC.mainNavButton.hidden = YES;
        [self.view  addSubview:self.searchViewContainer];
        
        self.hasStartedTyping = NO;
        self.searchTextView.clearsOnBeginEditing = YES;
//        self.searchTextView.text = @"Bldg. #, address, etc...";
        self.searchTextView.text = @"";
        self.clearSearchTextButton.hidden = NO;
        self.suggestionsArray = nil;
        self.searchResultArray = nil;
        [self.searchTableView reloadData];
    } completion:^(BOOL finished) {
        //
    }];
}

- (IBAction)closeSearchButtonPressed:(id)sender {
    // start search
    [self.searchTextView resignFirstResponder];
    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.mainVC.mainNavButton.hidden = NO;
        [self.searchViewContainer removeFromSuperview];
    } completion:^(BOOL finished) {
        //
    }];
    
}

- (IBAction)clearTextButtonPressed:(id)sender {
    self.searchTextView.text = @"";
    self.clearSearchTextButton.hidden = YES;
    
    self.suggestionsArray = nil;
    self.searchResultArray = nil;
    [self.searchTableView reloadData];
}

#pragma mark - TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.searchTextView.text length] > 0) {
        [self startSearchWithString:self.searchTextView.text];
    }
    return YES;
}

- (void)searchTextDidChange {
    
    NSString *suggestString = self.searchTextView.text;
    [ApplicationDelegate.lbmgEngine getListingSuggestionsWithString:suggestString contentBlock:^(NSArray *array) {
        self.suggestionsArray = array;
        [self.searchTableView reloadData];
    } errorBlock:^(NSError *error) {
        // non action necessary
    }];
    
    // determines whether or not to show the clear text button
    if ([self.searchTextView.text length] > 0) {
        self.clearSearchTextButton.hidden = NO;
    }
    else {
        self.clearSearchTextButton.hidden = YES;
    }
}

#pragma mark - Tableview delegate/datasource

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.suggestionsArray) {
        return self.suggestionsArray.count;
    } 
    return self.searchResultArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.suggestionsArray) return 40;

    EventDescription *event = self.searchResultArray[indexPath.row];
    if (event.factualId) return 40;
    
    return 50;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.suggestionsArray) {
        LBMGAroundMeCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.tourName = self.suggestionsArray[indexPath.row];
        cell.favoriteButton.hidden = YES;
        return cell;
    } else {
        EventDescription *event = self.searchResultArray[indexPath.row];
        if (event.factualId) {
            LBMGTourLibraryDetailTBVCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
            
            cell.tourNameLabel.text = event.name;
            cell.tourAddress.text = [NSString stringWithFormat:@"%3.1f miles", [event.distance floatValue]*0.00062137119];
            cell.typeIcon.image = [UIImage imageNamed:@"disclosureicon"];
            return cell;
        } else {
            LBMGAroundMeFeaturedCell *cell = [tableView dequeueReusableCellWithIdentifier:FeaturedCellIdentifier forIndexPath:indexPath];
            
            cell.tourNameLabel.text = event.name;
            cell.tourAddress.text = [NSString stringWithFormat:@"%3.1f miles", [event.distance floatValue]*0.00062137119];
            return cell;
            
        }
    }    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.suggestionsArray) {
        [self startSearchWithString:self.suggestionsArray[indexPath.row]];
    } else {
        EventDescription *event = self.searchResultArray[indexPath.row];
        
        [SVProgressHUD showWithStatus:@"Loading Details"];
        //curl -u 'lbmg:de2013' -H "Accept:application/vnd.lbmg+json;version=1" http://lbmg-staging.herokuapp.com/api/events/1.json
        [ApplicationDelegate.lbmgEngine getEventWithId:[event.eventDescriptionId intValue] factual:event.factualId contentBlock:^(NSDictionary *response) {
            [SVProgressHUD dismiss];
            NSLog(@"%@", response);
            
            Event *event = [Event instanceFromDictionary:response];
            
            LBMGEventMasterVC *eventVC;
            
            if (event.sponsored) {
                eventVC = [LBMGSponsoredEventVC new];
            } else {
                eventVC = [LBMGEventVC new];
            }
            eventVC.event = event;
            
            [[(LBMGAppDelegate *)[[UIApplication sharedApplication] delegate] viewController] presentViewController:eventVC animated:YES completion:nil];
            
        } errorBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Event details unavailable"];
        }];
    }
}
         
 
 - (void)startSearchWithString:(NSString *)searchString
{
    [SVProgressHUD showWithStatus:@"Loading Events"];
    self.searchTextView.text = searchString;
    [self.searchTextView resignFirstResponder];
    [ApplicationDelegate.lbmgEngine getListingSearchWithString:searchString withLatitude:self.locationManager.location.coordinate.latitude andLongitude:self.locationManager.location.coordinate.longitude contentBlock:^(NSArray *array) {

        DLog(@"Suggestions - %@", array);

        if (array.count) {
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showErrorWithStatus:@"No Events Found"];
        }
        
        NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[array count]];
        for (id valueMember in array) {
            EventDescription *populatedMember = [EventDescription instanceFromDictionary:valueMember];
            [myMembers addObject:populatedMember];
        }
        self.searchResultArray = [myMembers copy];
        
        self.suggestionsArray = nil;
        [self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    } errorBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Events Unavailable"];
    }];
}

#pragma mark swipe navigation closed
// TODO: this is kinda bunk, since it's a copy from NORotateVC. ALl the other pages are children of that
// I'm just adding this here, to avoid having to try and make this a child of that too, and potentioally causing regression bugs.

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
    if (recognizer.direction != UISwipeGestureRecognizerDirectionLeft) return;
    
    // if swiped left, close nav and remove the gesture view
    LBMGMainMasterPageVC *mainController = self.mainVC;
    [mainController hideNavTable];
}

@end
