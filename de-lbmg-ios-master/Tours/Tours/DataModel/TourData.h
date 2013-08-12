#import <Foundation/Foundation.h>

@class TourRoute;

@interface TourData : NSObject {

}

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *tourDataId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) TourRoute *route;
@property (nonatomic, copy) NSNumber *version;
@property (nonatomic, copy) NSString *assets_zip_url;
@property (nonatomic, copy) NSString *introAudio;

@property (nonatomic, strong) NSArray *tourPhotos;
@property (nonatomic, strong) NSArray *tourVideos;
@property (nonatomic, copy) NSNumber *routeBased;

+ (TourData *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
