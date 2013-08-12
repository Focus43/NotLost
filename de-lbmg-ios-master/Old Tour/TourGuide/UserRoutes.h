//
//  UserRoutes.h
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRoutes : NSObject

@property (nonatomic, copy) NSArray *routes;


+ (UserRoutes *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
