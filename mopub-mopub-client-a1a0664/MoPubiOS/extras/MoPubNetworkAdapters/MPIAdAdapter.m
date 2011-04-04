//
//  MPIAdAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPIAdAdapter.h"
#import "MPAdView.h"
#import "MPLogging.h"

@implementation MPIAdAdapter

- (void)dealloc
{
	_adBannerView.delegate = nil;
	[_adBannerView release];
	[super dealloc];
}

- (void)getAdWithParams:(NSDictionary *)params
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	Class cls = NSClassFromString(@"ADBannerView");
	if (cls != nil) {
		CGSize size = self.adView.bounds.size;
		
		if (_adBannerView)
		{
			_adBannerView.delegate = nil;
			[_adBannerView release];
		}
		
		_adBannerView = [[cls alloc] initWithFrame:(CGRect){{0, 0}, size}];
		
		// iOS 4.2:
		if (&ADBannerContentSizeIdentifierPortrait != nil)
		{
			_adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
															ADBannerContentSizeIdentifierPortrait, 
															ADBannerContentSizeIdentifierLandscape, 
															nil];
			if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
				_adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			else
				_adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		}
		// Prior to iOS 4.2:
		else
		{
			_adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
															ADBannerContentSizeIdentifier320x50, 
															ADBannerContentSizeIdentifier480x32, 
															nil];
			if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
				_adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
			else
				_adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
			
		}
			
		_adBannerView.delegate = self;
	} 
	else 
	{
		// iAd not supported in iOS versions before 4.0.
		[self bannerView:nil didFailToReceiveAdWithError:nil];
	}
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
	if (!_adBannerView) 
		return;
	
	if (UIInterfaceOrientationIsLandscape(newOrientation))
	{
		// Tests for iOS >= 4.2.
		_adBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape) ? 
			ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
	}
	else
	{
		// Tests for iOS >= 4.2.
		_adBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait) ?
			ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
	}
	
	// Prevent this view from automatically positioning itself in the center of its superview.
	_adBannerView.frame = CGRectMake(0.0, 
									 0.0, 
									 _adBannerView.frame.size.width, 
									 _adBannerView.frame.size.height);
}

#pragma mark -
#pragma	mark ADBannerViewDelegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	MPLogInfo(@"iAd Failed To Receive Ad");
	_hasReceivedFirstResponse = YES;

	// Edge case: This method schedules the banner view to be deallocated. If this method
	// was called due to a failed internal iAd refresh, there is a chance the user could
	// initiate a banner action, only to have the banner view be deallocated during that action.
	// So, just don't allow the user to interact with the iAd.
	[_adBannerView setUserInteractionEnabled:NO];
	
	[self.adView adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	MPLogInfo(@"iAd Finished Executing Banner Action");
	[self.adView userActionDidEndForAdapter:self];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	MPLogInfo(@"iAd Should Begin Banner Action");
	[self.adView userActionWillBeginForAdapter:self];
	return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	// ADBannerView has its own internal timer for refreshing ads, so this callback may happen
	// multiple times. We should only set the ad content view once -- the first time an iAd loads.
	if (!_hasReceivedFirstResponse)
	{
		MPLogInfo(@"iAd Load Succeeded");
		_hasReceivedFirstResponse = YES;
		[self.adView setAdContentView:_adBannerView];
		[self.adView adapterDidFinishLoadingAd:self];
	}
	else 
	{
		MPLogInfo(@"iAd Internal Refresh Succeeded");
	}
}

@end