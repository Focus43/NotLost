#import <Foundation/Foundation.h>

@interface Category : NSObject {

}

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *subCategories;
@property (nonatomic, copy) NSNumber *categoryID;


+ (Category *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
