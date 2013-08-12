//
//  OutlineRoute.m
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import "OutlineRoute.h"

@implementation OutlineRoute

+ (OutlineRoute *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    OutlineRoute *instance = [[OutlineRoute alloc] init];
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

@end
