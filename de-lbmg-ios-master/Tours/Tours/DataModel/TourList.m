#import "TourList.h"

#import "TourSection.h"

@implementation TourList
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.tourData forKey:@"tourData"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.tourData = [decoder decodeObjectForKey:@"tourData"];
    }
    return self;
}

+ (TourList *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourList *instance = [[TourList alloc] init];
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

    if ([key isEqualToString:@"TourData"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                TourSection *populatedMember = [TourSection instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.tourData = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"TourData"]) {
        [self setValue:value forKey:@"tourData"];
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }

}



@end
