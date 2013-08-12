#import "TourRoute.h"

#import "MediaPoint.h"
#import "PoiPoint.h"
#import "TourPoint.h"

@implementation TourRoute
+ (TourRoute *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourRoute *instance = [[TourRoute alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];
    [self addOnTourPOIsToPoiPoints];
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([key isEqualToString:@"mediaPoints"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                MediaPoint *populatedMember = [MediaPoint instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.mediaPoints = myMembers;

        }

    } else if ([key isEqualToString:@"poiPoints"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                PoiPoint *populatedMember = [PoiPoint instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.poiPoints = myMembers;

        }

    } else if ([key isEqualToString:@"tourPoints"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                TourPoint *populatedMember = [TourPoint instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.tourPoints = myMembers;

        }

    }
    else {
        [super setValue:value forKey:key];
    }
    
}

- (void)addOnTourPOIsToPoiPoints {
    NSMutableArray *myMembers = [[NSMutableArray alloc] initWithArray:self.poiPoints];
    for (TourPoint *point in self.tourPoints) {
        if ([point.type isEqualToString:@"PoiPoint"]) {
            PoiPoint *poi = [PoiPoint new];
            poi.latitude = point.latitude;
            poi.longitude = point.longitude;
            poi.name = point.name;
            poi.radius = point.radius;
            poi.type = point.type;
            poi.labelText = point.labelText;
            poi.onRoute = TRUE;
            [myMembers addObject:poi];
        }
    }
    self.poiPoints = myMembers;
}


@end
