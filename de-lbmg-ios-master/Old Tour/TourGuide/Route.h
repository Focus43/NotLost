//
//  Route.h
//  
//
//  Created by Paul Warren on 9/26/12.
//  Copyright (c) 2012 Xcellent Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSArray *outlineRoute;
@property (nonatomic, copy) NSString *routeName;
@property (nonatomic, copy) NSArray *wayPoints;
@property (nonatomic, copy) NSArray *mediaPoints;


+ (Route *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
