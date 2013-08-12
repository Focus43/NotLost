#import <Foundation/Foundation.h>

@interface EventCategories : NSObject {

}

@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSNumber *eventCategoriesId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *factualId;

+ (EventCategories *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
