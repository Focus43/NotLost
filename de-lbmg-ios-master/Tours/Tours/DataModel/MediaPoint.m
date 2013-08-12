#import "MediaPoint.h"

#import "Photo.h"

@implementation MediaPoint
+ (MediaPoint *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    MediaPoint *instance = [[MediaPoint alloc] init];
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

    if ([key isEqualToString:@"photos"]) {

        if ([value isKindOfClass:[NSArray class]])
        {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Photo *populatedMember = [Photo instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.photos = myMembers;

        }

    } else if ([key isEqualToString:@"videos"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.videos = myMembers;

        }

    }
    else {
        [super setValue:value forKey:key];
    }
    
}



@end
