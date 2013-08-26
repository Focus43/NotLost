#import <Foundation/Foundation.h>

@class TourPoint;

@interface PoiPoint : NSObject {

}

@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *radius;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic) BOOL onRoute;
@property (nonatomic) BOOL isOpen;

+ (PoiPoint *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (BOOL)matchesTourPoint:(TourPoint *)tourPoint;

@end
