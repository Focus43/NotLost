//
//  TutorialPhoto.m
//  NotLost
//
//  Created by Stine Richvoldsen on 9/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "TutorialPhoto.h"

@implementation TutorialPhoto

+ (TutorialPhoto *)instanceFromDictionary:(NSDictionary *)aDictionary
{    
    TutorialPhoto *instance = [[TutorialPhoto alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    instance.isTutorialImage = YES;
    instance.
    
    return instance;    
}

@end
