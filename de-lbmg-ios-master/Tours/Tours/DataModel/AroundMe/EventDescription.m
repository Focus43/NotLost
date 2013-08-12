#import "EventDescription.h"

@implementation EventDescription
+ (EventDescription *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    EventDescription *instance = [[EventDescription alloc] init];
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
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }

}

- (NSDate *)apiStringFromDate:(NSString *)dateString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}


@end
