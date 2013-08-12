//
//  LBMGCalendarMasterVC.m
//  Tours
//
//  Created by Alan Smithee on 3/21/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGCalendarMasterVC.h"
#import "LBMGCalendarWeekVC.h"
#import "ArialBlackLabel.h"
#import <EventKit/EventKit.h>
#import "LBMGDayView.h"
#import "LBMGCalendarEventCell.h"
#import "Event.h"
#import "LBMGEventMasterVC.h"
#import "LBMGSponsoredEventVC.h"
#import "LBMGEventVC.h"
#import "EventDescription.h"
#import "LBMGMainMasterPageVC.h"
#import "LBMGEngine.h"
#import "TapIt.h"

// This is the TEST zone id for the Interstitial Example
// go to http://ads.tapit.com/ to get your's
#define ZONE_ID @"30792"

@interface LBMGCalendarMasterVC ()

@property (strong, nonatomic) LBMGCalendarWeekVC *calendarWeekVC;
@property (assign, nonatomic) BOOL isCalendarOpen;
@property (strong, nonatomic) NSDate *weekStartDate;
@property (strong, nonatomic) NSDate *weekEndDate;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSArray *weeksEvents;
@property (strong, nonatomic) NSDictionary *weeksSelectedEvents;
@property (strong, nonatomic) NSDictionary *weeksFavorites;
@property (assign, nonatomic) BOOL hasCalendarAccess;
@property (assign, nonatomic) int openDay;
@property (strong, nonatomic) TapItInterstitialAd *interstitialAd;

@end

@implementation LBMGCalendarMasterVC

static NSString *CellIdentifier = @"Cell";


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"LBMGCalendarEventCell" bundle:nil];
    [self.detailTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];

//    self.weekBackButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    if (self.view.bounds.size.height < 480) {
        self.calenderViewContainer.frame = CGRectOffset(self.calenderViewContainer.bounds, 0, -20);
    }
    
    [self animateDaysBackToPosition];

    self.store = [[EKEventStore alloc] init];
    
//    [self resetDateToNow];

    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            DLog(@"Granted Access");
            self.hasCalendarAccess = YES;
            [self performSelectorOnMainThread:@selector(resetDateToNow) withObject:nil waitUntilDone:NO];
        } else {
            DLog(@"Denied Access");
            self.hasCalendarAccess = NO;
            [SVProgressHUD showErrorWithStatus:@"Some App features will be unavailable without Calendar access"];
            [self performSelectorOnMainThread:@selector(resetDateToNow) withObject:nil waitUntilDone:NO];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"ViewWillAppear");
    if (self.weekStartDate) {
        [self performSelectorOnMainThread:@selector(updateDateSpecificItems) withObject:nil waitUntilDone:NO];
    }
    
}



- (void)scrolledIntoView
{
    [self loadInterstitial];
}


- (void)loadInterstitial
{
    self.interstitialAd = [[TapItInterstitialAd alloc] init];
    self.interstitialAd.delegate = self;
    self.interstitialAd.animated = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            //                            @"test", @"mode", // enable test mode to test banner ads in your app
                            nil];
    TapItRequest *request = [TapItRequest requestWithAdZone:ZONE_ID andCustomParameters:params];
    //    AppDelegate *myAppDelegate = (AppDelegate *)([[UIApplication sharedApplication] delegate]);
    //    [request updateLocation:myAppDelegate.locationManager.location];
    [self.interstitialAd loadInterstitialForRequest:request];
    
}


- (void)updateDateSpecificItems
{
    DLog(@"update Calendar Display");
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    [formatter setDateFormat:@"d"];
    
    NSString *startDate = [formatter stringFromDate:self.weekStartDate];
    NSString *suffix = [suffixes objectAtIndex:[startDate intValue]];
    startDate = [startDate stringByAppendingString:suffix];
    NSString *endDate = [formatter stringFromDate:self.weekEndDate];
    suffix = [suffixes objectAtIndex:[endDate intValue]];
    endDate = [endDate stringByAppendingString:suffix];
    self.weekDayRangeLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
    
    [formatter setDateFormat:@"MMMM"];
    self.monthLabel.text = [formatter stringFromDate:self.weekStartDate];

    [formatter setDateFormat:@"yyyy"];
    self.yearLabel.text = [formatter stringFromDate:self.weekStartDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day = 1;
    [formatter setDateFormat:@"d"];
    NSDate *labelDate = self.weekStartDate;
    
    if (self.hasCalendarAccess) {
        [self fetchEventData];
        [self updateDayIcons];
    }
    for (UILabel *dateLabel in self.dateLabels) {
        NSString *dateString = [formatter stringFromDate:labelDate];
        NSString *suffix = [suffixes objectAtIndex:[dateString intValue]];
        dateLabel.text = [dateString stringByAppendingString:suffix];
        labelDate = [calendar dateByAddingComponents:comps toDate:labelDate options:0];
    }
    
    // Look for saved Events with selected date inlcuded in thsi week
    self.weeksSelectedEvents = [LBMGUtilities savedEventsFrom:self.weekStartDate to:self.weekEndDate];
    [self updateSelectedEvents];
    DLog(@"%@", self.weeksSelectedEvents);
    
    self.weeksFavorites = [LBMGUtilities favoriteEventsForWeek:self.weekStartDate];
    [self updateFavorites];
    
    [self animateDaysBackToPosition];
    self.isCalendarOpen = NO;    
}

- (void)updateDayIcons
{
    int i = 0;
    for (LBMGDayView *dayView in self.dayViews) {
        BOOL hasEvent = [self.weeksEvents[i] boolValue];
        UIImageView *icon = dayView.dayIcons[0];
        if (hasEvent) {
            icon.image = [UIImage imageNamed:@"cal_personalicon"];
        } else {
            icon.image = nil;
        }
        i++;
    }
}

- (void)updateSelectedEvents
{
    int i = 0;
    for (LBMGDayView *dayView in self.dayViews) {
        UIImageView *icon = dayView.dayIcons[1];
       if ([self.weeksSelectedEvents objectForKey:[NSNumber numberWithInt:i]]) {
            icon.image = [UIImage imageNamed:@"cal_eventicon"];
        } else {
            icon.image = nil;
        }
        i++;
    }
}

- (void)updateFavorites
{
    int i = 0;
    for (LBMGDayView *dayView in self.dayViews) {
        UIImageView *icon = dayView.dayIcons[2];
        if ([self.weeksFavorites objectForKey:[NSNumber numberWithInt:i]]) {
            icon.image = [UIImage imageNamed:@"favorite_icon_on"];
        } else {
            icon.image = nil;
        }
        i++;
    }
}

- (void)calculateStartAndEndDaysOfWeekForDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];
    
    NSDateComponents *componentsToSubtract  = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: (0 - [weekdayComponents weekday]) + 2];
    [componentsToSubtract setHour: 0 - [weekdayComponents hour]];
    [componentsToSubtract setMinute: 0 - [weekdayComponents minute]];
    [componentsToSubtract setSecond: 0 - [weekdayComponents second]];
    
    self.weekStartDate = [gregorian dateByAddingComponents:componentsToSubtract toDate:date options:0];
    
    NSDateComponents *componentsToAdd = [gregorian components:NSDayCalendarUnit fromDate:self.weekStartDate];
    [componentsToAdd setDay:6];
    self.weekEndDate = [gregorian dateByAddingComponents:componentsToAdd toDate:self.weekStartDate options:0];
}

- (IBAction)daySelected:(UIButton *)dayButton
{    
    self.isCalendarOpen = !self.isCalendarOpen;
    if (self.isCalendarOpen) {
        self.openDay = dayButton.tag;
        [self.detailTableView reloadData];
        [self rearrangeViewsForSelectedDay:dayButton.tag];
    } else {
        [self animateDaysBackToPosition];
    }
}

- (IBAction)nextWeekButtonTouched:(id)sender
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day = 7;
    self.weekStartDate = [calendar dateByAddingComponents:comps toDate:self.weekStartDate options:0];
    self.weekEndDate = [calendar dateByAddingComponents:comps toDate:self.weekEndDate options:0];
    [self updateDateSpecificItems];
}

- (IBAction)previousWeekButtonTouched:(id)sender
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day = -7;
    NSDate *tempWeekEndDate = [calendar dateByAddingComponents:comps toDate:self.weekEndDate options:0];
    
    if([(NSDate *)[NSDate date] compare:tempWeekEndDate] == NSOrderedAscending)
    {
        self.weekStartDate = [calendar dateByAddingComponents:comps toDate:self.weekStartDate options:0];
        self.weekEndDate = tempWeekEndDate;
        [self updateDateSpecificItems];
    }
}

- (void)fetchEventData
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];

    NSMutableArray *hasEvents = [NSMutableArray arrayWithCapacity:7];
    
    for (int i = 0; i < 7; i++) {
        // Create the end date components
        comps.day = i;
        NSDate *eventDate = [calendar dateByAddingComponents:comps toDate:self.weekStartDate options:0];
        if ([self eventForDay:eventDate]) {
            [hasEvents addObject:[NSNumber numberWithBool:YES]];
        } else {
            [hasEvents addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    self.weeksEvents = [hasEvents copy];
}

- (BOOL)eventForDay:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day = 1;
    NSDate *nextDay = [calendar dateByAddingComponents:comps toDate:date options:0];
    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:date
                                                                 endDate:nextDay
                                                               calendars:nil];
    NSArray *events = [self.store eventsMatchingPredicate:predicate];
    return events.count;
}

- (IBAction)resetDateToNow {
    NSDate *today = [NSDate date];
    [self calculateStartAndEndDaysOfWeekForDate:today];
    [self updateDateSpecificItems];
}

- (void)rearrangeViewsForSelectedDay:(int)day
{
    if (day > 1) {
        [self animateViewsUpFromDay:day];
    } else {
        UIView *monday = self.dayViews[0];
        CGRect tableFrame = self.detailTableView.frame;
        tableFrame.origin.y = monday.frame.origin.y + monday.frame.size.height;
        self.detailTableView.frame = tableFrame;
    }
    if (day < 7) {
        [self animateViewsDownFromDay:day+1];
    }
}

#pragma mark - Animate view methods

- (void)animateDaysToPosition
{
    int i = 0;
    for (UIView *view in self.dayViews) {
        view.center = CGPointMake(160, self.calenderViewContainer.bounds.size.height+20);
        [UIView animateWithDuration:i*0.2+0.25 animations:^{
            view.center = CGPointMake(160, i * view.bounds.size.height+56);
        }];
        i++;
    }
}

- (void)animateDaysBackToPosition
{
    int i = 0;
    for (UIView *view in self.dayViews) {
        [UIView animateWithDuration:0.25 animations:^{
            view.center = CGPointMake(160, i * view.bounds.size.height+56);
            if (i == (self.openDay-1)) {
                CGRect tableFrame = self.detailTableView.frame;
                tableFrame.origin.y = view.frame.origin.y + view.frame.size.height;
                self.detailTableView.frame = tableFrame;
            }
        }];
        i++;
    }
}

- (void)animateViewsDownFromDay:(int)day
{    
    UIView *sunday = self.dayViews[6];
    
    CGFloat offset = 0;
    for (int i = day; i < 8; i++) {
        
        UIView *button = self.dayViews[i-1];
        [UIView animateWithDuration:0.25 animations:^{
            button.center = CGPointMake(button.center.x, sunday.center.y + offset);
        }];
        offset += button.frame.size.height;
    }
}

- (void)animateViewsUpFromDay:(int)day
{
    UIView *fromDay = self.dayViews[day-1];
    
    CGRect tableFrame = self.detailTableView.frame;
    tableFrame.origin.y = fromDay.frame.origin.y + fromDay.frame.size.height;
    self.detailTableView.frame = tableFrame;
    
    UIView *monday = self.dayViews[0];
    
    tableFrame.origin.y = monday.frame.origin.y + monday.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.detailTableView.frame = tableFrame;
    }];

    CGFloat offset = 0;
    for (int i = day; i > 0; i--) {
        
        UIView *button = self.dayViews[i-1];
        [UIView animateWithDuration:0.25 animations:^{
            button.center = CGPointMake(button.center.x, monday.center.y - offset);
        }];
        offset += button.frame.size.height;
    }
}

#pragma mark - TableView datasource & delegate methods

//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        NSArray * events = [self.weeksSelectedEvents objectForKey:[NSNumber numberWithInt:self.openDay-1]];
        return MAX(1,events.count);
    } else if (section == 2) {
        NSArray * events = [self.weeksFavorites objectForKey:[NSNumber numberWithInt:self.openDay-1]];
        return MAX(1,events.count);
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBMGCalendarEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.personalContentView.hidden = YES;
    cell.otherContentView.hidden = NO;
    cell.disclosureIcon.hidden = NO;
    if (indexPath.section == 0) {
        cell.personalContentView.hidden = NO;
        cell.otherContentView.hidden = YES;
        if ([self.weeksEvents[self.openDay-1] boolValue]) {
            cell.personalItemLabel.text = @"You have a personal item on your calendar today";
        } else if (self.hasCalendarAccess) {
            cell.personalItemLabel.text = @"Your calendar is empty for today";
            cell.disclosureIcon.hidden = YES;
        } else {
            cell.personalItemLabel.text = @"Calendar access unavailable";
            cell.disclosureIcon.hidden = YES;
        }
    } else if (indexPath.section == 1) {
        NSArray * events = [self.weeksSelectedEvents objectForKey:[NSNumber numberWithInt:self.openDay-1]];
        
        if (events) {
            Event *event = events[indexPath.row];
            cell.titleLabel.text = event.name;
            cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:event.selectedDate dateStyle:NSDateFormatterShortStyle timeStyle:kCFDateFormatterShortStyle];
            cell.descriptionLabel.text = event.address_1;
        } else {
            cell.titleLabel.text = @"";
            cell.descriptionLabel.text = @"";
            cell.dateLabel.text = @"No items selected for today";
            cell.disclosureIcon.hidden = YES;
        }
        
        cell.favoriteImageView.hidden = YES;
        cell.eventImageView.hidden = NO;
    } else {
        cell.favoriteImageView.hidden = NO;
        cell.eventImageView.hidden = YES;
        NSArray * events = [self.weeksFavorites objectForKey:[NSNumber numberWithInt:self.openDay-1]];
        
        if (events) {
            EventDescription *event = events[indexPath.row];
            cell.titleLabel.text = event.name;
            cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:event.startDate dateStyle:NSDateFormatterShortStyle timeStyle:kCFDateFormatterShortStyle];
            cell.descriptionLabel.text = [NSDateFormatter localizedStringFromDate:event.endDate dateStyle:NSDateFormatterShortStyle timeStyle:kCFDateFormatterShortStyle];
            cell.disclosureIcon.hidden = YES;
        } else {
            cell.titleLabel.text = @"";
            cell.descriptionLabel.text = @"";
            cell.dateLabel.text = @"No favorite matches for today";
            cell.disclosureIcon.hidden = YES;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if ([self.weeksEvents[self.openDay-1] boolValue]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow:"]];
        }
    } else if (indexPath.section == 1) {
        NSArray * events = [self.weeksSelectedEvents objectForKey:[NSNumber numberWithInt:self.openDay-1]];
        if (events) {
            Event *event = events[indexPath.row];
            LBMGEventMasterVC *eventVC;
            
            if (event.sponsored) {
                eventVC = [LBMGSponsoredEventVC new];
            } else {
                eventVC = [LBMGEventVC new];
            }
            eventVC.event = event;
            
            [[(LBMGAppDelegate *)[[UIApplication sharedApplication] delegate] viewController] presentViewController:eventVC animated:YES completion:nil];
        }
    } else if (indexPath.section == 2) {
        NSArray * events = [self.weeksFavorites objectForKey:[NSNumber numberWithInt:self.openDay-1]];
        if (events) {
            EventDescription *event = events[indexPath.row];
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
    
}

#pragma mark -
#pragma mark TapItInterstitialAdDelegate methods

- (void)tapitInterstitialAd:(TapItInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
    //    [self updateUIWithState:StateError];
}

- (void)tapitInterstitialAdDidUnload:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad did unload");
    //    [self updateUIWithState:StateNone];
    self.interstitialAd = nil; // don't reuse interstitial ad!
}

- (void)tapitInterstitialAdWillLoad:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad will load");
}

- (void)tapitInterstitialAdDidLoad:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad did load");
    //    [self.interstitialAd presentFromViewController:self];
    if (!interstitialAd.presentingController) {
        [self.interstitialAd presentFromViewController:self];
    }
    //    [self updateUIWithState:StateReady];
}

- (BOOL)tapitInterstitialAdActionShouldBegin:(TapItInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Ad action should begin");
    return YES;
}

- (void)tapitInterstitialAdActionDidFinish:(TapItInterstitialAd *)interstitialAd {
    NSLog(@"Ad action did finish");
}



@end
