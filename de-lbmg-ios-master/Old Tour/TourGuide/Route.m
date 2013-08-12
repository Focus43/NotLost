//
//  Route.m
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import "Route.h"

#import "OutlineRoute.h"
#import "WayPoint.h"

@implementation Route

+ (Route *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Route *instance = [[Route alloc] init];
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

    if ([key isEqualToString:@"outlineRoute"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                OutlineRoute *populatedMember = [OutlineRoute instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.outlineRoute = myMembers;

        }

    } else if ([key isEqualToString:@"wayPoints"]) {

        if ([value isKindOfClass:[NSArray class]])
        {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                WayPoint *populatedMember = [WayPoint instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.wayPoints = myMembers;

        }
    } else if ([key isEqualToString:@"mediaPoints"]) {
        
        if ([value isKindOfClass:[NSArray class]])
            {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                WayPoint *populatedMember = [WayPoint instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            
            self.mediaPoints = myMembers;
            
            }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


@end
