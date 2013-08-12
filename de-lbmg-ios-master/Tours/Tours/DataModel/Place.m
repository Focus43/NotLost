#import "Place.h"

#import "TourDetail.h"

@implementation Place
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.placeName forKey:@"placeName"];
    [encoder encodeObject:self.tours forKey:@"tours"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.placeName = [decoder decodeObjectForKey:@"placeName"];
        self.tours = [decoder decodeObjectForKey:@"tours"];
    }
    return self;
}

+ (Place *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Place *instance = [[Place alloc] init];
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

    } else {
        [super setValue:value forKey:key];
    }

}



@end
