#import "TourPoint.h"

@implementation TourPoint
+ (TourPoint *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourPoint *instance = [[TourPoint alloc] init];
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
    
    if ([key isEqualToString:@"direction_trigger"]) {
        [self setValue:value forKey:@"directionTrigger"];
        
    }
}


@end
