#import "TourSection.h"

#import "TourPlace.h"

@implementation TourSection
+ (TourSection *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourSection *instance = [[TourSection alloc] init];
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

    if ([key isEqualToString:@"places"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                TourPlace *populatedMember = [TourPlace instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.places = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"SectionName"]) {
        [self setValue:value forKey:@"sectionName"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"sectionId"];
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }

}



@end
