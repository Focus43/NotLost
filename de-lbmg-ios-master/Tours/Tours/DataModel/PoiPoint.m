#import "PoiPoint.h"
#import "TourPoint.h"

@implementation PoiPoint
+ (PoiPoint *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    PoiPoint *instance = [[PoiPoint alloc] init];
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

- (BOOL)matchesTourPoint:(TourPoint *)tourPoint {
    if (self.onRoute &&
        self.latitude == tourPoint.latitude &&
        self.longitude == tourPoint.longitude &&
        ([self.name isEqualToString:tourPoint.name] || self.name == tourPoint.name) &&
        ([self.radius isEqualToNumber:tourPoint.radius] || self.radius == tourPoint.radius) &&
        ([self.type isEqualToString:tourPoint.type] || self.type == tourPoint.type) &&
        ([self.labelText isEqualToString:tourPoint.labelText] || self.labelText == tourPoint.labelText)) {
        return YES;
    }
    return NO;
}

@end
