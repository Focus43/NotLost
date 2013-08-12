//
//  TapItHelpers.h
//  TapIt-iOS-Sample
//
//  Created by Nick Penteado on 5/16/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


UIInterfaceOrientation TapItInterfaceOrientation();
UIWindow *TapItKeyWindow();
UIViewController *TapItTopViewController();
CGFloat TapItStatusBarHeight();
CGRect TapItApplicationFrame(UIInterfaceOrientation orientation);
CGRect TapItScreenBounds(UIInterfaceOrientation orientation);
CGAffineTransform TapItRotationTransformForOrientation(UIInterfaceOrientation orientation);