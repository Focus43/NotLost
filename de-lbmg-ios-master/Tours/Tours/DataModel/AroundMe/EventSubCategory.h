#import <Foundation/Foundation.h>

@interface EventSubCategory : NSObject {

}

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSArray *events;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *subCategoryID;

+ (EventSubCategory *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
