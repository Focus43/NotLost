#import "Section.h"

#import "Place.h"

@implementation Section
+ (Section *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Section *instance = [[Section alloc] init];
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

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"SectionName"]) {
        [self setValue:value forKey:@"sectionName"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
