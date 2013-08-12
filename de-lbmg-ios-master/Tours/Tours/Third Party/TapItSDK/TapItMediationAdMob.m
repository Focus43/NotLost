//
//  TapItMediationAdMob.m
//
//  Created by Nick Penteado on 8/24/12.
//  Copyright (c) 2012 Nick Penteado. All rights reserved.
//

#import "TapItMediationAdMob.h"
#import "GADAdSize.h"
#import "TapIt.h"

#define MEDIATION_STRING @"admob-1.0.1"

@implementation TapItMediationAdMob

@synthesize tapitAd, tapitInterstitial;

+ (NSString *)adapterVersion {
    return TAPIT_VERSION;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

- (id)initWithGADMAdNetworkConnector:(id<GADMAdNetworkConnector>)c {
    self = [super init];
    if (self != nil) {
        connector = c;
        redirectCount = 0;
    }
    return self;
}

- (void)getInterstitial {
    tapitInterstitial = [[TapItInterstitialAd alloc] init];
    tapitInterstitial.delegate = self;
    tapitInterstitial.showLoadingOverlay = NO;
    NSString *zoneId = [connector publisherId];
    TapItRequest *request = [TapItRequest requestWithAdZone:zoneId];
    [request setCustomParameter:MEDIATION_STRING forKey:@"mediation"];
    [tapitInterstitial loadInterstitialForRequest:request];
}

- (void)getBannerWithSize:(GADAdSize)adSize {
    if (!GADAdSizeEqualToSize(adSize, kGADAdSizeBanner) &&
        !GADAdSizeEqualToSize(adSize, kGADAdSizeFullBanner) &&
        !GADAdSizeEqualToSize(adSize, kGADAdSizeLeaderboard) &&
        !GADAdSizeEqualToSize(adSize, kGADAdSizeMediumRectangle)) {
        NSString *errorDesc = [NSString stringWithFormat:
                               @"Invalid ad type %@, not going to get ad.",
                               NSStringFromGADAdSize(adSize)];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   errorDesc, NSLocalizedDescriptionKey, nil];
        NSError *error = [NSError errorWithDomain:@"ad_mediation"
                                             code:1
                                         userInfo:errorInfo];
        [self tapitBannerAdView:nil didFailToReceiveAdWithError:error];
        return;
    }
    
    CGSize cgAdSize = CGSizeFromGADAdSize(adSize);
    CGRect adFrame = CGRectMake(0, 0, cgAdSize.width, cgAdSize.height);
    tapitAd = [[TapItBannerAdView alloc] initWithFrame:adFrame];
    NSString *zoneId = [connector publisherId];
    tapitAd.presentingController = [connector viewControllerForPresentingModalView];
//    tapitAd.shouldReloadAfterTap = NO;
    tapitAd.showLoadingOverlay = NO;
    TapItRequest *adRequest = [TapItRequest requestWithAdZone:zoneId];
    [adRequest setCustomParameter:@"999999" forKey:TAPIT_PARAM_KEY_BANNER_ROTATE_INTERVAL]; // don't rotate banner
    [adRequest setCustomParameter:MEDIATION_STRING forKey:@"mediation"];
    tapitAd.delegate = self;
    [tapitAd startServingAdsForRequest:adRequest];
}

- (void)stopBeingDelegate {
    if(tapitInterstitial) {
        tapitInterstitial.delegate = nil;
    }
    
    if(tapitAd) {
        tapitAd.delegate = nil;
    }
}

- (BOOL)isBannerAnimationOK:(GADMBannerAnimationType)animType {
    return YES;
}

- (void)presentInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [tapitInterstitial presentFromViewController:rootViewController];
}

- (void)dealloc {
    [self stopBeingDelegate];
    [tapitAd release], tapitAd = nil;
    [tapitInterstitial release], tapitInterstitial = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark TapItBannerAdViewDelegate methods

- (void)tapitBannerAdViewWillLoadAd:(TapItBannerAdView *)bannerView {
//    TILog(@"tapitBannerAdViewWillLoadAd:");
    // no google equivilent... NOOP
}

- (void)tapitBannerAdViewDidLoadAd:(TapItBannerAdView *)bannerView {
//    TILog(@"tapitBannerAdViewDidLoadAd:");
    [connector adapter:self didReceiveAdView:bannerView];
}

- (void)tapitBannerAdView:(TapItBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
//    TILog(@"tapitBannerAdView:didFailToReceiveAdWithError:");
    [connector adapter:self didFailAd:error];
}

- (BOOL)tapitBannerAdViewActionShouldBegin:(TapItBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave {
//    TILog(@"tapitBannerAdViewActionShouldBegin:willLeaveApplication:");
    if (redirectCount++ == 0) {
        // tapitBannerAdViewActionShouldBegin:willLeaveApplication: may be called multiple times... only report one click/load...
        [connector adapter:self clickDidOccurInBanner:bannerView];
        [connector adapterWillPresentFullScreenModal:self];
    }
    if (willLeave) {
        [connector adapterWillLeaveApplication:self];
    }
    return YES;
}

- (void)tapitBannerAdViewActionWillFinish:(TapItBannerAdView *)bannerView {
//    TILog(@"tapitBannerAdViewActionWillFinish:");
    [connector adapterWillDismissFullScreenModal:self];
}

- (void)tapitBannerAdViewActionDidFinish:(TapItBannerAdView *)bannerView {
//    TILog(@"tapitBannerAdViewActionDidFinish:");
    [connector adapterDidDismissFullScreenModal:self];
}


#pragma mark -
#pragma mark TapItInterstitialAdDelegate methods

- (void)tapitInterstitialAd:(TapItInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
//    TILog(@"tapitInterstitialAd:didFailWithError:");
    [connector adapter:self didFailInterstitial:error];
}

- (void)tapitInterstitialAdDidUnload:(TapItInterstitialAd *)interstitialAd {
    // no google equivilent... NOOP
    // see tapitInterstitialAdActionWillFinish: and tapitInterstitialAdActionDidFinish:
//    TILog(@"tapitInterstitialAdDidUnload:");
}

- (void)tapitInterstitialAdWillLoad:(TapItInterstitialAd *)interstitialAd {
    // no google equivilent... NOOP
    // see tapitInterstitialAdDidLoad
//    TILog(@"tapitInterstitialAdWillLoad:");
}

- (void)tapitInterstitialAdDidLoad:(TapItInterstitialAd *)interstitialAd {
//    TILog(@"tapitInterstitialAdDidLoad:");
    [connector adapter:self didReceiveInterstitial:interstitialAd];
}

- (BOOL)tapitInterstitialAdActionShouldBegin:(TapItInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
//    TILog(@"tapitInterstitialAdActionShouldBegin:willLeaveApplication:");
    if (redirectCount++ == 0) {
        [connector adapterWillPresentInterstitial:self];
    }
    if (willLeave) {
        [connector adapterWillLeaveApplication:self];
    }
    return YES;
}

- (void)tapitInterstitialAdActionWillFinish:(TapItInterstitialAd *)interstitialAd {
//    TILog(@"tapitInterstitialAdActionWillFinish:");
    [connector adapterWillDismissInterstitial:self];
}

- (void)tapitInterstitialAdActionDidFinish:(TapItInterstitialAd *)interstitialAd {
//    TILog(@"tapitInterstitialAdActionDidFinish:");
    [connector adapterDidDismissInterstitial:self];
}

@end
