#import <Foundation/Foundation.h>

@interface ThumbnailPhoto : NSObject {

}

@property (nonatomic, copy) NSString *thumbnail_photo;
@property (nonatomic, copy) NSString *url;

+ (ThumbnailPhoto *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
