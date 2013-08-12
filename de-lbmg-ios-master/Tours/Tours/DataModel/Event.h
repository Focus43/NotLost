//
//  SponsoredEvent.h
//  Tours
//
//  Created by Alan Smithee on 4/24/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbnailPhoto.h"

@interface Event : NSObject

@property (nonatomic, strong) NSString *address_1;
@property (nonatomic, strong) NSString *address_2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *primary_website;
@property (nonatomic, strong) NSString *secondary_website;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSNumber *zip_code;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic) BOOL sponsored;
@property (nonatomic, strong) NSString *startDateString;
@property (nonatomic, strong) NSString *endDateString;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSDictionary *cover_image;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, copy) NSNumber *eventDescriptionId;
@property (nonatomic, copy) NSString *factualId;
@property (nonatomic, strong) ThumbnailPhoto *thumbnailPhoto;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;


+ (Event *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
