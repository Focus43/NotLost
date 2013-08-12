#import <Foundation/Foundation.h>

@interface TourPoint : NSObject {

}

@property (nonatomic, copy) NSNumber *index;
@property (nonatomic, copy) NSString *audio;
@property (nonatomic, copy) NSString *directionText;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *radius;
@property (nonatomic, copy) NSNumber *seqNumber;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) float directionFromPreviousPoint;
@property (nonatomic, copy) NSString *directionTrigger;
@property (nonatomic, copy) NSString *labelText;

+ (TourPoint *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
