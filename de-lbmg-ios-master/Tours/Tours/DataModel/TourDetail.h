#import <Foundation/Foundation.h>

@interface TourDetail : NSObject <NSCoding> {

}

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSNumber *tourDetailId;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSNumber *version;
@property (nonatomic, copy) NSString *assets_zip_url;
@property (nonatomic, copy) NSNumber *routeBased;

+ (TourDetail *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
