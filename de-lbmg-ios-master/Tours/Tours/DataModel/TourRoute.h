#import <Foundation/Foundation.h>

@interface TourRoute : NSObject {

}

@property (nonatomic, copy) NSArray *mediaPoints;
@property (nonatomic, copy) NSArray *poiPoints;
@property (nonatomic, copy) NSArray *tourPoints;

+ (TourRoute *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (void)addOnTourPOIsToPoiPoints;

@end
