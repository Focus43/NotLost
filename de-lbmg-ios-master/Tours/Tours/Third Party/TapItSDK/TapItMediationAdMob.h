//
//  TapItMediationAdMob.h
//  NickTest
//
//  Created by Nick Penteado on 8/24/12.
//  Copyright (c) 2012 Nick Penteado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADMAdNetworkAdapterProtocol.h"
#import "GADMAdNetworkConnectorProtocol.h"
#import "TapIt.h"

@interface TapItMediationAdMob : NSObject <TapItBannerAdViewDelegate, TapItInterstitialAdDelegate, GADMAdNetworkAdapter> {
    id<GADMAdNetworkConnector> connector;
    TapItBannerAdView *tapitAd;
    TapItInterstitialAd *tapitInterstitial;
    // used to suppress duplicate calls to adapterWillPresentInterstitial:, adapter:clickDidOccurInBanner, and adapterWillPresentFullScreenModal:
    // (tapit sdk calls tapit[Interstitial|Banner]AdActionShouldBegin:willLeaveApplication: each time a http redirect occurs...)
    int redirectCount;
}

@property (nonatomic, retain) UIView *tapitAd;
@property (nonatomic, retain) NSObject *tapitInterstitial;

@end
