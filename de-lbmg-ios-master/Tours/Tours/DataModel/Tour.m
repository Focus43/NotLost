#import "Tour.h"

#import "TourData.h"

@implementation Tour
+ (Tour *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Tour *instance = [[Tour alloc] init];
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

    if ([key isEqualToString:@"tour"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.tour = [TourData instanceFromDictionary:value];
        }

    }
    else {
        [super setValue:value forKey:key];
    }

}



@end
