#import "Tours.h"

#import "Place.h"

@implementation Tours
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.places forKey:@"places"];
    [encoder encodeObject:self.sectionName forKey:@"sectionName"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.places = [decoder decodeObjectForKey:@"places"];
        self.sectionName = [decoder decodeObjectForKey:@"sectionName"];
    }
    return self;
}

+ (Tours *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Tours *instance = [[Tours alloc] init];
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

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([key isEqualToString:@"places"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Place *populatedMember = [Place instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.places = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"SectionName"]) {
        [self setValue:value forKey:@"sectionName"];
    }
//    else {
//        // commenting this out stops the app from crashing when a new key is added
//        [super setValue:value forUndefinedKey:key];
//    }

}



@end
