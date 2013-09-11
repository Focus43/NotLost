//
//  TutorialPhoto.h
//  NotLost
//
//  Created by Stine Richvoldsen on 9/9/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "Photo.h"

@interface TutorialPhoto : Photo

@property (nonatomic) BOOL isTutorialImage; 

+ (TutorialPhoto *)instanceFromDictionary:(NSDictionary *)aDictionary;

@end
