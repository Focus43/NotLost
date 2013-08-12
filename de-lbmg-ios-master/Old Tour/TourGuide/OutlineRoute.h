//
//  OutlineRoute.h
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlineRoute : NSObject

@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;


+ (OutlineRoute *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
