#import <Foundation/Foundation.h>

@interface EventDescription : NSObject {

}

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *eventDescriptionId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *factualId;
@property (nonatomic) BOOL sponsored;
@property (nonatomic, strong) NSString *startDateString;
@property (nonatomic, strong) NSString *endDateString;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, copy) NSNumber *distance;

@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;


+ (EventDescription *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
