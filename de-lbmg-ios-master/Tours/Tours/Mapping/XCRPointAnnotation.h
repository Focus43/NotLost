//
//  XCRPointAnnotation.h
//  TourGuide
//
//  Created by Alan Smithee on 9/17/12.
//  Copyright (c) 2012 LBMG. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface XCRPointAnnotation : MKPointAnnotation

@property (nonatomic, assign) int type;
@property (nonatomic, assign) int poiState;
@property (nonatomic, assign) int poiIndex;
@property (nonatomic, assign) BOOL isStart;

@end
