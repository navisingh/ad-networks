//
//  MPGoogleAdSenseAdapter.m
//  MoPub
//
//  Created by Andrew He on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPGoogleAdSenseAdapter.h"
#import "CJSONDeserializer.h"
#import "MPAdView.h"
#import "MPLogging.h"

static NSDictionary *GADHeaderAttrMap = nil;

@implementation MPGoogleAdSenseAdapter

+ (void)initialize
{
	GADHeaderAttrMap = [[NSDictionary alloc] initWithObjectsAndKeys:
											 kGADAdSenseClientID,@"Gclientid",
											 kGADAdSenseCompanyName,@"Gcompanyname",
											 kGADAdSenseAppName,@"Gappname",
											 kGADAdSenseApplicationAppleID,@"Gappid",
											 kGADAdSenseKeywords,@"Gkeywords",
											 kGADAdSenseIsTestAdRequest,@"Gtestadrequest",
											 kGADAdSenseAppWebContentURL,@"Gappwebcontenturl", 
											 kGADAdSenseChannelIDs,@"Gchannelids",
											 kGADAdSenseAdType,@"Gadtype",
											 kGADAdSenseHostID,@"Ghostid",
											 kGADAdSenseAdBackgroundColor,@"Gbackgroundcolor",
											 kGADAdSenseAdTopBackgroundColor,@"Gadtopbackgroundcolor",
											 kGADAdSenseAdBorderColor,@"Gadbordercolor",
											 kGADAdSenseAdLinkColor,@"Gadlinkcolor",
											 kGADAdSenseAdTextColor,@"Gadtextcolor",
											 kGADAdSenseAdURLColor,@"Gadurlolor",
											 kGADExpandDirection,@"Gexpandirection",
											 kGADAdSenseAlternateAdColor,@"Galternateadcolor",
											 kGADAdSenseAlternateAdURL,@"Galternateadurl",
											 kGADAdSenseAllowAdsafeMedium,@"Gallowadsafemedium",
											 nil];
}

- (id)initWithAdView:(MPAdView *)adView
{
	if (self = [super initWithAdView:adView])
	{
		_adViewController = [[GADAdViewController alloc] initWithDelegate:self];
	}
	return self;
}

- (void)dealloc
{
	_adViewController.delegate = nil;
	[_adViewController release];
	[super dealloc];
}

- (NSNumber *)GtestadrequestKeyConvert:(NSString *)str
{
	return [NSNumber numberWithInt:[str intValue]];
}

- (NSArray *)GchannelidsKeyConvert:(NSString *)str
{
	// chop off [" and "]
	str = [str substringWithRange:NSMakeRange(2, [str length] - 4)];
	return [str componentsSeparatedByString:@"', '"]; 
}

- (NSString *)GadtypeKeyConvert:(NSString *)str
{
	if ([str isEqual:@"GADAdSenseTextAdType"])
		return kGADAdSenseTextAdType;
	if ([str isEqual:@"GADAdSenseImageAdType"])
		return kGADAdSenseImageAdType;
	if ([str isEqual:@"GADAdSenseTextImageAdType"])
		return kGADAdSenseTextImageAdType; 
	return kGADAdSenseTextImageAdType;
}

- (void)getAdWithParams:(NSDictionary *)params
{	
	// Native AdSense params.
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
	NSData *headerData = [(NSString *)[params objectForKey:@"X-Nativeparams"] dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *headerParams = [[CJSONDeserializer deserializer] deserializeAsDictionary:headerData
																					 error:NULL];
	for (NSString *key in headerParams)
	{
		NSObject *value = [headerParams objectForKey:key];
		if (value && ![(NSString *)value isEqual:@""]) 
		{
			SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@KeyConvert:",key]);
			if ([self respondsToSelector:selector])
			{
				value = [self performSelector:selector withObject:(NSString *)value];
			}
			[attributes setObject:value forKey:[GADHeaderAttrMap objectForKey:key]];
		}				
	}
	
	// Sizing params.
	CGFloat width = [[params objectForKey:@"X-Width"] floatValue];
	CGFloat height = [[params objectForKey:@"X-Height"] floatValue];
	
	if (width == 320.0 && height == 50.0){
		_adViewController.adSize = kGADAdSize320x50; 
	}
	else if (width == 300.0 && height == 250.0){
		_adViewController.adSize = kGADAdSize300x250;
	}
	else if (width == 468.0 && height == 60.0){
		_adViewController.adSize = kGADAdSize468x60;
	}
	else if (width == 728.0 && height == 90.0){
		_adViewController.adSize = kGADAdSize728x90;
	}
	
	// Finally, request the ad.
	_adViewController.view.frame = CGRectMake(0, 0, width, height);
	[_adViewController loadGoogleAd:attributes];
	[attributes release];
}

#pragma mark -
#pragma mark GADAdViewControllerDelegate

- (UIViewController *)viewControllerForModalPresentation:
(GADAdViewController *)adController
{
	return [self.adView.delegate viewControllerForPresentingModalView];
}

- (void)loadSucceeded:(GADAdViewController *)adController
          withResults:(NSDictionary *)results
{
	[self.adView setAdContentView:adController.view];
	[self.adView adapterDidFinishLoadingAd:self];
}

- (void)loadFailed:(GADAdViewController *)adController
         withError:(NSError *)error
{
	[self.adView adapter:self didFailToLoadAdWithError:nil];
}

- (GADAdClickAction)adControllerActionModelForAdClick:
(GADAdViewController *)adController
{
	[self.adView userActionWillBeginForAdapter:self];
	return GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW;
}

- (void)adControllerDidCloseWebsiteView:(GADAdViewController *)adController
{
	[self.adView userActionDidEndForAdapter:self];
}

@end
