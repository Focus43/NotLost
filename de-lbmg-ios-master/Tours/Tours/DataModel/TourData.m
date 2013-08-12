#import "TourData.h"

#import "TourRoute.h"
#import "MediaPoint.h"
#import "Photo.h"

@implementation TourData
+ (TourData *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourData *instance = [[TourData alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];
    [self getAndStoreAllTourPhotos];
    [self getAndStoreAllTourVideos];

}

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([key isEqualToString:@"route"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.route = [TourRoute instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"tourDataId"];
    } else if ([key isEqualToString:@"route_based"]) {
        [self setValue:value forKey:@"routeBased"];
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }

}

- (void)getAndStoreAllTourPhotos
{
    NSMutableArray *tempPhotos = [[NSMutableArray alloc] init];
    for (MediaPoint *point in self.route.mediaPoints) {
        for (Photo *photo in point.photos) {
            photo.mediaLabelText = point.labelText;
            [tempPhotos addObject:photo];
        }
    }
    self.tourPhotos = tempPhotos;
}

- (void)getAndStoreAllTourVideos
{
    NSMutableArray *tempVideos = [[NSMutableArray alloc] init];
    for (MediaPoint *point in self.route.mediaPoints) {
        for (NSDictionary *video in point.videos) {
            [tempVideos addObject:video];
        }
    }
    self.tourVideos = tempVideos;
}

@end
