//
//  MPInterstitialAdController.h
//  MoPub
//
//  Created by Andrew He on 2/2/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

enum 
{
	InterstitialCloseButtonTypeDefault,
	InterstitialCloseButtonTypeNone
};
typedef NSUInteger InterstitialCloseButtonType;

enum 
{
	InterstitialOrientationTypePortrait,
	InterstitialOrientationTypeLandscape,
	InterstitialOrientationTypeBoth
};
typedef NSUInteger InterstitialOrientationType;

@protocol MPInterstitialAdControllerDelegate;

@interface MPInterstitialAdController : UIViewController <MPAdViewDelegate>
{
	// Previous state of the status bar, before the interstitial appears.
	BOOL _statusBarWasHidden;
	
	// Previous state of the nav bar, before the interstitial appears.
	BOOL _navigationBarWasHidden;
	
	// Whether the interstitial is fully loaded.
	BOOL _ready;
	
	// Underlying ad view used for the interstitial.
	MPAdView *_adView;
	
	// Reference to the view controller that is presenting this interstitial.
	UIViewController<MPInterstitialAdControllerDelegate> *_parent;
	
	// The ad unit ID.
	NSString *_adUnitId;
	
	// Size of the interstitial ad. Defaults to fill the entire screen.
	CGSize _adSize;
	
	// Determines what kind of close button we want to display.
	InterstitialCloseButtonType _closeButtonType;
	
	// Determines the allowed orientations for the interstitial.
	InterstitialOrientationType _orientationType;
	
	// Button used to dismiss the interstitial.
	UIButton *_closeButton;
}

@property (nonatomic, readonly, assign) BOOL ready;
@property (nonatomic, assign) UIViewController<MPInterstitialAdControllerDelegate> *parent;
@property (nonatomic, copy) NSString *adUnitId;

/*
 * A shared pool of interstitial ads.
 */
+ (NSMutableArray *)sharedInterstitialAdControllers;

/*
 * Gets an interstitial for the given ad unit ID. Once created, an interstitial will stay around
 * so that you can retrieve it later.
 */
+ (MPInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)ID;

/*
 * Removes an interstitial from the shared pool.
 */
+ (void)removeSharedInterstitialAdController:(MPInterstitialAdController *)controller;

/*
 * Begin loading the content for the interstitial ad. You may implement the -interstitialDidLoadAd
 * and -interstitialDidFailToLoadAd delegate methods, so that you can decide when to show the ad.
 * This method does not automatically retry if it fails.
 */
- (void)loadAd;

/*
 * Display the interstitial modally.
 */
- (void)show;

@end

@protocol MPInterstitialAdControllerDelegate <MPAdViewDelegate>
@required
/*
 * This callback notifies you to dismiss the interstitial, and allows you to implement any
 * pre-dismissal behavior (e.g. unpausing a game).
 */
- (void)dismissInterstitial:(MPInterstitialAdController *)interstitial;

@optional
/*
 * These callbacks notify you when the interstitial (un)successfully loads its ad content. You may
 * implement these if you want to prefetch interstitial ads.
 */
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial;
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial;

/*
 * This callback notifies you that the interstitial is about to appear. This is a good time to
 * handle potential app interruptions (e.g. pause a game).
 */
- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial;
@end

