#import "ThumbnailPhoto.h"

@implementation ThumbnailPhoto
+ (ThumbnailPhoto *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ThumbnailPhoto *instance = [[ThumbnailPhoto alloc] init];
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

@end
