//
//  SponsoredEvent.m
//  Tours
//
//  Created by Alan Smithee on 4/24/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "Event.h"
#import "Photo.h"

@implementation Event

+ (Event *)instanceFromDictionary:(NSDictionary *)aDictionary
{
    Event *instance = [[Event alloc] init];
    instance.address_1 = @"";
    instance.address_2 = @"";
    instance.city = @"";
    instance.state = @"";
    [instance setAttributesFromDictionary:aDictionary];
    return instance;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{
    
    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self setValuesForKeysWithDictionary:aDictionary];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"eventDescriptionId"];
    } else if ([key isEqualToString:@"factual_id"]) {
        [self setValue:value forKey:@"factualId"];
    } else if ([key isEqualToString:@"start_date"]) {
        [self setValue:value forKey:@"startDateString"];
        if (![self.startDateString isEqualToString:@""]) {
            self.startDate = [self apiStringFromDate:self.startDateString];
            DLog(@"%@ - %@", self.startDateString, self.startDate);
        }
    } else if ([key isEqualToString:@"end_date"]) {
        [self setValue:value forKey:@"endDateString"];
        if (![self.endDateString isEqualToString:@""]) {
            self.endDate = [self apiStringFromDate:self.endDateString];
            DLog(@"%@ - %@", self.endDateString, self.endDate);
        }
    } else if ([key isEqualToString:@"thumbnail_image"]) {
        //[self setValue:value forUndefinedKey:@"thumbnailPhoto"];
        ThumbnailPhoto *thumbnail = [ThumbnailPhoto instanceFromDictionary:value];
        self.thumbnailPhoto = thumbnail;
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    
    if ([key isEqualToString:@"images"]) {
        
        if ([value isKindOfClass:[NSArray class]])
        {
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Photo *populatedMember = [Photo instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            self.images = myMembers;
        }
    }
    else {
        [super setValue:value forKey:key];
    }
}

- (NSDate *)apiStringFromDate:(NSString *)dateString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self address_1] forKey:@"address_1"];
    [encoder encodeObject:[self address_2] forKey:@"address_2"];
    [encoder encodeObject:[self city] forKey:@"city"];
    [encoder encodeObject:[self descriptionText] forKey:@"descriptionText"];
    [encoder encodeObject:[self name] forKey:@"name"];
    [encoder encodeObject:[self primary_website] forKey:@"primary_website"];
    [encoder encodeObject:[self secondary_website] forKey:@"secondary_website"];
    [encoder encodeObject:[self state] forKey:@"state"];
    [encoder encodeObject:[self zip_code] forKey:@"zip_code"];
    [encoder encodeObject:[self phone_number] forKey:@"phone_number"];
    [encoder encodeBool:[self sponsored] forKey:@"sponsored"];
    [encoder encodeObject:[self startDateString] forKey:@"startDateString"];
    [encoder encodeObject:[self endDateString] forKey:@"endDateString"];
    [encoder encodeObject:[self videos] forKey:@"videos"];
    [encoder encodeObject:[self images] forKey:@"images"];
    [encoder encodeObject:[self cover_image] forKey:@"cover_image"];
    [encoder encodeObject:[self distance] forKey:@"distance"];
    [encoder encodeObject:[self eventDescriptionId] forKey:@"eventDescriptionId"];
    [encoder encodeObject:[self factualId] forKey:@"factualId"];
    [encoder encodeObject:[self startDate] forKey:@"startDate"];
    [encoder encodeObject:[self endDate] forKey:@"endDate"];
    [encoder encodeObject:[self selectedDate] forKey:@"selectedDate"];
    [encoder encodeObject:[self latitude] forKey:@"latitude"];
    [encoder encodeObject:[self longitude] forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        [self setAddress_1:[decoder decodeObjectForKey:@"address_1"]];
        [self setAddress_2:[decoder decodeObjectForKey:@"address_2"]];
        [self setCity:[decoder decodeObjectForKey:@"city"]];
        [self setDescriptionText:[decoder decodeObjectForKey:@"descriptionText"]];
        [self setName:[decoder decodeObjectForKey:@"name"]];
        [self setPrimary_website:[decoder decodeObjectForKey:@"primary_website"]];
        [self setSecondary_website:[decoder decodeObjectForKey:@"secondary_website"]];
        [self setState:[decoder decodeObjectForKey:@"state"]];
        [self setZip_code:[decoder decodeObjectForKey:@"zip_code"]];
        [self setPhone_number:[decoder decodeObjectForKey:@"phone_number"]];
        [self setSponsored:[decoder decodeBoolForKey:@"sponsored"]];
        [self setStartDateString:[decoder decodeObjectForKey:@"startDateString"]];
        [self setEndDateString:[decoder decodeObjectForKey:@"endDateString"]];
        [self setVideos:[decoder decodeObjectForKey:@"videos"]];
        [self setImages:[decoder decodeObjectForKey:@"images"]];
        [self setCover_image:[decoder decodeObjectForKey:@"cover_image"]];
        [self setDistance:[decoder decodeObjectForKey:@"distance"]];
        [self setEventDescriptionId:[decoder decodeObjectForKey:@"eventDescriptionId"]];
        [self setFactualId:[decoder decodeObjectForKey:@"factualId"]];
        [self setStartDate:[decoder decodeObjectForKey:@"startDate"]];
        [self setEndDate:[decoder decodeObjectForKey:@"endDate"]];
        [self setSelectedDate:[decoder decodeObjectForKey:@"selectedDate"]];
        [self setLatitude:[decoder decodeObjectForKey:@"latitude"]];
        [self setLongitude:[decoder decodeObjectForKey:@"longitude"]];
    }
    return self;
}

@end