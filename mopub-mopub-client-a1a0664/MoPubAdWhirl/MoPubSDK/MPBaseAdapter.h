//
//  MPBaseAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPAdView;

@interface MPBaseAdapter : NSObject 
{
	// Reference to the parent MPAdView.
	MPAdView *_adView;
}

@property (nonatomic, readonly) MPAdView *adView;

/*
 * Creates an adapter with a reference to an MPAdView.
 */
- (id)initWithAdView:(MPAdView *)adView;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -getAdWithParams: needs to be implemented by adapter subclasses that want to load native ads.
 * -getAd simply calls -getAdWithParams: with a nil dictionary.
 */
- (void)getAd;
- (void)getAdWithParams:(NSDictionary *)params;

/*
 * Your subclass should implement this method if your native ads vary depending on orientation.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

@end

@protocol MPAdapterDelegate
@required
/*
 * These callbacks notify you that the adapter (un)successfully loaded an ad.
 */
- (void)adapterDidFinishLoadingAd:(MPBaseAdapter *)adapter;
- (void)adapter:(MPBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;

/*
 * These callbacks notify you that user interacted (or stopped interacting) with the native ad.
 */
- (void)userActionWillBeginForAdapter:(MPBaseAdapter *)adapter;
- (void)userActionDidEndForAdapter:(MPBaseAdapter *)adapter;
@end