#import <Foundation/Foundation.h>

@interface Section : NSObject {

}

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSArray *places;
@property (nonatomic, copy) NSString *sectionName;

+ (Section *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
