//
//  UIToggleButton.m
//  
//
//  Created by Alan Smithee on 2/1/13.
//  Copyright (c) 2013 Carl Edwards. All rights reserved.
//

#import "UIToggleButton.h"

@implementation UIToggleButton

//- (void)toggleColorOn:(BOOL)on {
//    [self setBackgroundColor:on ? self.toggleOnColor : self.toggleOffColor];
//    //self.highlighted = YES;
//    if (on) {
//        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
////        [self.titleLabel setTextColor:[UIColor redColor]];
//    }
//    else {
//        //[self.titleLabel setTextColor:[UIColor greenColor]];
//        [self setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//    }
//}

- (void)setOn {
    [self setBackgroundColor:self.toggleOnColor];
    [self setTitleColor:self.toggleOnFontColor forState:UIControlStateNormal];
    [self setTitleShadowColor:self.toggleOnShadowColor forState:UIControlStateNormal];
    
    self.isToggled = YES;
    [self setImage:self.toggleOnImage forState:UIControlStateNormal];
    [self setImage:self.toggleOnImage forState:UIControlStateHighlighted];
}

- (void)setOff {
    [self setBackgroundColor:self.toggleOffColor];
    [self setTitleColor:self.toggleOffFontColor forState:UIControlStateNormal];
    [self setTitleShadowColor:self.toggleOffShadowColor forState:UIControlStateNormal];
    
    self.isToggled = NO;
    [self setImage:self.toggleOffImage forState:UIControlStateNormal];
    [self setImage:self.toggleOffImage forState:UIControlStateHighlighted];
}

//- (void)setToggleOffColor:(UIColor *)toggleOffColor andToggleOnColor:(UIColor *)toggleOnColor {
//    self.toggleOffColor = toggleOffColor;
//    self.toggleOnColor = toggleOnColor;
//    [self setBackgroundColor:self.toggleOffColor];
//}

- (void)setToggleOffColor:(UIColor *)toggleOffColor fontColor:(UIColor *)fontColor withShadowColor:(UIColor *)shadowColor {
    self.toggleOffColor = toggleOffColor;
    self.toggleOffFontColor = fontColor;
    self.toggleOffShadowColor = shadowColor;
}

- (void)setToggleOnColor:(UIColor *)toggleOnColor fontColor:(UIColor *)fontColor withShadowColor:(UIColor *)shadowColor {
    self.toggleOnColor = toggleOnColor;
    self.toggleOnFontColor = fontColor;
    self.toggleOnShadowColor = shadowColor;
}

- (void)setToggleOffImage:(UIImage *)toggleOffImage andToggleOnImage:(UIImage *)toggleOnImage {
    self.toggleOffImage = toggleOffImage;
    self.toggleOnImage = toggleOnImage;
    [self setImage:self.isToggled ? self.toggleOnImage :self.toggleOffImage forState:UIControlStateHighlighted];
}

@end
