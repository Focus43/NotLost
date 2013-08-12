//
//  TapItInterstitialAd.h
//  TapIt-iOS-Sample
//
//  Created by Nick Penteado on 4/11/12.
//  Copyright (c) 2012 TapIt!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TapItAdDelegates.h"
#import "TapItConstants.h"

@class TapItRequest;

@interface TapItInterstitialAd : NSObject <TapItInterstitialAdDelegate, TapItBrowserControllerDelegate>

@property (assign, nonatomic) id<TapItInterstitialAdDelegate> delegate;

@property (assign, nonatomic) BOOL animated;
@property (assign, nonatomic) BOOL autoReposition;
@property (assign, nonatomic) BOOL showLoadingOverlay;
//@property (assign, nonatomic) TapItInterstitialControlType controlType;
@property (assign, nonatomic) TapItAdType allowedAdTypes;
@property (readonly) BOOL loaded;
@property (assign, nonatomic) UIViewController *presentingController;

- (BOOL)loadInterstitialForRequest:(TapItRequest *)request;

- (void)presentFromViewController:(UIViewController *)contoller;
//- (void)presentInView:(UIView *)view;

@end
