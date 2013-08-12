#import "TourDetail.h"

@implementation TourDetail
+ (TourDetail *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    TourDetail *instance = [[TourDetail alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    self.assets_zip_url = @"";
    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"created_at"]) {
        [self setValue:value forKey:@"createdAt"];
    } else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"tourDetailId"];
    } else if ([key isEqualToString:@"updated_at"]) {
        [self setValue:value forKey:@"updatedAt"];
    } else if ([key isEqualToString:@"route_based"]) {
        [self setValue:value forKey:@"routeBased"];
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }

}

//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self address] forKey:@"address"];
    [encoder encodeObject:[self createdAt] forKey:@"createdAt"];
    [encoder encodeObject:[self descriptionText] forKey:@"descriptionText"];
    [encoder encodeObject:[self distance] forKey:@"distance"];
    [encoder encodeObject:[self name] forKey:@"name"];
    [encoder encodeObject:[self price] forKey:@"price"];
    [encoder encodeObject:[self tourDetailId] forKey:@"tourDetailId"];
    [encoder encodeObject:[self updatedAt] forKey:@"updatedAt"];
    [encoder encodeObject:[self version] forKey:@"version"];
    [encoder encodeObject:[self assets_zip_url] forKey:@"assets_zip_url"];
    [encoder encodeObject:[self routeBased] forKey:@"routeBased"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        [self setAddress:[decoder decodeObjectForKey:@"address"]];
        [self setCreatedAt:[decoder decodeObjectForKey:@"createdAt"]];
        [self setDescriptionText:[decoder decodeObjectForKey:@"descriptionText"]];
        [self setDistance:[decoder decodeObjectForKey:@"distance"]];
        [self setName:[decoder decodeObjectForKey:@"name"]];
        [self setPrice:[decoder decodeObjectForKey:@"price"]];
        [self setTourDetailId:[decoder decodeObjectForKey:@"tourDetailId"]];
        [self setUpdatedAt:[decoder decodeObjectForKey:@"updatedAt"]];
        [self setVersion:[decoder decodeObjectForKey:@"version"]];
        [self setAssets_zip_url:[decoder decodeObjectForKey:@"assets_zip_url"]];
        [self setRouteBased:[decoder decodeObjectForKey:@"routeBased"]];
    }
    return self;
}

@end
