#import "TourPlace.h"

#import "TourDetail.h"

@implementation TourPlace
+ (TourPlace *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourPlace *instance = [[TourPlace alloc] init];
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

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([key isEqualToString:@"tours"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                TourDetail *populatedMember = [TourDetail instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.tours = myMembers;

        }

    }else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"placeId"];
    } else {
        [super setValue:value forKey:key];
    }

}



@end
