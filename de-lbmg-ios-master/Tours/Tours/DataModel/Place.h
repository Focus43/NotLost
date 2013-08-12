#import <Foundation/Foundation.h>

@interface Place : NSObject <NSCoding> {

}

@property (nonatomic, copy) NSString *placeName;
@property (nonatomic, copy) NSArray *tours;

+ (Place *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
