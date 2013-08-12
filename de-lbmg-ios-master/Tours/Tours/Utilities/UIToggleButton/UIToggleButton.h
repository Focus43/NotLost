//
//  UIToggleButton.h
//  
//
//  Created by Alan Smithee on 2/1/13.
//  Copyright (c) 2013 Carl Edwards. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToggleButton : UIButton

@property (nonatomic, strong) UIColor *toggleOnColor;
@property (nonatomic, strong) UIColor *toggleOnFontColor;
@property (nonatomic, strong) UIColor *toggleOnShadowColor;

@property (nonatomic, strong) UIColor *toggleOffColor;
@property (nonatomic, strong) UIColor *toggleOffFontColor;
@property (nonatomic, strong) UIColor *toggleOffShadowColor;

@property (nonatomic, strong) UIImage *toggleOffImage;
@property (nonatomic, strong) UIImage *toggleOnImage;
@property (nonatomic) BOOL isToggled;

//- (void)toggleColorOn:(BOOL)on;
- (void)setToggleOffImage:(UIImage *)toggleOffImage andToggleOnImage:(UIImage *)toggleOnImage;
- (void)setToggleOffColor:(UIColor *)toggleOffColor fontColor:(UIColor *)fontColor withShadowColor:(UIColor *)shadowColor;
- (void)setToggleOnColor:(UIColor *)toggleOnColor fontColor:(UIColor *)fontColor withShadowColor:(UIColor *)shadowColor;
//- (void)setToggleOffColor:(UIColor *)toggleOffColor andToggleOnColor:(UIColor *)toggleOnColor;
- (void)setOn;
- (void)setOff;

@end
