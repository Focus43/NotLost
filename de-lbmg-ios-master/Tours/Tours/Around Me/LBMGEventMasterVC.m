//
//  LBMGEventMasterVC.m
//  Tours
//
//  Created by Alan Smithee on 4/25/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGEventMasterVC.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "PRPAlertView.h"
#import "UAPush.h"

// This is the TEST zone id for the Interstitial Example
// go to http://ads.tapit.com/ to get your's
#define ZONE_ID @"30788"

@interface LBMGEventMasterVC ()

@end

@implementation LBMGEventMasterVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self populateViewWithGeneralEventData];
    [self performSelector:@selector(checkForSavedEvent) withObject:nil afterDelay:0.01];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)checkForSavedEvent {
    NSDate *selectedDate = [LBMGUtilities checkForID:self.event];
    
    if (selectedDate && self.event.sponsored && self.event.endDate) {
        selectedDate = self.event.endDate;
        self.imGoingButton.selected = YES;
    }
    if (selectedDate) {
        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:selectedDate];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
                
        // if the year is before then ok
        // if the year is the same and the month is before then ok
        // if the year is the same and the month is the same and the date is before ok
        // if the year is the same and the month is the same and the date is the same ok
        if ((today.year <= otherDay.year) ||
            (today.year == otherDay.year && today.month < otherDay.month) ||
            (today.year == otherDay.year && today.month == otherDay.month && today.date < otherDay.date) ||
            (today.year == otherDay.year && today.month == otherDay.month && today.date == otherDay.date)) {
            
            self.imGoingButton.selected = YES;
            self.event.selectedDate = selectedDate;
        }
    }
}

- (void)populateViewWithGeneralEventData {
    self.titleLabel.text = self.event.name;
//    [self.phoneButton setTitle:self.event.phone_number forState:UIControlStateNormal];
    
    NSString *pNumber = [self phoneNumber:self.event.phone_number];
    self.phoneLabel.text = pNumber;
    self.website1Label.text = self.event.primary_website;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MM/dd/yyyy - hh:mma";
    self.dateFromLabel.text = [formatter stringFromDate:self.event.startDate];
    self.dateToLabel.text = [formatter stringFromDate:self.event.endDate];  
    
    NSString *address;
    if ([self.event.address_2 length] > 0) {
        address = [NSString stringWithFormat:@"%@\n%@\n%@ %@, %@", self.event.address_1, self.event.address_2, self.event.city, self.event.state, self.event.zip_code];
    }
    else {
        address = [NSString stringWithFormat:@"%@\n%@ %@, %@", self.event.address_1, self.event.city, self.event.state, self.event.zip_code];
    }
    
    if ([self.event.address_1 length] == 0 && [self.event.city length] == 0 && [self.event.state length] == 0 && [self.event.zip_code intValue] == 0) {
        if (self.event.longitude && self.event.latitude) {
            address = [NSString stringWithFormat:@"%@\n%@", self.event.longitude, self.event.latitude];
        } else {
            address = @"Not Available";
            self.takeMeThereButton.hidden = YES;
        }
    }
    
    self.addressLabel.text = address;
    
    if (self.event.distance && ![self.event.distance isEqualToString:@""]) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%@ miles", self.event.distance];
    }
}

-(NSString *) phoneNumber:(NSString *)number{
    static NSCharacterSet* set = nil;
    if (set == nil){
        set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
    NSString* phoneString = [[number componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    switch (phoneString.length) {
        case 7: return [NSString stringWithFormat:@"%@-%@", [phoneString substringToIndex:3], [phoneString substringFromIndex:3]];
        case 10: return [NSString stringWithFormat:@"(%@) %@-%@", [phoneString substringToIndex:3], [phoneString substringWithRange:NSMakeRange(3, 3)],[phoneString substringFromIndex:6]];
        case 11: return [NSString stringWithFormat:@"%@ (%@) %@-%@", [phoneString substringToIndex:1], [phoneString substringWithRange:NSMakeRange(1, 3)], [phoneString substringWithRange:NSMakeRange(4, 3)], [phoneString substringFromIndex:7]];
        case 12: return [NSString stringWithFormat:@"+%@ (%@) %@-%@", [phoneString substringToIndex:2], [phoneString substringWithRange:NSMakeRange(2, 3)], [phoneString substringWithRange:NSMakeRange(5, 3)], [phoneString substringFromIndex:8]];
        default: return @"";
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)phoneButtonPressed:(id)sender {
    NSString *strippedPhoneNumber = [[self.event.phone_number componentsSeparatedByCharactersInSet:
                                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                     componentsJoinedByString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", strippedPhoneNumber]]];
}

- (IBAction)website1ButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.primary_website]];
}

- (IBAction)addressButtonPressed:(id)sender {
    
    if (self.event.longitude && self.event.longitude) {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.event.latitude doubleValue], [self.event.longitude doubleValue]);

        NSDictionary *addressDict = @{
                                      (NSString *) kABPersonPhoneMainLabel : self.event.phone_number,
                                      (NSString *) kABPersonAddressStreetKey : self.event.address_1,
                                      (NSString *) kABPersonAddressStreetKey : self.event.address_2,
                                      (NSString *) kABPersonAddressCityKey : self.event.city,
                                      (NSString *) kABPersonAddressStateKey : self.event.state,
                                      (NSString *) kABPersonAddressZIPKey : self.event.zip_code,
                                      (NSString *) kABPersonAddressCountryKey : @"United States"
                                      };
        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:addressDict];
        
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.event.name];
        
        [mapItem openInMapsWithLaunchOptions:nil];
    }
    else {
        Class itemClass = [MKMapItem class];
        if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
            
            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
            
            NSDictionary *addressDict = @{
                                          (NSString *) kABPersonPhoneMainLabel : self.event.phone_number,
                                          (NSString *) kABPersonAddressStreetKey : self.event.address_1,
                                          (NSString *) kABPersonAddressStreetKey : self.event.address_2,
                                          (NSString *) kABPersonAddressCityKey : self.event.city,
                                          (NSString *) kABPersonAddressStateKey : self.event.state,
                                          (NSString *) kABPersonAddressZIPKey : self.event.zip_code,
                                          (NSString *) kABPersonAddressCountryKey : @"United States"
                                          };
            
            
            [geoCoder geocodeAddressDictionary:addressDict completionHandler:^(NSArray *placemarks, NSError *error) {
                if ([placemarks count] > 0) {
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    
                    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:addressDict];
                    MKMapItem *toItem = [[MKMapItem alloc] initWithPlacemark:place];
                    
                    NSArray *items = @[toItem];
                    [MKMapItem openMapsWithItems:items launchOptions:nil];
                }
            }];
        }
    }
}

- (IBAction)goingButtonPressed:(UIButton *)sender
{
    if (self.event.selectedDate) {
        // alert to clarify deselect
        [PRPAlertView showWithTitle:@"Favorite?" message:@"Do you want to remove this from your favorites?"
                        cancelTitle:@"NO" cancelBlock:^{

                        } otherTitle:@"YES" otherBlock:^{
                            self.event.selectedDate = nil;
                            self.imGoingButton.selected = NO;
                            [LBMGUtilities removeCalendarEvent:self.event];
                        }];
    } else {
        // if the event is passed display an alert
        
        // if it is a dated event add to calendar for the dates of the event
        if (self.event.sponsored && self.event.startDate != NULL && self.event.endDate != NULL) {
            if ([self.event.endDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) {
                UIAlertView *pastAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"This event has passed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [pastAlert show];
            }
            else {
                self.imGoingButton.selected = YES;
                self.event.selectedDate = [NSDate date];
                [LBMGUtilities addNewCalendarEvent:self.event];
            }
        } else {
            self.imGoingButton.selected = YES;
            self.event.selectedDate = [NSDate date];
            
            [LBMGUtilities addNewCalendarEvent:self.event];
            // Ask for date/Time of event.
            //[self askUserForDateAndTime];
        }
    }
}

- (void)askUserForDateAndTime
{
    self.pickerContainer.frame = self.view.frame;
    [self.view addSubview:self.pickerContainer];
    self.pickerContainer.hidden = NO;
    if (self.event.startDate) {
        self.datePicker.minimumDate = self.event.startDate;
    } else {
        self.datePicker.minimumDate = [NSDate date];
    }
    if (self.event.endDate) {
        self.datePicker.maximumDate = self.event.endDate;
    }
    [self showPicker];
}

- (void)showPicker
{
    self.pickerView.center = CGPointMake(160, self.pickerContainer.frame.size.height+self.pickerView.frame.size.height/2);
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerView.center = CGPointMake(160, self.pickerContainer.frame.size.height-self.pickerView.frame.size.height/2);
    }];    
}

- (void)dismissPicker
{
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerView.center = CGPointMake(160, self.pickerContainer.frame.size.height+self.pickerView.frame.size.height/2);
    }completion:^(BOOL finished) {
        self.pickerContainer.hidden = YES;
    } ];
}

- (IBAction)cancelPickerPressed:(UIBarButtonItem *)sender {
    [self dismissPicker];
}

- (IBAction)pickerDateSelected:(UIBarButtonItem *)sender {
    self.event.selectedDate = self.datePicker.date;
    [self dismissPicker];
    self.imGoingButton.selected = YES;
    [LBMGUtilities addNewCalendarEvent:self.event];
    
}

- (IBAction)pickerValueChanged:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDatePicker *datePicker = (UIDatePicker *)sender;
        
        if ([self.datePicker.date compare:[NSDate date]] == NSOrderedAscending) {
            
            datePicker.date = [NSDate date];
        }
        
    });
}

@end
