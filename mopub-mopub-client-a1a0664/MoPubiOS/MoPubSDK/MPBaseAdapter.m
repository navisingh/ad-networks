//
//  MPBaseAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseAdapter.h"
#import "MPAdView.h"
#import "MPLogging.h"

@implementation MPBaseAdapter

@synthesize adView = _adView;

- (id)initWithAdView:(MPAdView *)adView
{
	if (self = [super init])
		_adView = adView;
	return self;
}

- (void)dealloc
{
	_adView = nil;
	[super dealloc];
}

- (void)unregisterDelegate
{
	_adView = nil;
}

- (void)getAd
{
	[self getAdWithParams:nil];
}

- (void)getAdWithParams:(NSDictionary *)params
{
	// To be implemented by subclasses.
	[self doesNotRecognizeSelector:_cmd];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
	// Do nothing by default. Subclasses can override.
	MPLogDebug(@"rotateToOrientation %d called for adapter %@ (%p)",
		  newOrientation, NSStringFromClass([self class]), self);
}

@end
