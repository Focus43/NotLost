#import <Foundation/Foundation.h>

@interface TourSection : NSObject {

}

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSArray *places;
@property (nonatomic, copy) NSString *sectionName;
@property (nonatomic, copy) NSNumber *sectionId;

+ (TourSection *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
