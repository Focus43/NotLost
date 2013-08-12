#import <Foundation/Foundation.h>

@interface TourPlace : NSObject {

}

@property (nonatomic, copy) NSString *placeName;
@property (nonatomic, copy) NSArray *tours;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *placeId;

+ (TourPlace *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
