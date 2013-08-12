//
//  LBMGImage.h
//  Tours
//
//  Created by Alan Smithee on 4/4/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//
// From: http://www.icab.de/blog/2010/10/01/scaling-images-and-creating-thumbnails-from-uiviews/

#import <UIKit/UIKit.h>

@interface LBMGImage :UIImage

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
