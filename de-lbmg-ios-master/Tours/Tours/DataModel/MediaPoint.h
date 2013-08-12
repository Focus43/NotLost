#import <Foundation/Foundation.h>

@interface MediaPoint : NSObject {

}

@property (nonatomic, copy) NSNumber *index;
@property (nonatomic, copy) NSString *audio;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, copy) NSNumber *radius;
@property (nonatomic, copy) NSNumber *sequenceMax;
@property (nonatomic, copy) NSArray *videos;
@property (nonatomic, copy) NSString *labelText;

+ (MediaPoint *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
