#import "Photo.h"

@implementation Photo
+ (Photo *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Photo *instance = [[Photo alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}


//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self caption] forKey:@"caption"];
    [encoder encodeObject:[self photo] forKey:@"photo"];
    [encoder encodeObject:[self url] forKey:@"url"];
    [encoder encodeObject:[self thumb_url] forKey:@"thumb_url"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        [self setCaption:[decoder decodeObjectForKey:@"caption"]];
        [self setPhoto:[decoder decodeObjectForKey:@"photo"]];
        [self setUrl:[decoder decodeObjectForKey:@"url"]];
        [self setThumb_url:[decoder decodeObjectForKey:@"thumb_url"]];
    }
    return self;
}

@end
