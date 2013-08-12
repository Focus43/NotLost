//
//  WayPoint.h
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WayPoint : NSObject

@property (nonatomic, copy) NSNumber *index;
@property (nonatomic, copy) NSString *audioItem;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, assign) BOOL poi;
@property (nonatomic, copy) NSNumber *radiusMeters;
@property (nonatomic, copy) NSArray *videos;
@property (nonatomic, assign) NSNumber *dependancy;


+ (WayPoint *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
