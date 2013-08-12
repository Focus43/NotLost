#import <Foundation/Foundation.h>

@interface TourList : NSObject <NSCoding> {

}

@property (nonatomic, copy) NSArray *tourData;

+ (TourList *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
