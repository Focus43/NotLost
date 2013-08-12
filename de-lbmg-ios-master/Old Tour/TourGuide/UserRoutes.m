//
//  UserRoutes.m
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import "UserRoutes.h"

#import "Route.h"

@implementation UserRoutes

+ (UserRoutes *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    UserRoutes *instance = [[UserRoutes alloc] init];
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

    if ([key isEqualToString:@"routes"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Route *populatedMember = [Route instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.routes = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


@end
