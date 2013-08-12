#import <Foundation/Foundation.h>

@class TourData;

@interface Tour : NSObject {

}

@property (nonatomic, strong) TourData *tour;

+ (Tour *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
