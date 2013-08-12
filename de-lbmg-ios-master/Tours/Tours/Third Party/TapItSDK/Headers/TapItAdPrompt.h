//
//  TapItPopupAd.h
//  TapIt-iOS-Sample
//
//  Created by Nick Penteado on 7/20/12.
//  Copyright (c) 2012 TapIt!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TapItAdDelegates.h"

@class TapItRequest;

@interface TapItAdPrompt : NSObject <UIActionSheetDelegate>

@property (assign, nonatomic) id<TapItAdPromptDelegate> delegate;
@property (readonly) BOOL loaded;
@property (assign) BOOL showLoadingOverlay;

- (id)initWithRequest:(TapItRequest *)request;

/**
 * preload the AdPrompt, to be shown later...
 */
- (void)load;

- (void)showAsAlert;
- (void)showAsActionSheet;

@end
