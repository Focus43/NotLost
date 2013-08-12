#import <Foundation/Foundation.h>

@interface Tours : NSObject <NSCoding> {

}

@property (nonatomic, copy) NSArray *places;
@property (nonatomic, copy) NSString *sectionName;

+ (Tours *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
