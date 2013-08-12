#import <Foundation/Foundation.h>

@interface Photo : NSObject {

}

@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumb_url;
@property (nonatomic, copy) NSString *mediaLabelText;

+ (Photo *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
