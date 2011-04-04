//
//  MPInterstitialAdController.m
//  MoPub
//
//  Created by Andrew He on 2/2/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialAdController.h"

#define ORIENTATION_PORTRAIT_ONLY	@"p"
#define ORIENTATION_LANDSCAPE_ONLY	@"l"
#define ORIENTATION_BOTH			@"b"

#define CLOSE_BUTTON_PADDING		15.0

@interface MPInterstitialAdController (Internal)
- (id)initWithAdUnitId:(NSString *)ID parentViewController:(UIViewController *)parent;
- (void)setUpCloseButton;
@end

@implementation MPInterstitialAdController

@synthesize ready = _ready;
@synthesize parent = _parent;
@synthesize adUnitId = _adUnitId;

#pragma mark -
#pragma mark Class methods

+ (NSMutableArray *)sharedInterstitialAdControllers
{
	static NSMutableArray *sharedInterstitialAdControllers;
	
	@synchronized(self)
	{
		if (!sharedInterstitialAdControllers)
			sharedInterstitialAdControllers = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return sharedInterstitialAdControllers;
}

+ (MPInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)ID
{	
	NSMutableArray *controllers = [MPInterstitialAdController sharedInterstitialAdControllers];
	
	@synchronized(self)
	{
		// Find the correct ad controller based on the ad unit ID.
		MPInterstitialAdController *controller = nil;
		for (MPInterstitialAdController *c in controllers)
		{
			if ([c.adUnitId isEqualToString:ID])
			{
				controller = c;
				break;
			}
		}
		
		// Create the ad controller if it doesn't exist.
		if (!controller)
		{
			controller = [[[MPInterstitialAdController alloc] initWithAdUnitId:ID 
														  parentViewController:nil] autorelease];
			[controllers addObject:controller];
		}
		return controller;
	}
}

+ (void)removeSharedInterstitialAdController:(MPInterstitialAdController *)controller
{
	NSMutableArray *sharedInterstitialAdControllers = [MPInterstitialAdController sharedInterstitialAdControllers];
	[sharedInterstitialAdControllers removeObject:controller];
}

#pragma mark -
#pragma mark Lifecycle

- (id)initWithAdUnitId:(NSString *)ID parentViewController:(UIViewController *)parent
{
	if (self = [super init])
	{
		_ready = NO;
		_parent = parent;
		_adUnitId = ID;
		_adSize = [[UIScreen mainScreen] bounds].size;
		_closeButtonType = InterstitialCloseButtonTypeDefault;
		_orientationType = InterstitialOrientationTypeBoth;
	}
	return self;
}

- (void)dealloc 
{
	_parent = nil;
	_adView.delegate = nil;
	[_adView release];
	[_adUnitId release];
    [super dealloc];
}

- (void)loadView 
{
	self.view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.frame = (CGRect){{0, 0}, [UIScreen mainScreen].bounds.size};
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	_adView = [[MPAdView alloc] initWithAdUnitId:self.adUnitId size:_adSize];
	// Typically, we don't set an autoresizing mask for MPAdView, but in this case we always
	// want it to occupy the full screen.
	_adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_adView.delegate = self;
	[self.view addSubview:_adView];
	
	[self setUpCloseButton];
}

- (void)viewWillAppear:(BOOL)animated
{
	// Triggers -loadView if it hasn't happened.
	self.view;
	[super viewWillAppear:animated];
	
	if ([self.parent respondsToSelector:@selector(interstitialWillAppear:)])
		[self.parent interstitialWillAppear:self];
}

- (void)viewDidAppear:(BOOL)animated
{
	// Triggers -loadView if it hasn't happened.
	self.view;
	[_adView adViewDidAppear];
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Internal

- (void)setUpCloseButton
{
	if (_closeButtonType == InterstitialCloseButtonTypeDefault)
	{
		[_closeButton removeFromSuperview];
		_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *closeButtonImage = [UIImage imageNamed:@"MPCloseButtonX.png"];
		[_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
		[_closeButton sizeToFit];
		_closeButton.frame = CGRectMake(self.view.frame.size.width - CLOSE_BUTTON_PADDING - _closeButton.frame.size.width,
										CLOSE_BUTTON_PADDING,
										_closeButton.frame.size.width,
										_closeButton.frame.size.height);
		_closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		[_closeButton addTarget:self 
						 action:@selector(closeButtonPressed) 
			   forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:_closeButton];
		[self.view bringSubviewToFront:_closeButton];
	}
	else
	{
		[_closeButton removeFromSuperview];
	}
}

#pragma mark -

- (void)setKeywords:(NSString *)keywords
{
	_adView.keywords = keywords;
}

- (NSString *)keywords
{
	return _adView.keywords;
}

- (void)closeButtonPressed
{
	// Restore previous status/navigation bar state.
	[[UIApplication sharedApplication] setStatusBarHidden:_statusBarWasHidden];
	[self.navigationController setNavigationBarHidden:_navigationBarWasHidden animated:NO];
	
	[self.parent dismissInterstitial:self];
}

- (void)loadAd
{
	// Triggers -loadView if it hasn't happened.
	self.view;
	[_adView loadAd];
}

- (void)show
{	
	// Track the previous state of the status bar, so that we can restore it.
	_statusBarWasHidden = [UIApplication sharedApplication].statusBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	// Likewise, track the previous state of the navigation bar.
	_navigationBarWasHidden = self.navigationController.navigationBarHidden;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[self.parent presentModalViewController:self animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if (_orientationType == InterstitialOrientationTypePortrait)
		return (interfaceOrientation == UIInterfaceOrientationPortrait || 
				interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	else if (_orientationType == InterstitialOrientationTypeLandscape)
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
				interfaceOrientation == UIInterfaceOrientationLandscapeRight);
	else
		return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
	_ready = YES;
	
	if ([self.parent respondsToSelector:@selector(interstitialDidLoadAd:)])
		[self.parent interstitialDidLoadAd:self];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
	_ready = NO;
	
	if ([self.parent respondsToSelector:@selector(interstitialDidFailToLoadAd:)])
		[self.parent interstitialDidFailToLoadAd:self];
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
	if ([self.parent respondsToSelector:@selector(willPresentModalViewForAd:)])
		[self.parent willPresentModalViewForAd:view];
}

- (void)adViewDidReceiveResponseParams:(NSDictionary *)params
{
	NSString *closeButtonChoice = [params objectForKey:@"X-Closebutton"];
	
	if ([closeButtonChoice isEqualToString:@"None"])
		_closeButtonType = InterstitialCloseButtonTypeNone;
	else
		_closeButtonType = InterstitialCloseButtonTypeDefault;
	
	// Adjust the close button depending on the value of "X-Closebutton".
	[self setUpCloseButton];
	
	// Set the allowed orientations.
	NSString *orientationChoice = [params objectForKey:@"X-Orientation"];
	if ([orientationChoice isEqualToString:ORIENTATION_PORTRAIT_ONLY])
		_orientationType = InterstitialOrientationTypePortrait;
	else if ([orientationChoice isEqualToString:ORIENTATION_LANDSCAPE_ONLY])
		_orientationType = InterstitialOrientationTypeLandscape;
	else 
		_orientationType = InterstitialOrientationTypeBoth;
}

- (void)adViewShouldClose:(MPAdView *)view
{
	[self closeButtonPressed];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
